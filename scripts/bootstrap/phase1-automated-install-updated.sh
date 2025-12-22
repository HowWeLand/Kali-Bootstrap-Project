#!/bin/bash
# phase1-automated-install.sh
# Kali Bootstrap: Phase 1 - Destructive Operations to Bootable System
#
# WARNING: THIS SCRIPT DESTROYS DATA
# - Secure erases drives
# - Creates new partition tables
# - Formats filesystems
# 
# BEFORE RUNNING:
# 1. Boot Kali Live USB
# 2. Run `lsblk` to identify your drives
# 3. Edit the variables at the top of this script
# 4. Verify config files exist in CONFIG_DIR
# 5. Triple-check you have the right drives
#
# This script will prompt for:
# - LUKS passphrase (for backup recovery)
# - Confirmation before destructive operations
#
# It will NOT prompt for:
# - Drive paths (you set them as variables)
# - Partition sizes (you set them as variables)
# - Any other configuration (edit the variables)

set -euo pipefail  # Exit on error, undefined variables, pipe failures

#==============================================================================
# UTILITY FUNCTIONS
#==============================================================================

generate_hostname() {
    local prefix=${1:-laptop}
    local min=${2:-10000}
    local max=${3:-99999}
    local random_num=$(shuf -i ${min}-${max} -n 1)
    echo "${prefix}-${random_num}"
}

#==============================================================================
# CONFIGURATION VARIABLES - EDIT THESE BEFORE RUNNING
#==============================================================================

# Repository paths (edit if running outside repo context)
REPO_ROOT="$(dirname "$(readlink -f "$0")")/.."
CONFIG_DIR="${REPO_ROOT}/configs"
SCRIPT_DIR="${REPO_ROOT}/scripts/bootstrap"

# YOU MUST RUN `lsblk` FIRST AND SET THESE CORRECTLY
# Wrong values = destroyed wrong drive = data loss

# NVMe Drive (usually /dev/nvme0n1 or /dev/nvme1n1)
NVME_DRIVE="/edit/me/please"

# SATA SSD Drive (usually /dev/sda or /dev/sdb)
SATA_DRIVE="/dev/sda"

# USB Keyfile Drive (usually /dev/sdb or /dev/sdc - check lsblk!)
USB_DRIVE="/dev/sdb"
USB_KEYFILE_PATH="/keyfile"  # Path on USB drive after mounting

# Partition Sizes
# I use a larger /boot so I can put a custom live iso as a system restore measure on here
EFI_SIZE="512M"
BOOT_SIZE="10G"
# Root and Home use remaining space on their respective drives

# LUKS Encryption Settings
LUKS_CIPHER="aes-xts-plain64"
LUKS_KEY_SIZE="512"
LUKS_HASH="sha256"
LUKS_PBKDF="argon2id"
LUKS_ITER_TIME="4000"  # milliseconds (4 seconds)

# Partition Labels (for /dev/disk/by-partlabel/ references)
PARTLABEL_EFI="ESP"
PARTLABEL_BOOT="BOOT"
PARTLABEL_CRYPTROOT="cryptroot"
PARTLABEL_CRYPTHOME="crypthome"
PARTLABEL_USB="KALI_KEYSTORE"

# Crypt device mapper names (keep consistent with crypttab)
CRYPT_ROOT_NAME="cryptroot"
CRYPT_HOME_NAME="crypthome"

# System Configuration
# Uncomment to generate random hostname:
# HOSTNAME=$(generate_hostname "laptop")
# Or generate with custom prefix/range:
# HOSTNAME=$(generate_hostname "kali" 10000 99999)

# Default: set your own hostname here
HOSTNAME="laptop-81935"

TIMEZONE="America/Chicago"  # List: timedatectl list-timezones
LOCALE="en_US.UTF-8"        # List: cat /usr/share/i18n/SUPPORTED

# Kali Mirror
KALI_MIRROR="http://http.kali.org/kali"

