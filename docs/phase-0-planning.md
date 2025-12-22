# Phase 0: Hardware Decisions and Planning

**Status:** Before any destructive operations  
**Environment:** Planning stage, documentation review  
**Goal:** Make all critical decisions and create configuration file for automation

---

## Philosophy: Plan Before Destroy

**The principle:**
> "Measure twice, cut once" applies to drives even more than wood.

**Phase 0 is about:**
- Understanding your hardware
- Making informed decisions
- Documenting choices
- Creating configuration ready for Phase 1 automation

**What you DON'T do in Phase 0:**
- Touch any drives
- Run any destructive commands
- Boot from live USB yet
- Start installation

**What you DO in Phase 0:**
- Identify hardware
- Choose encryption settings
- Plan partition layout
- Decide filesystem strategy
- Document everything

---

## Hardware Identification

### Identify Your Drives

**From your current system (or live USB):**
```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL,SERIAL
```

**Record:**
- Drive paths (`/dev/nvme0n1`, `/dev/sda`, etc.)
- Sizes
- Models
- **Serial numbers** (for verification in automation)

**Example output:**
```
NAME        SIZE TYPE MODEL              SERIAL
nvme0n1     1TB  disk Samsung 970 EVO   S5GXNX0T123456
├─nvme0n1p1 512M part
├─nvme0n1p2 1G   part
└─nvme0n1p3 998G part
sda         2TB  disk WD Blue SSD       20180123456789
└─sda1      2TB  part
```

### Get Serial Numbers

**For NVMe drives:**
```bash
nvme id-ctrl /dev/nvme0n1 | grep "^sn"
```

**For SATA/SSD drives:**
```bash
smartctl -i /dev/sda | grep "Serial Number"
```

**Why serial numbers matter:**
- Automation script verifies you're erasing correct drives
- Drive letters (`/dev/sda` vs `/dev/sdb`) can change
- Serial numbers don't change
- Prevents catastrophic "wrong drive" disasters

### Determine Drive Roles

**For this project's multi-drive setup:**

**Primary Drive (NVMe recommended):**
- EFI System Partition (ESP)
- Boot partition
- Root filesystem
- System subvolumes (`/opt`, `/srv`, `/usr/local`, `/var/log`, etc.)

**Secondary Drive (SATA SSD):**
- Home directory
- VM/container storage
- Large data subvolumes

**USB Drive:**
- LUKS keyfile storage
- LUKS header backups
- Recovery information

**Why this split:**
- NVMe speed for system/boot
- SATA capacity for data/VMs
- USB for crypto keys (removable security)

---

## Encryption Decisions

**See:** `docs/decision-encryption.md` (when created) for comprehensive encryption guide.

**For this project, we use:**

### LUKS2 Configuration

**Cipher:** `aes-xts-plain64`
- Industry standard
- Hardware acceleration on modern CPUs
- AES-NI support

**Key size:** `512` (bits)
- 256-bit effective security (XTS mode uses 2 keys)
- Excellent security/performance balance

**Hash:** `sha256`
- Fast, secure
- Hardware acceleration available

**PBKDF:** `argon2id`
- Memory-hard (resistant to GPU attacks)
- LUKS2 default
- Better than PBKDF2

**Iteration time:** `4000` (milliseconds)
- 4 seconds unlock time
- Balance between security and convenience
- Adjustable based on your patience

**Why these choices:**
- Modern, secure defaults
- Hardware acceleration where possible
- LUKS2 recommended configuration
- Tested and proven

**Alternative considerations:**
- Serpent cipher (slower, potentially more secure)
- Longer iteration times (more secure, slower unlock)
- Different PBKDF (argon2i vs argon2id)

**See LUKS2 documentation for details on alternatives.**

### Keyfile Strategy

**USB keyfile with passphrase fallback:**

**Primary unlock:** USB keyfile
- Passwordless boot when USB present
- Fast unlock
- Removable security (take USB when leaving laptop)

**Fallback:** Strong passphrase
- Works if USB lost/damaged
- Can unlock from recovery environment
- Backup access method

