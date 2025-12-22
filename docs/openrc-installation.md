# OpenRC Installation and Configuration

**Purpose:** Complete guide to installing and configuring OpenRC on Kali Linux, including bootstrap installation and crypto configuration.

---

## Table of Contents

1. [Bootstrap with OpenRC (Recommended)](#bootstrap-with-openrc-recommended)
2. [OpenRC Service Management](#openrc-service-management)
3. [Configuring Crypto (cryptdisks)](#configuring-crypto-cryptdisks)
4. [Service Dependencies](#service-dependencies)
5. [Creating Custom Runlevels](#creating-custom-runlevels)
6. [Troubleshooting](#troubleshooting)

---

## Bootstrap with OpenRC (Recommended)

**This is the cleanest approach** - install OpenRC from the start rather than converting from systemd later.

### Prerequisites

- Booted from Kali Live USB
- Partitions created and encrypted (see Phase 1)
- Filesystems created and mounted at `/mnt`

### Bootstrap Command

```bash
debootstrap --variant=minbase \
  --include=kali-archive-keyring,sysvinit-core,openrc,elogind,initscripts,orphan-sysvinit-scripts,linux-image-amd64,firmware-linux,grub-efi-amd64,efibootmgr,cryptsetup,cryptsetup-initramfs,btrfs-progs \
  --arch=amd64 \
  kali-rolling \
  /mnt \
  http://http.kali.org/kali
```

### Package Breakdown

**Init system:**
- `sysvinit-core` - PID 1 init binary
- `openrc` - Service manager
- `elogind` - Session management (systemd-logind replacement)
- `initscripts` - Basic init scripts
- `orphan-sysvinit-scripts` - Additional sysvinit compatibility scripts

**System essentials:**
- `kali-archive-keyring` - GPG keys for Kali repos
- `linux-image-amd64` - Kernel
- `firmware-linux` - Hardware firmware

**Boot:**
- `grub-efi-amd64` - Bootloader
- `efibootmgr` - EFI boot management

**Encryption:**
- `cryptsetup` - LUKS tools
- `cryptsetup-initramfs` - Early crypto unlock

**Filesystem:**
- `btrfs-progs` - BTRFS tools

### Why This Package List?

**The critical combination:**
```
sysvinit-core + openrc + elogind + orphan-sysvinit-scripts
```

**Without `orphan-sysvinit-scripts`:**
- Missing service files for essential services
- Crypto services may not be available
- Boot process incomplete

**This was discovered through iteration** - initial bootstrap attempts without `orphan-sysvinit-scripts` failed to boot properly.

### Post-Bootstrap Steps

**Mount proc/sys/dev for chroot:**
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

**Inside chroot, complete basic configuration:**
```bash
# Set hostname
echo "laptop-81935" > /etc/hostname

# Configure /etc/hosts
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
127.1.1.1   laptop-81935
::1         localhost ip6-localhost ip6-loopback
EOF

# Generate locales
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

# Set timezone
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
```

---

## OpenRC Service Management

### Basic Commands

**View system status:**
```bash
rc-status                # Current runlevel and running services
rc-status -a             # All runlevels and services
rc-status boot           # Services in boot runlevel
```

**Manage services:**
```bash
rc-service <service> start
rc-service <service> stop
rc-service <service> restart
rc-service <service> status
```

**Add/remove services from runlevels:**
```bash
rc-update add <service> <runlevel>
rc-update del <service> <runlevel>
rc-update show           # Show all services and runlevels
rc-update show -v        # Verbose: show details
```

### Standard Runlevels

**Default runlevels:**
- `sysinit` - System initialization (automatic)
- `boot` - Boot-time services
- `default` - Normal operation
- `shutdown` - Clean shutdown

**Special runlevels:**
- `single` - Single-user mode
- `nonetwork` - No network services

### Runlevel Transitions

**Switch between runlevels:**
```bash
rc <runlevel>            # Switch to specified runlevel
rc default               # Switch to default runlevel
rc boot                  # Re-enter boot runlevel
```

**What happens during transition:**
1. Services not in target runlevel are stopped
2. Dependencies are resolved
3. Services in target runlevel are started
4. System is now in new state

---

## Configuring Crypto (cryptdisks)

### The Crypto Services

OpenRC provides two crypto services:

**`cryptdisks-early`:**
- Runs in `sysinit` runlevel
- Unlocks devices needed before mounting filesystems
- Typically root volume

**`cryptdisks`:**
- Runs in `boot` runlevel
- Unlocks additional devices
- Typically home, data volumes

### Configuration Files

**`/etc/crypttab`** - Defines encrypted volumes:
```
# <target> <source device> <key file> <options>
cryptroot /dev/disk/by-partlabel/LUKS_ROOT /dev/disk/by-label/KALI_KEYSTORE:/crypto_keyfile luks,keyscript=/lib/cryptsetup/scripts/passdev,initramfs
crypthome /dev/disk/by-partlabel/LUKS_HOME /dev/disk/by-label/KALI_KEYSTORE:/crypto_keyfile luks,keyscript=/lib/cryptsetup/scripts/passdev,initramfs
```

**Key components:**
- `target` - Name for decrypted device (`/dev/mapper/cryptroot`)
- `source device` - Encrypted partition (use labels or UUIDs)
- `key file` - USB keyfile location
- `options` - Encryption options

### Crypttab Options Explained

**`luks`:**
- Device is LUKS-encrypted
- Use cryptsetup to unlock

**`keyscript=/lib/cryptsetup/scripts/passdev`:**
- Use external device for keyfile
- Format: `device:path` (e.g., `/dev/disk/by-label/KEYSTORE:/keyfile`)

**`initramfs`:**
- Include this device in initramfs
- Enables early boot unlocking

**`keyfile-timeout=30`:** (optional)
- Wait up to 30 seconds for keyfile device
- Falls back to passphrase if timeout

### Testing Crypto Configuration

**Before rebooting, test in chroot:**

```bash
# Check crypttab syntax
cat /etc/crypttab

# Verify keyfile is accessible
mount /dev/disk/by-label/KALI_KEYSTORE /mnt
ls -l /mnt/crypto_keyfile
umount /mnt

# Test manual unlock (with passphrase)
cryptsetup open --test-passphrase /dev/disk/by-partlabel/LUKS_ROOT
# Enter passphrase - should succeed
```

### Crypto Service Status

**Check if crypto services are enabled:**
```bash
rc-update show | grep crypt
# Should show:
# cryptdisks-early | sysinit
# cryptdisks | boot
```

**If not enabled:**
```bash
rc-update add cryptdisks-early sysinit
rc-update add cryptdisks boot
```

### Initramfs Integration

**Rebuild initramfs to include crypto:**
```bash
update-initramfs -u -k all
```

**What this does:**
- Includes cryptsetup tools in initramfs
- Adds keyfile from USB (if mounted during rebuild)
- Configures early boot crypto unlock
- Sets up fallback to passphrase

**Verify initramfs contains crypto:**
```bash
lsinitramfs /boot/initrd.img-$(uname -r) | grep -i crypt
# Should show cryptsetup tools and scripts
```

---

## Service Dependencies

### Understanding depend()

OpenRC service files use `depend()` function to declare dependencies.

**Basic service file structure:**
```bash
#!/sbin/openrc-run

description="Example Service"

depend() {
    need <service>       # Required, fail without
    use <service>        # Use if available, don't fail
    before <service>     # Start before this service
    after <service>      # Start after this service
    provide <virtual>    # Provide a virtual service
}

start() {
    ebegin "Starting example service"
    start-stop-daemon --start --exec /usr/bin/example
    eend $?
}

stop() {
    ebegin "Stopping example service"
    start-stop-daemon --stop --exec /usr/bin/example
    eend $?
}
```

### Dependency Keywords

**`need`** - Hard requirement:
```bash
depend() {
    need net
}
# Service WILL NOT START if net is not running
# If net fails, this service stops
```

**`use`** - Soft dependency:
```bash
depend() {
    use dns
}
# Service will use dns if available
# But starts anyway if dns not running
```

**`after`** - Ordering:
```bash
depend() {
    after firewall
}
# Ensure firewall starts first
# But don't fail if firewall missing
```

**`before`** - Reverse ordering:
```bash
depend() {
    before nginx
}
# Ensure this starts before nginx
```

**`provide`** - Virtual services:
```bash
depend() {
    provide net
}
# This service provides "net" functionality
# Other services can "need net" and get this
```

### Example: Crypto Service Dependencies

**`/etc/init.d/cryptdisks-early`:**
```bash
depend() {
    before localmount
    after dev
}
```

**Meaning:**
- Start after device nodes available
- Start before mounting local filesystems
- Run in `sysinit` runlevel (very early)

**`/etc/init.d/cryptdisks`:**
```bash
depend() {
    after cryptdisks-early
    before localmount
}
```

**Meaning:**
- Start after early crypto unlock
- Still before mounting filesystems
- Run in `boot` runlevel

### Viewing Dependency Trees

**See what a service depends on:**
```bash
rc-service <service> describe
```

**Check dependency conflicts:**
```bash
rc-depend -t <service>    # Tree view
rc-depend -a              # All dependencies
```

---

## Creating Custom Runlevels

### Why Custom Runlevels?

**Use cases:**
- **lab** - Malware analysis, network isolated
- **demo** - Presentation mode, display optimized
- **forensics** - Minimal services, evidence preservation
- **pentesting** - Network tools only, GUI disabled

### Creating a Custom Runlevel

**Example: Create "lab" runlevel for malware analysis**

```bash
# Create the runlevel directory
mkdir /etc/runlevels/lab

# Copy services from default as starting point
cp -r /etc/runlevels/default/* /etc/runlevels/lab/

# Remove network from lab mode
rc-update del networking lab
rc-update del NetworkManager lab

# Add strict firewall
rc-update add netfilter lab

# Add VM/container services
rc-update add libvirtd lab
rc-update add containerd lab
```

**Switch to lab mode:**
```bash
rc lab
```

**What happens:**
1. Services in `default` but not `lab` stop (networking)
2. Services in `lab` but not `default` start (if any)
3. System is now in isolated lab state

**Return to normal:**
```bash
rc default
```

### Runlevel Configuration File

**`/etc/rc.conf`** - Global OpenRC configuration:

```bash
# Enable parallel service startup
rc_parallel="YES"

# Log service output
rc_logger="YES"

# Timeout for service start
rc_timeout_stopsec="90"

# Interactive boot (ask before each service)
rc_interactive="NO"
```

### Boot to Specific Runlevel

**Set default runlevel:**
```bash
# Edit /etc/inittab
id:3:initdefault:   # Default runlevel 3 (if using numbered runlevels)

# Or for OpenRC named runlevels:
# Set RC_DEFAULT_LEVEL in /etc/rc.conf
RC_DEFAULT_LEVEL="default"
```

**Boot to specific runlevel once:**
```bash
# Add to GRUB kernel line:
softlevel=lab
```

---

## Troubleshooting

### Boot Issues

**System boots to emergency shell:**

1. **Check crypto unlock:**
   ```bash
   # Are crypto devices open?
   ls /dev/mapper/
   # Should show: cryptroot, crypthome
   ```

2. **Check mounts:**
   ```bash
   mount | grep /dev/mapper
   # Should show your BTRFS subvolumes
   ```

3. **Check service failures:**
   ```bash
   rc-status
   # Shows which services failed
   
   rc-service <failed-service> start
   # Try starting manually to see error
   ```

**Crypto devices not unlocking:**

1. **Check USB keyfile device:**
   ```bash
   lsblk
   # Is KALI_KEYSTORE visible?
   
   mount /dev/disk/by-label/KALI_KEYSTORE /mnt
   ls /mnt/crypto_keyfile
   # Is keyfile present?
   ```

2. **Check crypttab:**
   ```bash
   cat /etc/crypttab
   # Verify device paths
   # Check keyfile path matches
   ```

3. **Try manual unlock:**
   ```bash
   cryptsetup open /dev/disk/by-partlabel/LUKS_ROOT cryptroot
   # Enter passphrase to test
   ```

**Filesystems not mounting:**

1. **Check fstab:**
   ```bash
   cat /etc/fstab
   # Verify device paths
   # Check mount options
   ```

2. **Mount manually:**
   ```bash
   mount /dev/mapper/cryptroot /mnt
   # Does it work?
   ```

3. **Check BTRFS:**
   ```bash
   btrfs subvolume list /dev/mapper/cryptroot
   # Are subvolumes present?
   ```

### Service Issues

**Service won't start:**

1. **Check dependencies:**
   ```bash
   rc-service <service> describe
   # What does it need?
   
   rc-status
   # Are dependencies running?
   ```

2. **Check service file:**
   ```bash
   cat /etc/init.d/<service>
   # Read the depend() function
   # What's required?
   ```

3. **Start dependencies first:**
   ```bash
   rc-service <dependency> start
   rc-service <service> start
   ```

**Service fails with "No such file or directory":**

- **Check if binary exists:**
  ```bash
  which <service-binary>
  ```

- **Check if service file is executable:**
  ```bash
  chmod +x /etc/init.d/<service>
  ```

### Networking Issues

**Network not coming up:**

1. **Check network service:**
   ```bash
   rc-status | grep net
   # Is networking in current runlevel?
   
   rc-update add networking default
   rc-service networking start
   ```

2. **For NetworkManager:**
   ```bash
   rc-update add NetworkManager default
   rc-service NetworkManager start
   ```

3. **Check interfaces:**
   ```bash
   ip link
   # Are interfaces visible?
   
   ip addr
   # Do they have IPs?
   ```

### Rebuilding Initramfs

**If crypto or boot issues persist:**

```bash
# Chroot from live USB
mount /dev/mapper/cryptroot /mnt
mount /dev/disk/by-partlabel/BOOT /mnt/boot
mount /dev/disk/by-partlabel/ESP /mnt/boot/efi

mount -t proc /proc /mnt/proc
mount -t sysfs /sys /mnt/sys
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts

chroot /mnt /bin/bash

# Rebuild initramfs
update-initramfs -u -k all

# Regenerate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg

# Exit and reboot
exit
umount -R /mnt
reboot
```

### Logs

**Check OpenRC logs:**
```bash
cat /var/log/rc.log
# Service start/stop events

dmesg
# Kernel messages (device detection, crypto)

cat /var/log/syslog
# System messages
```

---

## Verification Checklist

**After installation, verify:**

```bash
# 1. Check init system
ps -p 1
# Should show: /sbin/init (not systemd)

# 2. Check OpenRC
rc-status
# Should show services in current runlevel

# 3. Check crypto services
rc-update show | grep crypt
# Should show cryptdisks in boot/sysinit

# 4. Check elogind (session manager)
rc-status | grep elogind
# Should be running

# 5. Check mounts
mount | grep btrfs
# Should show all subvolumes

# 6. Check runlevels
ls /etc/runlevels/
# Should show: boot, default, shutdown, etc.
```

---

## Next Steps

**After OpenRC is working:**

1. **Install cron for scheduling:**
   ```bash
   apt install cron anacron
   rc-update add cron default
   ```

2. **Install desktop environment:**
   - XFCE recommended (see Phase 4)
   - KDE compatible
   - Avoid GNOME (requires systemd)

3. **Configure network:**
   - NetworkManager for GUI
   - Or manual /etc/network/interfaces

4. **Create custom runlevels:**
   - Lab mode for malware analysis
   - Demo mode for presentations

---

## Resources

**OpenRC Documentation:**
- Gentoo Wiki: https://wiki.gentoo.org/wiki/OpenRC
- OpenRC GitLab: https://gitlab.com/openrc/openrc
- Gentoo OpenRC User Guide: https://wiki.gentoo.org/wiki/OpenRC/User_Guide

**Service File Examples:**
- Gentoo ebuilds: https://gitweb.gentoo.org/repo/gentoo.git/tree/
- Look for `files/` directories with initd scripts

**Debian/Kali OpenRC:**
- orphan-sysvinit-scripts package documentation
- /etc/init.d/ service files
- /usr/share/doc/openrc/

---

**Document Status:** Complete installation and configuration guide  
**Based on:** Successful multi-drive encrypted Kali installation with OpenRC

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*
