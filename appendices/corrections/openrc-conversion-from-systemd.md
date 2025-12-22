# OpenRC Conversion from systemd

**Purpose:** Convert an existing systemd-based Kali installation to OpenRC.

**⚠️ WARNING:** This is an advanced procedure. Have backups and be prepared to boot from live USB to recover if something goes wrong.

---

## When to Use This

**Convert to OpenRC if:**
- Hit systemd mount ordering failures
- Want explicit service dependencies
- Need custom runlevels
- Prefer simpler init system

**DON'T convert if:**
- You need GNOME desktop
- System is working fine
- You're not comfortable with chroot recovery
- You don't have backups

**Recommended instead:** Bootstrap with OpenRC from the start (see `openrc-installation.md`)

---

## Prerequisites

### Before You Start

**Required:**
- Kali Live USB (for chroot if needed)
- Full system backup
- USB keyfile drive (if using encrypted drives)
- At least 2 hours of time
- Comfort with chroot operations

**Verify current system:**
```bash
# Check you're running systemd
ps -p 1
# Should show: /lib/systemd/systemd

# Check what's running
systemctl list-units --type=service --state=running
# Note any critical services

# Backup current fstab and crypttab
cp /etc/fstab /etc/fstab.systemd-backup
cp /etc/crypttab /etc/crypttab.systemd-backup
```

---

## Conversion Procedure

### Step 1: Boot from Live USB

**Why:** Safer to do conversion when not running the system being modified.

1. Boot Kali Live USB
2. Connect to network (if needed for package downloads)
3. Open terminal

### Step 2: Mount and Chroot

**Unlock encrypted drives:**
```bash
# If using encrypted drives
cryptsetup open /dev/disk/by-partlabel/LUKS_ROOT cryptroot
cryptsetup open /dev/disk/by-partlabel/LUKS_HOME crypthome
```

**Mount filesystems:**
```bash
# Mount root
mount -o subvol=@ /dev/mapper/cryptroot /mnt

# Mount boot partitions
mount /dev/disk/by-partlabel/BOOT /mnt/boot
mount /dev/disk/by-partlabel/ESP /mnt/boot/efi

# Mount other subvolumes
mount -o subvol=@home /dev/mapper/crypthome /mnt/home
mount -o subvol=@opt /dev/mapper/cryptroot /mnt/opt
mount -o subvol=@srv /dev/mapper/cryptroot /mnt/srv
mount -o subvol=@usr@local /dev/mapper/cryptroot /mnt/usr/local
mount -o subvol=@var@log /dev/mapper/cryptroot /mnt/var/log
mount -o subvol=@var@cache /dev/mapper/cryptroot /mnt/var/cache
mount -o subvol=@var@tmp /dev/mapper/cryptroot /mnt/var/tmp
# ... (all your subvolumes)

# Verify all mounted
mount | grep /mnt
```

**Prepare chroot:**
```bash
mount -t proc /proc /mnt/proc
mount -t sysfs /sys /mnt/sys
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
```

**Enter chroot:**
```bash
chroot /mnt /bin/bash
```

### Step 3: Download Required Packages

**Download packages before removing systemd:**
```bash
# Update package lists
apt update

# Download OpenRC packages (don't install yet)
cd /tmp
apt download \
    sysvinit-core \
    openrc \
    elogind \
    initscripts \
    orphan-sysvinit-scripts \
    systemd-standalone-sysusers
```

**Why download first:**
- systemd removal might break apt temporarily
- Having .deb files ready ensures we can proceed

### Step 4: Force Install systemd-standalone-sysusers

**The chicken-and-egg problem:**
- systemd provides `systemd-sysusers`
- sysvinit-core needs sysusers functionality
- Can't install sysvinit-core while systemd installed
- Can't remove systemd without replacement

**Solution:** Force install standalone sysusers first:

```bash
dpkg -i --force-conflicts /tmp/systemd-standalone-sysusers*.deb
```

**What --force-conflicts does:**
- Allows file conflicts between packages
- systemd-standalone-sysusers conflicts with systemd
- We force it anyway
- This creates a hybrid state temporarily

### Step 5: Remove systemd

**Now we can remove systemd:**
```bash
apt remove --purge systemd systemd-sysv systemd-cryptsetup
```