**Keyfile location:**
- USB drive labeled `KALI_KEYSTORE`
- Path: `/crypto_keyfile`
- 4096 bytes random data

**Passphrase requirements:**
- High entropy (diceware, random generation)
- Memorizable but strong
- Used during initial LUKS format
- Added to both encrypted drives

**Why this approach:**
- Convenience (USB) + Security (passphrase fallback)
- Can boot unattended with USB
- Can recover without USB
- Removable security layer

---

## Partition Layout Planning

### Boot Partitions (NVMe Drive)

**EFI System Partition (ESP):**
- Size: 512MB
- Format: FAT32
- Label: `ESP`
- Mount: `/boot/efi`
- Purpose: UEFI boot files

**Boot Partition:**
- Size: **10GB** (for future live ISO storage)
- Format: ext4
- Label: `BOOT`
- Mount: `/boot`
- Purpose: Kernel, initramfs, GRUB files

**Why 10GB boot:**
- Store Kali rescue ISO (4-5GB)
- Multiple kernel versions
- Initramfs snapshots
- GRUB configurations
- Future-proofing

**Original documentation had 1GB** - this was a mistake caught during corrections.

### Encrypted Partitions

**Root Partition (NVMe):**
- Size: Remaining space on NVMe
- Encryption: LUKS2
- Label: `LUKS_ROOT`
- Contains: BTRFS with system subvolumes

**Home Partition (SATA):**
- Size: Entire SATA drive
- Encryption: LUKS2
- Label: `LUKS_HOME`
- Contains: BTRFS with data subvolumes

**USB Keyfile Partition:**
- Size: Entire USB (4GB+ recommended)
- Format: FAT32
- Label: `KALI_KEYSTORE`
- Purpose: Keyfile and header backups

---

## Filesystem Strategy

**See:** `docs/decision-filesystem.md` (when created) for comprehensive filesystem comparison.

**For this project, we use BTRFS with flat subvolume layout.**

### Why BTRFS?

**Benefits:**
- Snapshots (system rollback, backup)
- Compression (zstd - save space, improve performance)
- Checksums (data integrity)
- Subvolumes (flexible organization)
- Copy-on-Write (CoW) for some uses
- Mainline kernel support

