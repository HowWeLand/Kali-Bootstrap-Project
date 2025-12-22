# Phase 1: Automated Installation - Secure Erase to Bootable System

**Status:** Destructive operations, scripted automation  
**Environment:** Kali Live USB  
**Goal:** From bare drives to bootable OpenRC system at TTY login

**⚠️ WARNING:** This phase **destroys all data** on target drives. Have backups.

---

## Overview

Phase 1 transforms bare metal into a bootable encrypted Kali system:

1. **Secure erase** drives (cryptographic if supported)
2. **Partition** drives (GPT, labeled)
3. **Encrypt** partitions (LUKS2)
4. **Create filesystems** (BTRFS with subvolumes)
5. **Mount** for bootstrap
6. **Bootstrap** Kali with OpenRC
7. **Configure** basic system
8. **Install bootloader** (GRUB)

**After Phase 1:**
- System boots to TTY login
- All crypto unlocks via USB keyfile
- All BTRFS subvolumes mounted
- OpenRC managing services
- Ready for Phase 2 customization

---

## Prerequisites

### What You Need

**From Phase 0:**
- Configuration file (`install-config.sh`) with all decisions
- Hardware identified (drive paths, serial numbers)
- Backups completed

**Physical items:**
- Kali Live USB (booted)
- Target drives (NVMe, SATA)
- USB drive for keyfiles (4GB+)
- Network connection (for package downloads)
- 2-3 hours uninterrupted time

**Mental preparation:**
- Understand what will be destroyed
- Know how to recover if it fails
- Read the script before running
- Accept responsibility for your data

### Boot Kali Live USB

1. Insert Kali Live USB
2. Boot system (F12/F2/Del for boot menu)
3. Select Live system (not installer)
4. Wait for desktop
5. Open terminal

### Verify Environment

```bash
# Check you're on live system
cat /etc/hostname
# Should NOT show your target hostname

# Check target drives visible
lsblk
# Should show your NVMe and SATA drives

# Check USB keyfile drive
lsblk | grep -i kali
# Or whatever label you'll use

# Check network
ping -c 3 kali.org
# Should work
```

---

## The Automation Script

**Location:** `scripts/phase1-automated-install.sh`

**See:** `docs/Script-Architecture.md` for design principles and safety features.

### What the Script Does

**Automatically:**
1. Verifies hardware (drive existence, serial numbers)
2. Confirms with user (interactive approval)
3. Secure erases drives (nvme-cli, smartmontools)
4. Creates partitions (parted)
5. Sets up LUKS encryption (cryptsetup)
6. Backs up LUKS headers immediately
7. Generates and stores keyfile
8. Creates BTRFS filesystems
9. Creates subvolumes (flat layout)
10. Mounts everything for bootstrap
11. Runs debootstrap with OpenRC
12. Generates fstab and crypttab
13. Configures basic system (hostname, locale, etc.)
14. Creates chroot finalization script
15. Logs everything with color-coded output

**Prompts user for:**
- LUKS passphrase (backup recovery method)
- Final confirmation before destruction
- Manual verification at key points

**Does NOT do:**
- Assume anything about your hardware
- Run if serial numbers don't match
- Continue if any step fails
- Hide errors or warnings

### Script Safety Features

**See:** `docs/Script-Architecture.md` for complete safety design.

**Key safety features:**
- Serial number verification (prevents wrong-drive disasters)
- Explicit confirmation required ("Type 'DESTROY ALL DATA'")
- 5-second countdown before destruction
- Fails fast on any error (`set -euo pipefail`)
- Color-coded logging (easy to spot problems)
- Verification checks throughout
- Creates recovery script for chroot

---

## Before Running the Script

### 1. Review Configuration

```bash
# Open your config file
vim install-config.sh

# Verify every value
# Especially:
# - Drive paths
# - Serial numbers
# - Labels (no conflicts)
# - Sizes appropriate
```