# Bootstrap Mount Point
CHROOT_TARGET="/mnt"

# Config files (must exist in CONFIG_DIR)
FSTAB_CONFIG="fstab"
CRYPTTAB_CONFIG="crypttab"

#==============================================================================
# COLOR OUTPUT AND LOGGING
#==============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

die() {
    log_error "$1"
    exit 1
}

#==============================================================================
# SAFETY CHECKS
#==============================================================================

require_root() {
    if [[ $EUID -ne 0 ]]; then
        die "This script must be run as root (use sudo)"
    fi
}

require_live_environment() {
    # Check if we're running from live environment (not installed system)
    if [[ ! -f /etc/debian_version ]] || [[ -d /target ]]; then
        log_warning "Cannot definitively confirm live environment"
        read -p "Are you SURE you're running from Kali Live USB? (yes/no): " confirm
        if [[ "$confirm" != "yes" ]]; then
            die "Aborted - run from Kali Live USB only"
        fi
    fi
}

verify_drive_exists() {
    local drive=$1
    if [[ ! -b "$drive" ]]; then
        die "Drive $drive does not exist. Run lsblk and update variables."
    fi
}

verify_config_files() {
    log_info "Verifying config files exist..."
    
    if [[ ! -f "$CONFIG_DIR/$FSTAB_CONFIG" ]]; then
        die "Missing config file: $CONFIG_DIR/$FSTAB_CONFIG"
    fi
    
    if [[ ! -f "$CONFIG_DIR/$CRYPTTAB_CONFIG" ]]; then
        die "Missing config file: $CONFIG_DIR/$CRYPTTAB_CONFIG"
    fi
    
    log_success "Config files found"
}

confirm_drives_unmounted() {
    log_info "Checking if target drives are mounted..."
    
    if mount | grep -q "$NVME_DRIVE"; then
        die "$NVME_DRIVE has mounted partitions. Unmount first."
    fi
    
    if mount | grep -q "$SATA_DRIVE"; then
        die "$SATA_DRIVE has mounted partitions. Unmount first."
    fi
    
    log_success "Target drives are not mounted"
}

interactive_confirmation() {
    echo ""
    echo "=========================================="
    echo "  FINAL CONFIRMATION BEFORE DESTRUCTION"
    echo "=========================================="
    echo ""
    echo "This will PERMANENTLY DESTROY ALL DATA on:"
    echo ""
    lsblk -o NAME,SIZE,MODEL,SERIAL "$NVME_DRIVE" "$SATA_DRIVE"
    echo ""
    echo "Target drives:"
    echo "  NVMe Root: $NVME_DRIVE"
    echo "  SATA Home: $SATA_DRIVE"
    echo "  USB Key:   $USB_DRIVE"
    echo ""
    echo "New system will be:"
    echo "  Hostname: $HOSTNAME"
    echo "  Timezone: $TIMEZONE"
    echo "  Init:     OpenRC"
    echo ""
    
    log_warning "Proceeding with destructive operations in 5 seconds..."
    log_warning "Press Ctrl+C NOW to abort!"
    sleep 5
}

#==============================================================================
# SECURE ERASE FUNCTIONS
#==============================================================================

secure_erase_nvme() {
    local drive=$1
    
    log_info "Checking NVMe secure erase capability..."
    
    if ! nvme id-ctrl -H "$drive" | grep -q "Format.*Supported"; then
        die "NVMe drive $drive does not support secure erase"
    fi
    
    log_info "Starting NVMe secure erase on $drive..."
    log_warning "This will take 1-2 minutes and cannot be interrupted"
    
    # Use cryptographic erase if supported, otherwise user data erase
    if nvme id-ctrl -H "$drive" | grep -q "Crypto Erase"; then
        log_info "Using cryptographic erase (instant)"
        nvme format "$drive" --ses=2 || die "NVMe cryptographic erase failed"
    else
        log_info "Using user data erase (slower)"
        nvme format "$drive" --ses=1 || die "NVMe user data erase failed"
    fi
    
    log_success "NVMe secure erase completed"
    
    # Verify drive is clean
    if lsblk "$drive" | grep -q "part"; then
        die "Drive $drive still shows partitions after erase"
    fi
}