**What gets removed:**
- systemd (init system)
- systemd-sysv (sysv compatibility)
- systemd-cryptsetup (crypto hooks we'll replace)

**Warnings you'll see:**
- Many packages want systemd
- apt will suggest alternatives
- This is expected

**If apt refuses:**
```bash
# Force removal
dpkg --remove --force-remove-reinstreq systemd systemd-sysv
```

### Step 6: Install OpenRC

**Install sysvinit and OpenRC:**
```bash
dpkg -i /tmp/sysvinit-core*.deb
dpkg -i /tmp/openrc*.deb
dpkg -i /tmp/elogind*.deb
dpkg -i /tmp/initscripts*.deb
dpkg -i /tmp/orphan-sysvinit-scripts*.deb
```

**Or if dpkg approach is problematic:**
```bash
apt install sysvinit-core openrc elogind initscripts orphan-sysvinit-scripts
```

**Fix any dependency issues:**
```bash
apt --fix-broken install
```

### Step 7: Configure OpenRC Services

**Enable crypto services:**
```bash
rc-update add cryptdisks-early sysinit
rc-update add cryptdisks boot
```

**Enable basic services:**
```bash
rc-update add elogind boot
rc-update add networking default
rc-update add dbus default
```

**Check what's enabled:**
```bash
rc-update show
```

**Should show:**
```
cryptdisks-early | sysinit
cryptdisks | boot
elogind | boot
networking | default
dbus | default
```

### Step 8: Verify Configuration Files

**Check /etc/crypttab:**
```bash
cat /etc/crypttab
```

**Should have:**
```
cryptroot /dev/disk/by-partlabel/LUKS_ROOT /dev/disk/by-label/KALI_KEYSTORE:/crypto_keyfile luks,keyscript=/lib/cryptsetup/scripts/passdev,initramfs
crypthome /dev/disk/by-partlabel/LUKS_HOME /dev/disk/by-label/KALI_KEYSTORE:/crypto_keyfile luks,keyscript=/lib/cryptsetup/scripts/passdev,initramfs
```

**Check /etc/fstab:**
```bash
cat /etc/fstab
```

**Ensure all mounts are present** - OpenRC uses fstab directly.

### Step 9: Rebuild Initramfs

**Critical step - rebuilds boot image with OpenRC:**
```bash
update-initramfs -u -k all
```

**What this does:**
- Removes systemd hooks
- Adds OpenRC crypto scripts
- Includes cryptsetup tools
- Configures keyfile access

**Verify initramfs:**
```bash
lsinitramfs /boot/initrd.img-$(uname -r) | grep -i crypt
# Should show cryptsetup and OpenRC crypto scripts
```

### Step 10: Regenerate GRUB Configuration

**Update GRUB to work with OpenRC:**
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

**Check GRUB config:**
```bash
grep -A5 "menuentry" /boot/grub/grub.cfg
```

**Should see:**
- `linux` line with kernel
- `initrd` line with initramfs
- `rootflags=subvol=@` if using BTRFS subvolumes

### Step 11: Exit and Reboot

**Exit chroot:**
```bash
sync
exit
```

**Unmount everything:**
```bash
umount -R /mnt
```

**Close crypto devices:**
```bash
cryptsetup close crypthome
cryptsetup close cryptroot
```

**Remove USB, reboot:**
```bash
sync
reboot
```

---

## First Boot Verification

### Boot Sequence

**What should happen:**
1. GRUB loads
2. Kernel boots
3. Initramfs runs
4. Crypto devices unlock (from USB keyfile)
5. Root mounts
6. OpenRC takes over
7. Services start
8. TTY login appears

**If it fails:** Boot from live USB, chroot again, check logs.

### Check OpenRC is Running

**Login and verify:**
```bash
# Check PID 1
ps -p 1
# Should show: /sbin/init (NOT systemd)

# Check OpenRC
rc-status
# Should show services in current runlevel

# Check what's running
ps aux | grep -v grep | grep -E "(openrc|elogind)"
```

### Check Services

**Verify crypto worked:**
```bash
ls /dev/mapper/
# Should show: cryptroot, crypthome

mount | grep btrfs
# Should show all subvolumes
```

**Verify network:**
```bash
ip addr
# Should show network interfaces

ping -c 3 kali.org
# Should work
```

**Check logs:**
```bash
cat /var/log/rc.log
# OpenRC service log

dmesg | less
# Kernel boot messages

cat /var/log/syslog
# System log
```

---

## Common Issues and Fixes

### Issue: System Boots to Emergency Shell

**Cause:** Crypto unlock failed or mounts failed

**Fix:**
1. Boot live USB
2. Chroot into system
3. Check crypttab and fstab
4. Rebuild initramfs
5. Try again

**Debug in emergency shell:**
```bash
# Check what failed
rc-status

# Try starting services manually
rc-service cryptdisks-early start
rc-service cryptdisks start
rc-service localmount start
```

### Issue: "No init found"

**Cause:** Bootloader looking for systemd

**Fix:**
```bash
# In chroot
update-grub
# Or manually edit /boot/grub/grub.cfg
# Ensure it's loading kernel and initramfs correctly
```

### Issue: Services Not Starting

**Cause:** Dependencies not met

**Fix:**
```bash
# Check what service needs
rc-service <service> describe

# Start dependencies manually
rc-service <dependency> start

# Then start service
rc-service <service> start
```

### Issue: Cryptsetup Not in Initramfs

**Cause:** Missing cryptsetup-initramfs package

**Fix:**
```bash
# In chroot
apt install cryptsetup-initramfs
update-initramfs -u -k all
```

### Issue: Keyfile Not Found

**Cause:** USB timing or path issue

**Fix:**
```bash
# Add rootdelay to GRUB
# Edit /etc/default/grub
GRUB_CMDLINE_LINUX="rootflags=subvol=@ rootdelay=10"

# Update GRUB
update-grub
```

### Issue: Network Not Working

**Cause:** Network service not enabled

**Fix:**
```bash
# Check network service
rc-status | grep net

# Enable and start
rc-update add networking default
rc-service networking start

# Or for NetworkManager
rc-update add NetworkManager default
rc-service NetworkManager start
```

---

## Rolling Back to systemd

**If conversion fails and you need to revert:**

### Emergency Rollback

**Boot live USB, chroot:**
```bash
# Mount and chroot (same as conversion procedure)

# Remove OpenRC
apt remove --purge openrc sysvinit-core

# Reinstall systemd
apt install systemd systemd-sysv

# Rebuild initramfs
update-initramfs -u -k all

# Update GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Exit, unmount, reboot
```

### Clean Reinstall

**If rollback doesn't work:**
- Boot live USB
- Back up /home and important data
- Reinstall Kali with systemd
- Restore data

---

## Post-Conversion Tasks

### Install Cron

**OpenRC doesn't include scheduling:**
```bash
apt install cron anacron
rc-update add cron default
rc-service cron start
```

### Configure Desktop

**XFCE works perfectly:**
```bash
apt install kali-desktop-xfce
rc-update add elogind boot
rc-update add dbus default
```

**Display manager:**
```bash
apt install lightdm
rc-update add lightdm default
```

### Create Custom Runlevels

**Example: Lab mode for malware analysis:**
```bash
mkdir /etc/runlevels/lab
cp /etc/runlevels/default/* /etc/runlevels/lab/
rc-update del networking lab

# Switch to lab mode
rc lab
```

---

## Verification Checklist

**After successful conversion:**

- [ ] System boots to TTY login
- [ ] `ps -p 1` shows /sbin/init not systemd
- [ ] `rc-status` shows services
- [ ] Crypto devices unlocked (`ls /dev/mapper/`)
- [ ] All filesystems mounted (`mount | grep btrfs`)
- [ ] Network working (`ping kali.org`)
- [ ] Can login as user
- [ ] Services start correctly (`rc-status`)

---

## Why This Procedure Works

### The Critical Package: systemd-standalone-sysusers

**The problem it solves:**

systemd provides system user/group creation through `systemd-sysusers`. Many packages depend on this functionality. When removing systemd, you need to replace this function.

**systemd-standalone-sysusers:**
- Provides same functionality as systemd-sysusers
- Works without systemd
- Allows sysvinit-core installation
- Breaks the circular dependency

**Why force-install:**
- Conflicts with systemd (provides same files)
- Need it before removing systemd
- Creates temporary hybrid state
- Resolved when systemd removed

### The Critical Package: orphan-sysvinit-scripts

**What it provides:**
- Service files for essential services
- Crypto service scripts (cryptdisks, cryptdisks-early)
- Network configuration scripts
- System initialization scripts

**Without it:**
- Services missing from runlevels
- Boot process incomplete
- Crypto may not unlock
- System may not fully start

**This was discovered through iteration** - initial conversions failed without this package.

---

## Lessons Learned

**From successful conversion:**

1. **Download packages first** - Before breaking systemd
2. **Force-install sysusers** - Breaks the circular dependency
3. **orphan-sysvinit-scripts is critical** - Missing services otherwise
4. **Rebuild initramfs thoroughly** - All kernels, verify contents
5. **GRUB config matters** - Regenerate, don't assume
6. **Test in chroot** - Before rebooting

**What didn't work:**
- Trying to install OpenRC while systemd running
- Removing systemd without sysusers replacement
- Missing orphan-sysvinit-scripts package
- Not rebuilding initramfs
- Assuming GRUB would "just work"

---

## Resources

**OpenRC Documentation:**
- Gentoo OpenRC Guide: https://wiki.gentoo.org/wiki/OpenRC
- OpenRC GitLab: https://gitlab.com/openrc/openrc

**Debian/Kali Specific:**
- orphan-sysvinit-scripts: `/usr/share/doc/orphan-sysvinit-scripts/`
- initscripts: `/usr/share/doc/initscripts/`

**Recovery:**
- Kali Live USB: https://www.kali.org/get-kali/
- Chroot guide: Kali documentation

---

**Document Status:** Complete conversion procedure  
**Based on:** Successful systemd → OpenRC conversion on multi-drive encrypted system

**Last tested:** December 2025 on Kali Rolling with multi-drive LUKS2 + BTRFS

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*