**Trade-offs:**
- More complex than ext4
- RAID5/6 still unstable (we don't use RAID)
- Requires understanding subvolumes

**Why not alternatives:**
- ext4: No snapshots, no compression, no CoW
- ZFS: Out-of-tree module, GPL licensing issues, designed for multi-drive pools
- XFS: No snapshots, no compression
- F2FS: Flash-optimized, less mature

### BTRFS Subvolume Layout

**Root drive subvolumes (NVMe):**
```
@                    → /              (CoW, compression)
@opt                 → /opt           (CoW, compression)
@srv                 → /srv           (CoW, compression)
@usr@local           → /usr/local     (CoW, compression)
@var@log             → /var/log       (CoW, compression)
@var@cache           → /var/cache     (nodatacow)
@var@tmp             → /var/tmp       (nodatacow)
```

**Home drive subvolumes (SATA):**
```
@home                         → /home                      (CoW, compression)
@var@lib@libvirt@images       → /var/lib/libvirt/images   (nodatacow)
@var@lib@containers           → /var/lib/containers       (nodatacow)
```

**Naming convention:**
- `@` for root
- `@name` for top-level directories
- `@parent@child` for nested paths (allows POSIX path mapping)

**CoW vs nodatacow:**
- **CoW + compression:** User data, system files (benefits from snapshots)
- **nodatacow:** VMs, containers, caches (performance over snapshotting)

### Mount Options Strategy

**For CoW subvolumes:**
```
defaults,noatime,compress=zstd:3,ssd,discard=async,subvol=@name
```

**For nodatacow subvolumes:**
```
defaults,noatime,nodatacow,ssd,discard=async,subvol=@name
```

**Option explanations:**
- `noatime`: Don't update access times (performance)
- `compress=zstd:3`: Compress with zstd level 3 (good balance)
- `ssd`: SSD-optimized operations
- `discard=async`: Async TRIM for SSDs
- `nodatacow`: Disable CoW (for VMs/containers)

---

## Init System Decision

**See:** `docs/decision-init-system.md` for complete comparison.

**Critical decision for this project:**

### For Multi-Drive Encrypted BTRFS: OpenRC Required

**Why:**
- systemd fails at mounting multiple encrypted BTRFS subvolumes
- systemd's dependency resolver can't handle cross-drive subvolumes
- OpenRC's sequential mounting works correctly

**If you have multi-drive encrypted setup:** Use OpenRC from bootstrap.

**If you have single-drive setup:** Either systemd or OpenRC works.

**Desktop environment impact:**
- GNOME requires systemd
- XFCE works with OpenRC (recommended)
- KDE works with OpenRC

**For this project:** Bootstrap with OpenRC from the start (cleaner than converting).

---

## System Configuration Decisions

### Hostname

**Choose a hostname:**
- Something memorable
- Not personally identifying if system compromised
- Examples: `laptop-81935`, `kali-work`, `pen-test-01`

### Locale and Timezone

**Locale:**
- `en_US.UTF-8` (standard US English)
- Or your preferred locale from `/usr/share/i18n/SUPPORTED`

**Timezone:**
- Your local timezone
- List available: `timedatectl list-timezones`
- Example: `America/Chicago`

### User Account

**Username:**
- Your daily-use account
- Not `root` (don't work as root)
- Standard naming conventions

**Password:**
- High entropy
- Stored in password manager
- Different from LUKS passphrase

---

## Network Planning

**Phase 0 decision:** What network management approach?

**Options:**
1. **NetworkManager** (GUI, easy)
2. **systemd-networkd** (not available with OpenRC)
3. **Manual `/etc/network/interfaces`** (traditional)

**For OpenRC + XFCE setup:**
- NetworkManager recommended
- Works with OpenRC
- GUI applet available
- Easy WiFi management

**Network configuration happens in Phase 5** - just decide which approach now.

---

## Desktop Environment Planning

**See:** `docs/decision-desktop-environment.md` (when created) for complete comparison.

**Phase 0 decision:** Which desktop environment?

**For OpenRC:**
- **XFCE** - Recommended, lightweight, professional
- **KDE** - More features, more complexity
- **Window managers** (i3, bspwm) - Minimal, requires configuration

**Not compatible with OpenRC:**
- GNOME (requires systemd)

**Desktop installation happens in Phase 4** - just decide which now.

---

## Package Selection Strategy

**Phase 0 decision:** Minimal bootstrap or include tools?

### Bootstrap Approach

**Minimal (Recommended):**
```
kali-archive-keyring
sysvinit-core
openrc
elogind
linux-image-amd64
firmware-linux
grub-efi-amd64
cryptsetup
cryptsetup-initramfs
btrfs-progs
```

**Add tools after first boot** in Phase 6.

**Why minimal:**
- Faster bootstrap
- Smaller initial install
- Add what you need when you need it
- Documented tool additions

### Tool Selection

**Happens in Phase 6:**
- `kali-linux-core` - Base Kali tools
- `kali-linux-headless` - CLI security tools
- `kali-tools-*` - Specific tool categories
- Individual packages as needed

**Phase 0:** Just note you'll decide this later.

---

## Creating the Configuration File

**All Phase 0 decisions go into variables for Phase 1 script.**

### Configuration Template

Create `install-config.sh`:

```bash
#!/bin/bash
# Kali Bootstrap Installation Configuration
# Edit all values before running Phase 1 script

#======================================
# HARDWARE CONFIGURATION
#======================================

# NVMe Drive (Root)
NVME_DRIVE="/dev/nvme0n1"
NVME_EXPECTED_SERIAL="S5GXNX0T123456"  # Get with: nvme id-ctrl /dev/nvme0n1 | grep "^sn"

# SATA Drive (Home/Data)
SATA_DRIVE="/dev/sda"
SATA_EXPECTED_SERIAL="20180123456789"  # Get with: smartctl -i /dev/sda | grep "Serial"

# USB Keyfile Drive
USB_DRIVE="/dev/sdb"  # CHECK CAREFULLY - this changes!

#======================================
# PARTITION SIZES
#======================================

EFI_SIZE="512M"
BOOT_SIZE="10G"  # Large enough for rescue ISO
# Root and Home use remaining space

#======================================
# ENCRYPTION SETTINGS
#======================================

LUKS_CIPHER="aes-xts-plain64"
LUKS_KEY_SIZE="512"
LUKS_HASH="sha256"
LUKS_PBKDF="argon2id"
LUKS_ITER_TIME="4000"  # milliseconds (4 seconds)

#======================================
# LABELS
#======================================

# BTRFS filesystem labels
BTRFS_LABEL_ROOT="KALI_ROOT"
BTRFS_LABEL_HOME="KALI_HOME"

# Partition labels
PARTLABEL_EFI="ESP"
PARTLABEL_BOOT="BOOT"
PARTLABEL_CRYPTROOT="LUKS_ROOT"
PARTLABEL_CRYPTHOME="LUKS_HOME"
PARTLABEL_USB="KALI_KEYSTORE"

# USB keyfile path (on mounted USB)
USB_KEYFILE_PATH="/crypto_keyfile"

#======================================
# SYSTEM CONFIGURATION
#======================================

HOSTNAME="laptop-81935"
TIMEZONE="America/Chicago"
LOCALE="en_US.UTF-8"

#======================================
# MIRROR
#======================================

KALI_MIRROR="http://http.kali.org/kali"

#======================================
# BOOTSTRAP MOUNT POINT
#======================================

CHROOT_TARGET="/mnt"
```

### Verification Checklist

**Before proceeding to Phase 1, verify:**

- [ ] Drive paths correct (`lsblk` output matches)
- [ ] Serial numbers verified (copied from actual commands)
- [ ] USB drive path noted (and understand it may change)
- [ ] Partition sizes appropriate for your drives
- [ ] Encryption settings chosen (or using defaults)
- [ ] Labels make sense (no conflicts with existing systems)
- [ ] Hostname chosen
- [ ] Timezone correct
- [ ] Locale appropriate

---

## Documentation References

**Read before Phase 1:**

1. **Init System Choice:** `docs/decision-init-system.md`
   - Why OpenRC for multi-drive encrypted
   - systemd vs OpenRC comparison

2. **OpenRC Installation:** `docs/openrc-installation.md`
   - What packages are needed
   - Service configuration
   - Troubleshooting

3. **Script Architecture:** `docs/Script-Architecture.md`
   - How automation works
   - Safety features
   - Recovery procedures

4. **Corrections:** `appendices/corrections-lessons-learned.md`
   - Mistakes others made
   - What to avoid
   - Lessons learned

**Optional deep dives:**
- Encryption comparison (when created)
- Filesystem comparison (when created)
- Desktop environment comparison (when created)

---

## Ready for Phase 1?

**You should have:**
- Configuration file created
- Hardware identified and verified
- Decisions documented
- Backups of any important data
- Kali Live USB ready
- At least 2-3 hours of uninterrupted time

**You should understand:**
- What Phase 1 will do (destroy data, partition, encrypt, bootstrap)
- Why decisions were made (not just copying config)
- How to recover if something fails (live USB, chroot)
- What working system looks like (TTY login, OpenRC services)

**If uncertain about anything:**
- Re-read relevant decision documents
- Test in VM first
- Ask questions (IRC, forums, etc.)
- Wait until you understand

**Never run destructive operations you don't understand.**

---

## Phase 0 Complete

**Deliverable:** Configuration file ready for Phase 1 automation.

**Next:** Phase 1 - Destructive operations to bootable system.

---

**Document Status:** Planning and decision phase complete  
**Next Phase:** Phase 1 - Automated installation

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*