unfreeze_sata_drive() {
    local drive=$1
    
    log_info "Checking if SATA drive is frozen..."
    
    if hdparm -I "$drive" 2>/dev/null | grep -q "frozen"; then
        log_warning "Drive is frozen, attempting to unfreeze via suspend..."
        log_info "System will suspend for 5 seconds"
        
        # Suspend/resume unfreezes the drive on most hardware
        rtcwake -m mem -s 5 2>/dev/null || {
            log_error "Suspend failed. Try manually: echo -n mem > /sys/power/state"
            read -p "Press Enter after waking system..." 
        }
        
        sleep 2
        
        if hdparm -I "$drive" 2>/dev/null | grep -q "frozen"; then
            die "Failed to unfreeze drive. Manual intervention required."
        fi
        
        log_success "Drive unfrozen"
    else
        log_success "Drive is not frozen"
    fi
}

secure_erase_sata() {
    local drive=$1
    local temp_password="SecureEraseTemp$(date +%s)"
    
    unfreeze_sata_drive "$drive"
    
    log_info "Starting SATA SSD secure erase on $drive..."
    log_warning "This will take 1-2 minutes"
    
    # Check if sanitize is supported (newer drives)
    if smartctl -g security "$drive" 2>/dev/null | grep -q "Sanitize.*Supported"; then
        log_info "Using sanitize command (cryptographic if supported)"
        smartctl -t sanitize,cryptographic "$drive" 2>/dev/null || \
        smartctl -t sanitize,overwrite "$drive" || \
        die "SATA sanitize failed"
        
        # Wait for sanitize to complete
        log_info "Waiting for sanitize to complete..."
        while smartctl -l devstat "$drive" 2>/dev/null | grep -q "in progress"; do
            sleep 10
        done
    else
        # Fall back to ATA Secure Erase
        log_info "Using ATA Secure Erase"
        
        # Set temporary password
        hdparm --user-master u --security-set-pass "$temp_password" "$drive" || \
            die "Failed to set security password"
        
        # Execute secure erase
        hdparm --user-master u --security-erase "$temp_password" "$drive" || \
            die "ATA Secure Erase failed"
    fi
    
    log_success "SATA secure erase completed"
    
    # Verify security is disabled
    if ! hdparm -I "$drive" 2>/dev/null | grep -q "not.*enabled"; then
        log_warning "Security may still be enabled. Check manually."
    fi
}

prepare_usb_keyfile() {
    local drive=$1
    
    log_info "Preparing USB keyfile drive $drive..."
    
    # Simple wipe and format for USB drive (not storing sensitive data)
    wipefs -a "${drive}1" 2>/dev/null || true
    
    # Create partition if needed
    if ! lsblk "$drive" | grep -q "part"; then
        log_info "Creating partition on USB drive..."
        parted -s "$drive" mklabel gpt
        parted -s "$drive" mkpart primary fat32 1MiB 100%
        parted -s "$drive" name 1 "$PARTLABEL_USB"
    fi
    
    # Format as FAT32
    mkfs.vfat -F 32 -n "$PARTLABEL_USB" "${drive}1" || die "Failed to format USB drive"
    
    # Mount and create keyfile
    mkdir -p /mnt/usb
    mount "${drive}1" /mnt/usb || die "Failed to mount USB drive"
    
    log_info "Generating random keyfile..."
    dd if=/dev/urandom of="/mnt/usb${USB_KEYFILE_PATH}" bs=4096 count=1 || \
        die "Failed to create keyfile"
    
    chmod 600 "/mnt/usb${USB_KEYFILE_PATH}"
    
    umount /mnt/usb
    
    log_success "USB keyfile drive prepared"
}