### 2. Verify Drive Serial Numbers

```bash
# NVMe
nvme id-ctrl /dev/nvme0n1 | grep "^sn"
# Output: sn      : S5GXNX0T123456

# SATA
sudo smartctl -i /dev/sda | grep "Serial Number"
# Output: Serial Number:    20180123456789

# Compare to config file
# MUST MATCH EXACTLY
```

### 3. Check lsblk One More Time

```bash
lsblk -o NAME,SIZE,TYPE,MODEL,SERIAL
```

**Verify:**
- Drive paths match config
- Sizes are what you expect
- Models are correct
- Nothing is currently mounted on targets

### 4. Prepare USB Keyfile Drive

```bash
# Insert USB drive for keyfiles
lsblk
# Note the device (probably /dev/sdb or /dev/sdc)

# Update config if needed
# USB_DRIVE="/dev/sdb"  # Or whatever lsblk shows
```

### 5. Read the Script

**Don't run scripts you haven't read:**

```bash
less scripts/phase1-automated-install.sh
```

**Understand:**
- What it does in each section
- Where it prompts for input
- How it handles errors
- What gets logged

---

## Running Phase 1

### Execute the Script

```bash
# Make executable if needed
chmod +x scripts/phase1-automated-install.sh

# Run as root
sudo bash scripts/phase1-automated-install.sh
```

### What to Expect

**Initial checks (1-2 minutes):**
- Script verifies it's running as root
- Checks for live environment
- Verifies drive existence
- Checks serial numbers
- Confirms drives unmounted

**If any check fails:** Script exits with error message.

**Confirmation prompt:**
```
==========================================
  FINAL CONFIRMATION BEFORE DESTRUCTION
==========================================

This will PERMANENTLY DESTROY ALL DATA on:

[lsblk output of target drives]

Target drives:
  NVMe Root: /dev/nvme0n1 (serial: S5GXNX0T123456)
  SATA Home: /dev/sda (serial: 20180123456789)
  USB Key:   /dev/sdb

Type 'DESTROY ALL DATA' to continue:
```

**You must type exactly:** `DESTROY ALL DATA`

**Then:** 5 second countdown (press Ctrl+C to abort)

### Secure Erase Phase (5-10 minutes)

**NVMe secure erase:**
- Checks for cryptographic erase support
- Falls back to user data erase if needed
- Takes 1-2 minutes typically
- Cannot be interrupted once started

**SATA SSD secure erase:**
- Checks if drive is "frozen"
- May attempt suspend/resume to unfreeze
- Uses sanitize (cryptographic) if supported
- Falls back to ATA secure erase
- Takes 2-5 minutes

**USB keyfile drive:**
- Simple format (not storing sensitive data on it)
- Creates FAT32 partition
- Fast (under 1 minute)

**What you'll see:**
```
[INFO] Starting NVMe secure erase on /dev/nvme0n1...
[WARNING] This will take 1-2 minutes and cannot be interrupted
[INFO] Using cryptographic erase (instant)
[SUCCESS] NVMe secure erase completed
```

### Partitioning Phase (1-2 minutes)

**Creates:**
- GPT partition tables
- Labeled partitions (by-partlabel references)
- EFI, Boot, Encrypted Root (NVMe)
- Encrypted Home (SATA)
- Keyfile storage (USB)

**What you'll see:**
```
[INFO] Creating partition table on /dev/nvme0n1...
[INFO] Creating EFI partition (512M)...
[INFO] Creating boot partition (10G)...
[INFO] Creating encrypted root partition (remaining space)...
[SUCCESS] NVMe partitions created
```

### Encryption Phase (5-10 minutes)

**Prompts for LUKS passphrase:**
```
==========================================
  LUKS PASSPHRASE SETUP
==========================================

This passphrase is for backup recovery only.
Primary unlock will use USB keyfile.
Use a strong passphrase you can remember!

Enter LUKS passphrase: [hidden]
Confirm passphrase: [hidden]
```

