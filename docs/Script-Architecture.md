# Script Architecture Documentation

## Overview

This project includes automation scripts for repeatable, tested Kali Linux installation from bare metal through bootable system. Scripts follow strict safety principles and extensive error handling.

---

## Design Principles

### 1. User Edits Variables, Not Prompted

**Philosophy:** Force users to open and read the script.

**Instead of:**
```bash
read -p "Enter NVMe drive path: " NVME_DRIVE
```

**We do:**
```bash
# YOU MUST RUN `lsblk` FIRST AND SET THESE CORRECTLY
NVME_DRIVE="/dev/nvme0n1"
NVME_EXPECTED_SERIAL="S5GXNX0T123456"
```

**Why:**
- User must read script before running
- Sees all configuration in one place
- Can review choices before execution
- No chance of typo during interactive prompt
- Serial number verification prevents wrong-drive disasters

**Exception:** Passwords are prompted interactively (can't be stored in script).

### 2. Separation of Concerns

**Each script does ONE thing:**

```
00-hardware-identification.sh   # ONLY identifies hardware
01-secure-erase.sh              # ONLY erases drives
02-partition.sh                 # ONLY creates partitions
...
```

**OR: Master script with clearly separated functions:**

```bash
# phase1-automated-install.sh
secure_erase_nvme() { ... }      # One responsibility
create_nvme_partitions() { ... } # One responsibility
setup_luks_encryption() { ... }  # One responsibility
```

**Benefits:**
- Easy to test individual components
- Can skip steps if already done
- Clear error isolation
- Readable code flow

### 3. Extensive Safety Checks

**NEVER trust user input or environment state.**

**Every destructive operation requires:**

1. **Drive existence check**
   ```bash
   verify_drive_exists() {
       if [[ ! -b "$drive" ]]; then
           die "Drive $drive does not exist"
       fi
   }
   ```

2. **Serial number verification**
   ```bash
   verify_drive_serial "$NVME_DRIVE" "$NVME_EXPECTED_SERIAL"
   # Fails if serial doesn't match
   ```

3. **Unmount verification**
   ```bash
   if mount | grep -q "$drive"; then
       die "Drive has mounted partitions"
   fi
   ```

4. **Interactive confirmation**
   ```bash
   read -p "Type 'DESTROY ALL DATA' to continue: " confirm
   if [[ "$confirm" != "DESTROY ALL DATA" ]]; then
       die "Aborted"
   fi
   ```

5. **Final countdown**
   ```bash
   log_warning "Proceeding in 5 seconds..."
   log_warning "Press Ctrl+C NOW to abort!"
   sleep 5
   ```

### 4. Fail Fast, Fail Loud

**Script settings:**
```bash
set -euo pipefail
```

**What this means:**
- `-e`: Exit immediately on any error
- `-u`: Treat undefined variables as errors
- `-o pipefail`: Pipe failures propagate

**Combined with `die()` function:**
```bash
die() {
    log_error "$1"
    exit 1
}

# Usage:
command || die "Command failed"
```

**Result:** Script stops at first error, doesn't continue damaging system.

### 5. Idempotency Where Possible

**Some operations can be repeated safely:**

```bash
# Partitioning: wipe first, then partition
wipefs -a "$drive" 2>/dev/null || true  # Succeeds even if already clean
parted -s "$drive" mklabel gpt          # Creates GPT even if exists

# Directory creation
mkdir -p /path/to/dir  # -p = no error if exists

# Mounting
mount /dev/sda1 /mnt || {
    if mount | grep -q "/mnt"; then
        log_info "Already mounted"
    else
        die "Mount failed"
    fi
}
```

**Destructive operations are NOT idempotent:**
- Secure erase (can only run once per power cycle on some drives)
- LUKS formatting (destroys existing encryption)
- Bootstrap (can't re-run over existing system)

**Document which operations are safe to re-run.**

### 6. Verbose Logging

**Every action logs:**

```bash
log_info "Starting operation..."
command || die "Operation failed"
log_success "Operation completed"
```

**Color-coded output:**
- Blue: Info (what's happening)
- Green: Success (what completed)
- Yellow: Warning (pay attention)
- Red: Error (critical failure)

**Logging functions are simple:**
```bash
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}
```

### 7. Configuration Over Magic Numbers

**Bad:**
```bash
parted -s /dev/nvme0n1 mkpart primary fat32 1MiB 512MiB
```

**Good:**
```bash
EFI_SIZE="512M"  # Set at top of script
parted -s "$NVME_DRIVE" mkpart primary fat32 1MiB "$EFI_SIZE"
```

**All magic numbers become named variables at script top.**

### 8. Document Hardware Quirks

**Different hardware needs different approaches:**

```bash
unfreeze_sata_drive() {
    # Some laptops need suspend/resume to unfreeze
    # Others need BIOS settings change
    # Document what works for YOUR hardware
    
    if hdparm -I "$drive" | grep -q "frozen"; then
        log_warning "Drive frozen. Attempting suspend..."
        rtcwake -m mem -s 5 || {
            log_error "Suspend failed."
            log_error "Try manually: echo -n mem > /sys/power/state"
            read -p "Press Enter after waking..." 
        }
    fi
}
```

**Comment explains:** What we're doing, why, and what to try if it fails.

---

## Script Structure

### Master Script Approach

**One script to rule them all:**

```bash
#!/bin/bash
# phase1-automated-install.sh

# 1. Configuration variables (user edits these)
NVME_DRIVE="/dev/nvme0n1"
...

# 2. Helper functions (colors, logging, safety)
log_info() { ... }
die() { ... }

# 3. Safety check functions
require_root() { ... }
verify_drive_serial() { ... }

# 4. Operational functions (grouped by phase)
secure_erase_nvme() { ... }
create_partitions() { ... }
setup_encryption() { ... }

# 5. Main execution
main() {
    # Run safety checks
    # Confirm with user
    # Execute operations in order
    # Handle errors
}

# 6. Execute
main "$@"
```

**Benefits:**
- Single file to review
- Clear execution flow
- Easy to comment out sections for testing
- All configuration in one place

**Drawbacks:**
- Long file
- Can't easily skip individual steps

### Modular Script Approach

**Alternative: One script per major operation:**

```
scripts/
├── lib/
│   ├── common.sh           # Shared functions
│   ├── logging.sh          # Log functions
│   └── safety.sh           # Safety checks
├── 00-identify-hardware.sh
├── 01-secure-erase.sh
├── 02-partition.sh
├── 03-encrypt.sh
├── 04-filesystem.sh
├── 05-mount.sh
├── 06-bootstrap.sh
├── 07-configure.sh
├── 08-bootloader.sh
└── 99-verify.sh
```

**Each script:**
- Sources `lib/common.sh`
- Checks prerequisites
- Does one thing
- Exits with status code

**Master runner:**
```bash
#!/bin/bash
# run-all.sh

for script in scripts/[0-9][0-9]-*.sh; do
    echo "Running $script..."
    bash "$script" || {
        echo "Script $script failed!"
        exit 1
    }
done
```

**Benefits:**
- Easy to run individual steps
- Clear separation
- Smaller files, easier to maintain

**Drawbacks:**
- More files to manage
- Configuration must be shared (env vars or config file)
- Harder to see full flow at once

**Current choice:** Master script (phase1-automated-install.sh) for Phase 1.

---

## Variable Naming Conventions

**All caps for configuration:**
```bash
NVME_DRIVE="/dev/nvme0n1"
LUKS_CIPHER="aes-xts-plain64"
HOSTNAME="laptop-81935"
```

**Lowercase for function-local variables:**
```bash
secure_erase_nvme() {
    local drive=$1
    local serial=$(nvme id-ctrl "$drive" | awk ...)
}
```

**Why:** Easy to see at a glance: THIS_IS_CONFIG vs this_is_local

---

## Error Handling Patterns

### Pattern 1: Die on Failure

```bash
command || die "Command failed"
```

**Use when:** Failure is unrecoverable.

### Pattern 2: Conditional Continuation

```bash
if ! command; then
    log_warning "Command failed, trying alternative..."
    alternative_command || die "Alternative also failed"
fi
```

**Use when:** Multiple approaches exist.

### Pattern 3: Optional Operations

```bash
command || {
    log_warning "Command failed, continuing anyway"
    # Operation was optional
}

# Or:
command 2>/dev/null || true  # Suppress errors, don't fail script
```

**Use when:** Command is nice-to-have, not required.

### Pattern 4: Retry Logic

```bash
for i in {1..3}; do
    if command; then
        break
    fi
    log_warning "Attempt $i failed, retrying..."
    sleep 2
done

# Verify it eventually worked
if ! verify_operation; then
    die "Operation failed after 3 retries"
fi
```

**Use when:** Operation might fail due to timing/hardware delays.

---

## Testing Strategy

### Level 1: Syntax Check

```bash
bash -n script.sh  # Parse but don't execute
shellcheck script.sh  # Linting
```

**Catches:** Syntax errors, common mistakes, bad practices.

### Level 2: Dry Run Mode

```bash
# Add to script:
DRY_RUN=false  # Set at top

# Wrap destructive commands:
if [[ "$DRY_RUN" == "true" ]]; then
    log_info "[DRY-RUN] Would execute: command"
else
    command || die "Command failed"
fi

# Usage:
bash script.sh  # Normal execution
DRY_RUN=true bash script.sh  # Dry run
```

**Catches:** Logic errors, missing checks, bad ordering.

### Level 3: VM Testing

```bash
# QEMU VM with virtual drives
qemu-system-x86_64 \
    -enable-kvm \
    -m 4G \
    -drive file=vdisk1.img,format=raw \
    -drive file=vdisk2.img,format=raw \
    -cdrom kali-live.iso \
    -boot d
```

**Catches:** Everything except hardware-specific quirks.

**Benefits:**
- Fast iterations
- No risk to real hardware
- Can snapshot VM state
- Can test repeatedly

### Level 4: Real Hardware

**The final test:**
- Run script on actual target hardware
- Verify each step
- Document any hardware-specific issues
- Update script with quirks

---

## Hardware-Specific Considerations

### NVMe Drives

**Secure Erase:**
```bash
nvme format /dev/nvme0n1 --ses=1  # User data erase
nvme format /dev/nvme0n1 --ses=2  # Cryptographic erase (if supported)
```

**Check capabilities first:**
```bash
nvme id-ctrl /dev/nvme0n1 | grep -i "Format"
nvme id-ctrl /dev/nvme0n1 | grep -i "Crypto"
```

**Quirks:**
- Some NVMe drives require power cycle after format
- Some don't support cryptographic erase
- Some have slow format operations (2-5 minutes)

### SATA SSDs

**Frozen State:**
- Many laptops "freeze" SATA drives at boot
- Must suspend/resume or power cycle to unfreeze
- `hdparm -I /dev/sda | grep frozen` to check

**Secure Erase Methods:**
1. **ATA Secure Erase** (older drives):
   ```bash
   hdparm --security-set-pass temp /dev/sda
   hdparm --security-erase temp /dev/sda
   ```

2. **Sanitize** (newer drives):
   ```bash
   smartctl -t sanitize,cryptographic /dev/sda
   # or
   smartctl -t sanitize,overwrite /dev/sda
   ```

**Quirks:**
- Freeze status varies by laptop model
- Some BIOSes have security settings that affect this
- Some drives don't support sanitize

### USB Drives

**Simple format is fine:**
```bash
wipefs -a /dev/sdb1  # Remove signatures
mkfs.vfat -F 32 -n LABEL /dev/sdb1  # FAT32 format
```

**Quirks:**
- USB enumeration takes time (add delays)
- Device name can change (`/dev/sdb` vs `/dev/sdc`)
- Serial number checking doesn't work reliably

---

## Recovery Procedures

### Script Fails Mid-Execution

**What to do:**

1. **Don't panic**
   - Most failures are before destructive operations
   - If after secure erase, drives are clean (not bricked)

2. **Check error message**
   - Scripts die with descriptive messages
   - Read the log output

3. **Verify state**
   ```bash
   lsblk  # What's currently partitioned?
   cryptsetup status cryptroot  # What's open?
   mount | grep /mnt  # What's mounted?
   ```

4. **Clean up if needed**
   ```bash
   umount -R /mnt  # Unmount everything under /mnt
   cryptsetup close crypthome cryptroot  # Close LUKS
   ```

5. **Fix issue and re-run**
   - Fix script error
   - Or run from failed step manually

### Partial Bootstrap

**If bootstrap fails partway:**

```bash
# Clean up mount point
umount -R /mnt
rm -rf /mnt/*

# Re-run bootstrap
debootstrap ...
```

**Bootstrap is safe to re-run** if target directory is empty.

### Wrong Drive Selected

**If you realize BEFORE running:**
- Edit variables in script
- Run again

**If you realize AFTER secure erase:**
- That drive's data is gone
- Restore from backup (you have backups, right?)
- Update script variables
- Run again on correct drive

**Prevention:** Serial number verification catches this.

---

## Documentation Requirements

**Every script must have:**

1. **Header comment block**
   ```bash
   #!/bin/bash
   # script-name.sh
   # Purpose: What this script does
   # Prerequisites: What must be true before running
   # Side effects: What this script changes
   # Usage: How to run it
   ```

2. **Configuration section**
   ```bash
   #==============================
   # CONFIGURATION - EDIT THESE
   #==============================
   VARIABLE="value"  # Comment explaining what this is
   ```

3. **Function comments**
   ```bash
   # function_name: What it does
   # Args: What arguments it takes
   # Returns: What it returns or does
   # Side effects: What it modifies
   ```

4. **Inline comments for non-obvious operations**
   ```bash
   # Wait for USB enumeration
   sleep 2
   ```

---

## Future Enhancements

### Phase 2 Automation

**Automate:**
- XDG environment setup
- Tool installation
- User creation
- Config deployment

**Still manual:**
- Personal preferences
- Application-specific configs
- Tool configuration (tmux, vim, etc.)

### Testing Framework

**Automated testing:**
```bash
#!/bin/bash
# test-suite.sh

run_test() {
    local test_name=$1
    local test_command=$2
    
    echo "Testing: $test_name"
    if eval "$test_command"; then
        echo "✓ PASS: $test_name"
    else
        echo "✗ FAIL: $test_name"
        exit 1
    fi
}

run_test "Drive detection" "test -b /dev/nvme0n1"
run_test "Serial verification" "verify_drive_serial /dev/nvme0n1 EXPECTED"
...
```

### Configuration File

**External config instead of script variables:**

```bash
# config/hardware.conf
NVME_DRIVE=/dev/nvme0n1
NVME_SERIAL=S5GXNX0T123456
...

# Script sources config
source config/hardware.conf
```

**Benefits:**
- Config survives script updates
- Can have multiple configs (hardware profiles)
- Clearer separation

---

## Related Documentation

- `scripts/phase1-automated-install.sh` - The actual Phase 1 script
- `docs/Phase-2-Pre-Boot-Customization.md` - What happens after Phase 1
- `CORRECTION-Init-System-Choice.md` - Why OpenRC in bootstrap

---

**Document Status:** Script architecture defined  
**Script Status:** Phase 1 complete, Phase 2 manual procedure documented

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*