#==============================================================================
# PARTITIONING
#==============================================================================

create_nvme_partitions() {
    local drive=$1
    
    log_info "Creating partition table on $drive..."
    
    parted -s "$drive" mklabel gpt
    parted -s "$drive" mkpart primary fat32 1MiB "$EFI_SIZE"
    parted -s "$drive" mkpart primary ext4 "$EFI_SIZE" "$((${EFI_SIZE%M} + ${BOOT_SIZE%G} * 1024))MiB"
    parted -s "$drive" mkpart primary btrfs "$((${EFI_SIZE%M} + ${BOOT_SIZE%G} * 1024))MiB" 100%
    
    parted -s "$drive" name 1 "$PARTLABEL_EFI"
    parted -s "$drive" name 2 "$PARTLABEL_BOOT"
    parted -s "$drive" name 3 "$PARTLABEL_CRYPTROOT"
    
    parted -s "$drive" set 1 esp on
    
    log_success "NVMe partitions created"
}

create_sata_partitions() {
    local drive=$1
    
    log_info "Creating partition table on $drive..."
    
    parted -s "$drive" mklabel gpt
    parted -s "$drive" mkpart primary btrfs 1MiB 100%
    parted -s "$drive" name 1 "$PARTLABEL_CRYPTHOME"
    
    log_success "SATA partitions created"
}

#==============================================================================
# FILESYSTEM CREATION
#==============================================================================

format_boot_partitions() {
    log_info "Formatting boot partitions..."
    
    mkfs.vfat -F 32 -n "$PARTLABEL_EFI" "/dev/disk/by-partlabel/$PARTLABEL_EFI" || \
        die "Failed to format EFI partition"
    
    mkfs.ext4 -L "$PARTLABEL_BOOT" "/dev/disk/by-partlabel/$PARTLABEL_BOOT" || \
        die "Failed to format boot partition"
    
    log_success "Boot partitions formatted"
}

setup_luks_encryption() {
    log_info "Setting up LUKS encryption..."
    
    # Mount USB for keyfile
    mkdir -p /mnt/usb
    mount "/dev/disk/by-label/$PARTLABEL_USB" /mnt/usb || die "Failed to mount USB keyfile"
    
    # Encrypt root partition
    log_info "Encrypting root partition..."
    cryptsetup luksFormat \
        --type luks2 \
        --cipher "$LUKS_CIPHER" \
        --key-size "$LUKS_KEY_SIZE" \
        --hash "$LUKS_HASH" \
        --pbkdf "$LUKS_PBKDF" \
        --iter-time "$LUKS_ITER_TIME" \
        --key-file "/mnt/usb${USB_KEYFILE_PATH}" \
        "/dev/disk/by-partlabel/$PARTLABEL_CRYPTROOT" || \
        die "Failed to encrypt root partition"
    
    # Encrypt home partition
    log_info "Encrypting home partition..."
    cryptsetup luksFormat \
        --type luks2 \
        --cipher "$LUKS_CIPHER" \
        --key-size "$LUKS_KEY_SIZE" \
        --hash "$LUKS_HASH" \
        --pbkdf "$LUKS_PBKDF" \
        --iter-time "$LUKS_ITER_TIME" \
        --key-file "/mnt/usb${USB_KEYFILE_PATH}" \
        "/dev/disk/by-partlabel/$PARTLABEL_CRYPTHOME" || \
        die "Failed to encrypt home partition"
    
    # Add passphrase as backup (user will be prompted)
    log_info "Adding backup passphrase to root partition..."
    cryptsetup luksAddKey \
        --key-file "/mnt/usb${USB_KEYFILE_PATH}" \
        "/dev/disk/by-partlabel/$PARTLABEL_CRYPTROOT" || \
        log_warning "Failed to add backup passphrase to root"
    
    log_info "Adding backup passphrase to home partition..."
    cryptsetup luksAddKey \
        --key-file "/mnt/usb${USB_KEYFILE_PATH}" \
        "/dev/disk/by-partlabel/$PARTLABEL_CRYPTHOME" || \
        log_warning "Failed to add backup passphrase to home"
    
    # Open encrypted partitions
    log_info "Opening encrypted partitions..."
    cryptsetup open \
        --key-file "/mnt/usb${USB_KEYFILE_PATH}" \
        "/dev/disk/by-partlabel/$PARTLABEL_CRYPTROOT" \
        "$CRYPT_ROOT_NAME" || \
        die "Failed to open root partition"
    
    cryptsetup open \
        --key-file "/mnt/usb${USB_KEYFILE_PATH}" \
        "/dev/disk/by-partlabel/$PARTLABEL_CRYPTHOME" \
        "$CRYPT_HOME_NAME" || \
        die "Failed to open home partition"
    
    umount /mnt/usb
    
    log_success "LUKS encryption configured"
}