**Then encrypts both drives:**
- Sets up LUKS2 with argon2id
- Takes 2-3 minutes per drive
- CPU intensive (argon2id is memory-hard)

**Immediately backs up headers:**
```
[INFO] Backing up LUKS headers to USB drive...
[SUCCESS] LUKS headers backed up
```

**Critical:** Headers backed up before any data written.

**Generates keyfile:**
- 4096 bytes of `/dev/urandom`
- Stored on USB at `/crypto_keyfile`
- Added to both LUKS volumes
- Passphrase still works (fallback)

### Filesystem Phase (2-3 minutes)

**Creates BTRFS filesystems:**
```
[INFO] Creating BTRFS filesystems...
[INFO] Creating BTRFS on cryptroot...
[INFO] Creating BTRFS on crypthome...
[SUCCESS] BTRFS filesystems created
```

**Creates subvolumes:**
- Root drive: `@`, `@opt`, `@srv`, `@usr@local`, `@var@log`, `@var@cache`, `@var@tmp`
- Home drive: `@home`, `@var@lib@libvirt@images`, `@var@lib@containers`

### Mount Phase (1 minute)

**Mounts everything at /mnt:**
```
[INFO] Mounting filesystems for bootstrap...
[SUCCESS] Filesystems mounted for bootstrap
[INFO] Mount structure:
/dev/mapper/cryptroot on /mnt type btrfs (...)
/dev/disk/by-partlabel/BOOT on /mnt/boot type ext4 (...)
[etc...]
```

### Bootstrap Phase (10-20 minutes)

**Downloads and installs base system:**
```
[INFO] Starting bootstrap (this will take several minutes)...
```

**What happens:**
- Downloads ~200-300MB of packages
- Unpacks and installs
- Configures dpkg
- Sets up package database
- Installs OpenRC, kernel, GRUB, crypto tools

**This is the longest phase** - be patient.

**What you'll see:**
```
I: Retrieving Release
I: Retrieving Packages
I: Validating Packages
I: Unpacking base system
[lots of package installation messages]
[SUCCESS] Bootstrap completed
```

### Configuration Phase (2-3 minutes)

**Generates config files:**
- `/etc/fstab` - All subvolumes with correct options
- `/etc/crypttab` - Both encrypted drives with keyfile
- `/etc/hostname` - Your chosen hostname
- `/etc/hosts` - Basic network resolution
- Locale and timezone settings

**Creates chroot finalization script:**
```
[SUCCESS] Chroot finalization script created
```

### Phase 1 Complete

```
==========================================
[SUCCESS] Phase 1 automation complete!
==========================================

Next steps:
1. Mount proc/sys/dev for chroot:
   mount -t proc /proc /mnt/proc
   mount -t sysfs /sys /mnt/sys
   mount --bind /dev /mnt/dev
   mount --bind /dev/pts /mnt/dev/pts

2. Chroot into system:
   chroot /mnt /bin/bash

3. Run finalization script:
   /root/finalize-install.sh

4. Exit chroot and reboot
```

---

## Post-Script: Chroot Finalization

### Enter Chroot

**Mount proc/sys/dev:**
```bash
mount -t proc /proc /mnt/proc
mount -t sysfs /sys /mnt/sys
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
```

**Chroot:**
```bash
chroot /mnt /bin/bash
```

**You're now inside the new system** (but not booted yet).

### Run Finalization Script

**Execute:**
```bash
/root/finalize-install.sh
```

**What it does:**
1. Generates locales
2. Sets timezone
3. Updates package lists
4. Installs essential utilities (vim, tmux, htop, etc.)
5. Rebuilds initramfs (critical for crypto)
6. Installs GRUB to ESP
7. Generates GRUB config
8. Enables OpenRC crypto services