create_btrfs_filesystems() {
    log_info "Creating BTRFS filesystems..."
    
    # No labels - reference by /dev/mapper/cryptroot
    mkfs.btrfs -f "/dev/mapper/$CRYPT_ROOT_NAME" || die "Failed to create root filesystem"
    mkfs.btrfs -f "/dev/mapper/$CRYPT_HOME_NAME" || die "Failed to create home filesystem"
    
    log_success "BTRFS filesystems created"
}

create_btrfs_subvolumes() {
    log_info "Creating BTRFS subvolumes..."
    
    # Mount root
    mount "/dev/mapper/$CRYPT_ROOT_NAME" /mnt || die "Failed to mount root"
    
    # Create root subvolumes
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@opt
    btrfs subvolume create /mnt/@srv
    btrfs subvolume create /mnt/@usr@local
    btrfs subvolume create /mnt/@var@log
    btrfs subvolume create /mnt/@var@cache
    btrfs subvolume create /mnt/@var@tmp
    
    umount /mnt
    
    # Mount home
    mount "/dev/mapper/$CRYPT_HOME_NAME" /mnt || die "Failed to mount home"
    
    # Create home subvolumes
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@var@lib@libvirt@images
    btrfs subvolume create /mnt/@var@lib@containers
    
    umount /mnt
    
    log_success "BTRFS subvolumes created"
}

#==============================================================================
# MOUNTING FOR BOOTSTRAP
#==============================================================================

mount_for_bootstrap() {
    log_info "Mounting filesystems for bootstrap..."
    
    # Mount root subvolume
    mount -o defaults,noatime,compress=zstd:3,ssd,discard=async,subvol=@ \
        "/dev/mapper/$CRYPT_ROOT_NAME" "$CHROOT_TARGET" || \
        die "Failed to mount root"
    
    # Create mount points
    mkdir -p "$CHROOT_TARGET"/{boot,boot/efi,home,opt,srv,usr/local,var/{log,cache,tmp,lib/{libvirt/images,containers}}}
    
    # Mount boot partitions
    mount "/dev/disk/by-partlabel/$PARTLABEL_BOOT" "$CHROOT_TARGET/boot" || \
        die "Failed to mount boot"
    mount "/dev/disk/by-partlabel/$PARTLABEL_EFI" "$CHROOT_TARGET/boot/efi" || \
        die "Failed to mount EFI"
    
    # Mount root subvolumes
    mount -o defaults,noatime,compress=zstd:3,ssd,discard=async,subvol=@opt \
        "/dev/mapper/$CRYPT_ROOT_NAME" "$CHROOT_TARGET/opt"
    mount -o defaults,noatime,compress=zstd:3,ssd,discard=async,subvol=@srv \
        "/dev/mapper/$CRYPT_ROOT_NAME" "$CHROOT_TARGET/srv"
    mount -o defaults,noatime,compress=zstd:3,ssd,discard=async,subvol=@usr@local \
        "/dev/mapper/$CRYPT_ROOT_NAME" "$CHROOT_TARGET/usr/local"
    mount -o defaults,noatime,compress=zstd:3,ssd,discard=async,subvol=@var@log \
        "/dev/mapper/$CRYPT_ROOT_NAME" "$CHROOT_TARGET/var/log"
    mount -o defaults,noatime,nodatacow,ssd,discard=async,subvol=@var@cache \
        "/dev/mapper/$CRYPT_ROOT_NAME" "$CHROOT_TARGET/var/cache"
    mount -o defaults,noatime,nodatacow,ssd,discard=async,subvol=@var@tmp \
        "/dev/mapper/$CRYPT_ROOT_NAME" "$CHROOT_TARGET/var/tmp"
    
    # Mount home subvolumes
    mount -o defaults,noatime,compress=zstd:3,subvol=@home \
        "/dev/mapper/$CRYPT_HOME_NAME" "$CHROOT_TARGET/home"
    mount -o defaults,noatime,nodatacow,subvol=@var@lib@libvirt@images \
        "/dev/mapper/$CRYPT_HOME_NAME" "$CHROOT_TARGET/var/lib/libvirt/images"
    mount -o defaults,noatime,nodatacow,subvol=@var@lib@containers \
        "/dev/mapper/$CRYPT_HOME_NAME" "$CHROOT_TARGET/var/lib/containers"
    
    log_success "Filesystems mounted"
}