**Watch for errors** - especially during:
- GRUB installation
- Initramfs rebuild
- Service configuration

### Verify Configuration

**Before exiting chroot:**

```bash
# Check fstab
cat /etc/fstab
# Should show all subvolumes

# Check crypttab
cat /etc/crypttab
# Should show both encrypted drives with keyfile

# Check GRUB config
cat /boot/grub/grub.cfg | grep -A5 "menuentry"
# Should show kernel with rootflags=subvol=@

# Check initramfs has crypto
lsinitramfs /boot/initrd.img-$(uname -r) | grep -i crypt
# Should show cryptsetup tools

# Check OpenRC services
rc-update show | grep crypt
# Should show:
# cryptdisks-early | sysinit
# cryptdisks | boot
```

### Exit Chroot

```bash
# Sync to disk
sync

# Exit chroot
exit
```

### Cleanup Before Reboot

**Unmount everything:**
```bash
umount -R /mnt
```

**Close crypto devices:**
```bash
cryptsetup close crypthome
cryptsetup close cryptroot
```

**Remove USB keyfile drive:**
- Keep it safe
- You'll need it for every boot
- Consider making a backup copy

**Sync and reboot:**
```bash
sync
reboot
```

---

## First Boot

### What Should Happen

**Boot sequence:**
1. **GRUB** loads, shows menu
2. Select Kali (usually auto-boots in 5 seconds)
3. **Kernel** loads from /boot
4. **Initramfs** starts
5. **Crypto unlock** via USB keyfile (automatic)
6. **Root mounts** from `/dev/mapper/cryptroot`
7. **OpenRC** takes over
8. **Services start** (cryptdisks, elogind, etc.)
9. **Remaining filesystems mount** from fstab
10. **TTY login prompt** appears

**Expected time:** 30-60 seconds from GRUB to login.

### Success Looks Like

**You see:**
```
Kali GNU/Linux Rolling laptop-81935 tty1

laptop-81935 login: _
```

**You can login:**
- Username: root (no user created yet)
- Password: (set during finalization, or still blank)

**After login:**
```bash
# Check init system
ps -p 1
# Should show: /sbin/init

# Check OpenRC
rc-status
# Should show services in default runlevel

# Check crypto
ls /dev/mapper/
# Should show: cryptroot crypthome

# Check mounts
mount | grep btrfs
# Should show all subvolumes

# Check network
ip addr
# Should show interfaces (may not have IPs yet)
```

**If you see all this:** Phase 1 succeeded! System is ready for Phase 2.

---

## Troubleshooting

### Boot Fails - Emergency Shell

**Symptoms:** System drops to emergency shell instead of login prompt.

**Common causes:**
1. Crypto didn't unlock
2. Mounts failed
3. Service dependency issue

**Debug steps:**

**Check crypto:**
```bash
ls /dev/mapper/
# Should show cryptroot and crypthome
# If missing, crypto unlock failed
```

**Check mounts:**
```bash
mount | grep mapper
# Should show all BTRFS subvolumes
# If missing, mount failed
```

**Try manual recovery:**
```bash
# If crypto missing, try manual unlock
cryptsetup open /dev/disk/by-partlabel/LUKS_ROOT cryptroot
# Enter passphrase

# If mounts missing, check fstab
cat /etc/fstab
# Verify paths and options

# Try manual mount
mount /dev/mapper/cryptroot /mnt
# If this works, fstab might be wrong
```

**If you can't recover in emergency shell:**
- Reboot to live USB
- Mount and chroot (see Post-Script section)
- Check and fix fstab, crypttab
- Rebuild initramfs
- Try again

### Crypto Unlock Fails

**Symptoms:** Prompted for passphrase, or boot hangs.

**Possible causes:**
1. USB keyfile drive not detected
2. USB timing issue
3. Keyfile path wrong
4. crypttab misconfigured

**Solutions:**

**Try passphrase:**
- If prompted, enter your LUKS passphrase
- This proves crypto works, just keyfile issue

**Boot to live USB and fix:**
```bash
# Mount and chroot
# Check crypttab
cat /etc/crypttab
# Verify:
# - Device paths correct
# - Keyfile path matches USB
# - keyscript option present

# Check GRUB has rootdelay
cat /etc/default/grub | grep CMDLINE
# Should have: rootdelay=10

# If not, add it:
echo 'GRUB_CMDLINE_LINUX="rootflags=subvol=@ rootdelay=10"' >> /etc/default/grub
update-grub

# Rebuild initramfs
update-initramfs -u -k all
```

### GRUB Not Found / No Bootloader

**Symptoms:** System tries to boot from wrong drive, or "No bootable device."

**Solution:**

**Boot to live USB:**
```bash
# Mount ESP
mount /dev/disk/by-partlabel/ESP /mnt

# Check if GRUB installed
ls /mnt/EFI/
# Should show kali directory

# If missing, chroot and reinstall GRUB
mount /dev/mapper/cryptroot /mnt  # mount root first
mount /dev/disk/by-partlabel/ESP /mnt/boot/efi
# mount proc/sys/dev as before
chroot /mnt /bin/bash

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=kali
update-grub
```

### Services Not Starting

**Symptoms:** Boot succeeds but services aren't running.

**Check:**
```bash
rc-status
# Shows what's supposed to be running

# Check specific service
rc-service elogind status

# Try starting manually
rc-service elogind start

# Check for errors
cat /var/log/rc.log
```

**See:** `docs/openrc-installation.md` troubleshooting section for service-specific debugging.

---

## Phase 1 Verification Checklist

**Before proceeding to Phase 2:**

- [ ] System boots without errors
- [ ] USB keyfile unlocks crypto automatically
- [ ] Both encrypted drives unlock (`/dev/mapper/cryptroot` and `crypthome`)
- [ ] All BTRFS subvolumes mount correctly
- [ ] TTY login works
- [ ] Can login as root
- [ ] `ps -p 1` shows `/sbin/init` not systemd
- [ ] `rc-status` shows OpenRC services
- [ ] Network interfaces present (`ip addr`)
- [ ] Logs show no critical errors (`dmesg`, `/var/log/rc.log`)

**If all checked:** Ready for Phase 2 (pre-boot customization in chroot).

---

## What Phase 1 Accomplished

**You now have:**
- Fully encrypted multi-drive system
- BTRFS with flat subvolume layout
- OpenRC managing services
- Working crypto unlock (USB keyfile + passphrase fallback)
- Bootable system at TTY
- Ready for customization

**You do NOT have yet:**
- Regular user account (still only root)
- Desktop environment
- Network configured
- Additional tools
- Shell customization

**Phase 2 handles:** User creation, XDG setup, tool installation, shell config - all before first real boot.

---

## Mistakes to Avoid

**From lessons learned:**

1. **Don't skip serial verification** - Wrong drive = data loss
2. **Don't ignore USB timing** - Add rootdelay to GRUB
3. **Don't skip LUKS header backups** - Script does this automatically
4. **Don't use USB 2.0 for keyfile** - Too slow, use USB 3.0
5. **Don't forget orphan-sysvinit-scripts** - OpenRC needs it
6. **Don't skip initramfs rebuild** - Crypto won't work
7. **Don't assume GRUB just works** - Verify and regenerate

**See:** `appendices/corrections-lessons-learned.md` for complete mistake catalog.

---

## Next Steps

**Phase 2:** Pre-boot customization in chroot
- XDG environment setup
- Tool installation
- User creation
- Shell configuration

**See:** `docs/Phase-2-Pre-Boot-Customization.md`

---

**Document Status:** Complete Phase 1 procedure  
**Script:** `scripts/phase1-automated-install.sh`  
**Tested:** Multi-drive encrypted BTRFS with OpenRC

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*