#==============================================================================
# BOOTSTRAP
#==============================================================================

run_bootstrap() {
    log_info "Running debootstrap..."
    log_warning "This will take 5-10 minutes..."
    
    debootstrap \
        --variant=minbase \
        --include=openrc,sysvinit-core,cryptsetup,btrfs-progs,grub-efi-amd64 \
        --arch=amd64 \
        kali-rolling \
        "$CHROOT_TARGET" \
        "$KALI_MIRROR" || \
        die "Bootstrap failed"
    
    log_success "Bootstrap completed"
}

#==============================================================================
# CHROOT CONFIGURATION
#==============================================================================

configure_fstab() {
    log_info "Installing fstab from config..."
    
    cp "$CONFIG_DIR/$FSTAB_CONFIG" "$CHROOT_TARGET/etc/fstab" || \
        die "Failed to copy fstab"
    
    log_success "/etc/fstab installed"
}

configure_crypttab() {
    log_info "Installing crypttab from config..."
    
    cp "$CONFIG_DIR/$CRYPTTAB_CONFIG" "$CHROOT_TARGET/etc/crypttab" || \
        die "Failed to copy crypttab"
    
    log_success "/etc/crypttab installed"
}

configure_basic_system() {
    log_info "Configuring basic system settings..."
    
    # Hostname
    echo "$HOSTNAME" > "$CHROOT_TARGET/etc/hostname"
    
    # Hosts file
    cat > "$CHROOT_TARGET/etc/hosts" << EOF
127.0.0.1   localhost
127.0.1.1   $HOSTNAME
::1         localhost ip6-localhost ip6-loopback
EOF
    
    # Locale
    echo "$LOCALE UTF-8" >> "$CHROOT_TARGET/etc/locale.gen"
    
    # Timezone (will be applied in chroot)
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" "$CHROOT_TARGET/etc/localtime"
    
    log_success "Basic system settings configured"
}

#==============================================================================
# GRUB CONFIGURATION
#==============================================================================

configure_grub() {
    log_info "Preparing for GRUB installation (will complete in chroot)..."
    
    # Create GRUB config (chroot will finalize)
    cat > "$CHROOT_TARGET/etc/default/grub" << 'EOF'
# GRUB Configuration

GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Kali"

# Kernel parameters
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="rootflags=subvol=@ rootdelay=10"

# Display
GRUB_GFXMODE=1920x1080
GRUB_GFXPAYLOAD_LINUX=keep

# Enable cryptodisk for encrypted /boot (if needed in future)
GRUB_ENABLE_CRYPTODISK=n
EOF
    
    log_success "GRUB config prepared"
}

#==============================================================================
# CHROOT SCRIPT GENERATION
#==============================================================================

generate_chroot_script() {
    log_info "Generating chroot finalization script..."
    
    cat > "$CHROOT_TARGET/root/finalize-install.sh" << 'CHROOT_EOF'
#!/bin/bash
# finalize-install.sh - Run inside chroot to complete installation

set -euo pipefail

echo "[INFO] Generating locales..."
locale-gen

echo "[INFO] Setting timezone..."
dpkg-reconfigure -f noninteractive tzdata

echo "[INFO] Updating package lists..."
apt update

echo "[INFO] Installing essential packages..."
apt install -y \
    vim \
    tmux \
    htop \
    ncdu \
    aptitude \
    lnav \
    zsh \
    git \
    curl \
    wget

echo "[INFO] Rebuilding initramfs..."
update-initramfs -u -k all

echo "[INFO] Installing GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=kali --recheck

echo "[INFO] Generating GRUB config..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "[INFO] Configuring OpenRC..."
rc-update add cryptdisks boot
rc-update add elogind boot

echo "[SUCCESS] Chroot finalization complete"
echo ""
echo "Next steps:"
echo "1. Exit chroot"
echo "2. Unmount all filesystems"
echo "3. Close encrypted volumes"
echo "4. Remove USB keyfile drive"
echo "5. Reboot"
echo "6. Boot should proceed to TTY login"
CHROOT_EOF
    
    chmod +x "$CHROOT_TARGET/root/finalize-install.sh"
    
    log_success "Chroot finalization script created"
}

#==============================================================================
# MAIN EXECUTION
#==============================================================================

main() {
    echo "=========================================="
    echo "  Kali Bootstrap - Phase 1 Automation"
    echo "=========================================="
    echo ""
    
    # Safety checks
    require_root
    require_live_environment
    verify_config_files
    
    # Verify hardware
    log_info "Verifying hardware configuration..."
    verify_drive_exists "$NVME_DRIVE"
    verify_drive_exists "$SATA_DRIVE"
    verify_drive_exists "$USB_DRIVE"
    confirm_drives_unmounted
    
    # Final confirmation
    interactive_confirmation
    
    # Secure erase
    log_info "=== Phase 1.1: Secure Erase ==="
    secure_erase_nvme "$NVME_DRIVE"
    secure_erase_sata "$SATA_DRIVE"
    prepare_usb_keyfile "$USB_DRIVE"
    
    # Partitioning
    log_info "=== Phase 1.2: Partitioning ==="
    create_nvme_partitions "$NVME_DRIVE"
    create_sata_partitions "$SATA_DRIVE"
    
    # Wait for kernel to recognize new partitions
    sleep 2
    partprobe "$NVME_DRIVE" "$SATA_DRIVE"
    sleep 2
    
    # Filesystem creation
    log_info "=== Phase 1.3: Filesystems ==="
    format_boot_partitions
    setup_luks_encryption
    create_btrfs_filesystems
    create_btrfs_subvolumes
    
    # Mount
    log_info "=== Phase 1.4: Mounting ==="
    mount_for_bootstrap
    
    # Bootstrap
    log_info "=== Phase 1.5: Bootstrap ==="
    run_bootstrap
    
    # Configuration
    log_info "=== Phase 1.6: Configuration ==="
    configure_fstab
    configure_crypttab
    configure_basic_system
    configure_grub
    generate_chroot_script
    
    # Done
    echo ""
    echo "=========================================="
    log_success "Phase 1 automation complete!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Chroot into system:"
    echo "   arch-chroot $CHROOT_TARGET /bin/bash"
    echo ""
    echo "2. Run finalization script:"
    echo "   /root/finalize-install.sh"
    echo ""
    echo "3. Exit chroot and reboot"
    echo ""
}

# Run main function
main "$@"
