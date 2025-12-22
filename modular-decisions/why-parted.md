# Why parted (Partitioning Tool Choice)

## TL;DR

`parted` is chosen for its scriptable, non-interactive mode that enables fully automated partitioning with partition labels in single commands. The tradeoff is **zero safety guardrails**—it executes destructive operations immediately without confirmation.

---

## The Case FOR parted

### Strength 1: Scriptable Non-Interactive Mode

```bash
# Single command creates labeled GPT partition
parted -s /dev/nvme0n1 mkpart LUKS_ROOT 1537MiB 100%

# Compare to fdisk which requires:
# 1. Enter interactive mode
# 2. Type 'n' for new partition
# 3. Enter partition number
# 4. Enter start sector
# 5. Enter end sector
# 6. Type 'w' to write
# 7. Exit
# 8. Separately set partition name with sgdisk
```

For a bootstrap script that must run unattended, parted's `-s` (script) mode is essential.

### Strength 2: Native GPT Support with Labels

parted handles GPT partition labels directly:

```bash
parted -s /dev/sda mkpart EFI fat32 1MiB 513MiB
parted -s /dev/sda mkpart BOOT ext4 513MiB 1537MiB
parted -s /dev/sda mkpart LUKS_ROOT 1537MiB 100%
```

The partition names (`EFI`, `BOOT`, `LUKS_ROOT`) become the PARTLABEL, which we use throughout the bootstrap for hardware-agnostic references.

### Strength 3: Consistent Across Drive Types

Same syntax works for:
- SATA drives (`/dev/sda`)
- NVMe drives (`/dev/nvme0n1`)
- USB drives (`/dev/sdb`)
- Virtual drives (`/dev/vda`)

No special handling or different command sequences needed.

---

## The Case AGAINST parted

### Weakness 1: Zero Safety Guardrails

**THIS IS CRITICAL:**

```bash
# This command INSTANTLY DESTROYS all data on the drive
# No confirmation prompt
# No undo
# No recovery
parted -s /dev/sda mklabel gpt

# Even without -s, parted writes changes immediately
# Unlike fdisk which holds changes in memory until 'w'
```

**Real-world disaster scenario:**
```bash
# User meant to partition /dev/sdb (USB drive)
# Typed /dev/sda (system drive) by mistake
parted -s /dev/sda mklabel gpt
# System drive instantly wiped
# No warning, no recovery
```

### Weakness 2: Less Educational

parted's terse output doesn't teach partition concepts:

```bash
$ parted -s /dev/sda mkpart LUKS_ROOT 1537MiB 100%
# (no output on success)
```

Compare to fdisk's interactive explanation:
```
Command (m for help): n
Partition type
   p   primary (2 primary, 0 extended, 2 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (3,4, default 3): 3
First sector (3145728-1953525167, default 3145728):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (3145728-1953525167, default 1953525167):
Created a new partition 3 of type 'Linux' and of size 930 GiB.
```

### Weakness 3: Alignment Footguns

parted's default alignment behavior can create suboptimal partitions:

```bash
# This might not align to 1MiB boundaries on all systems
parted -s /dev/sda mkpart primary 0% 512M
```

Best practice is always specifying MiB values:
```bash
parted -s /dev/sda mkpart primary 1MiB 513MiB
```

---

## Alternatives & When to Use Them

### Alternative 1: fdisk (Traditional, Safe)

**Use fdisk when:**
- Learning partition concepts interactively
- You want confirmation before writing changes
- Exploring existing partition structures
- Recovering from partition table damage

```bash
# fdisk holds changes in memory until 'w' is pressed
fdisk /dev/sda
# ... make changes ...
# 'q' quits without saving (safe)
# 'w' writes changes (destructive)
```

**Limitation:** Requires scripting tricks (heredocs, expect) for automation, which is fragile.

### Alternative 2: gdisk (GPT Specialist)

**Use gdisk when:**
- Complex GPT attribute manipulation
- Backup/restore GPT headers
- Converting MBR → GPT without data loss
- Repairing corrupted GPT tables

```bash
# gdisk has GPT-specific features parted lacks
gdisk /dev/sda
# 'x' enters expert mode for header manipulation
# 'c' converts MBR to GPT (dangerous but possible)
```

### Alternative 3: sfdisk (Scripting Alternative)

**Use sfdisk when:**
- You want scriptable partitioning WITH confirmation
- Cloning partition layouts between drives
- Dumping/restoring partition tables

```bash
# Dump partition layout
sfdisk -d /dev/sda > sda-layout.txt

# Apply to another drive (with confirmation)
sfdisk /dev/sdb < sda-layout.txt
```

---

## For This Project Specifically

### Why We Chose parted

1. **Scriptable automation** is core to reproducible bootstrap
2. **Partition labels in one command** simplifies hardware-agnostic design
3. **Same syntax everywhere** reduces conditional logic in scripts
4. **Kali Live environment includes it** by default

### Why We Didn't Choose fdisk

- Requires complex heredoc scripting for automation
- No partition labeling in single command
- More fragile when scripted (depends on prompts not changing)

### Why We Didn't Choose gdisk

- Overkill for our needs (we're not repairing GPT tables)
- Less commonly installed by default
- Learning curve for expert mode features we don't need

---

## Safety Recommendations for parted

Since parted is dangerous, our bootstrap includes these safeguards:

### 1. Explicit Hardware Verification Step

```bash
echo "System drive: $SYSTEM_DRIVE ($(lsblk -dno SIZE,MODEL $SYSTEM_DRIVE))"
read -p "Type 'DESTROY' to confirm: " confirm
[[ "$confirm" != "DESTROY" ]] && exit 1
```

### 2. Variable-Based References

Never hardcode device paths:
```bash
# BAD - typo means wrong drive destroyed
parted -s /dev/sda mklabel gpt

# GOOD - typo in variable name causes syntax error, not data loss
parted -s "$SYSTEM_DRIVE" mklabel gpt
```

### 3. Pre-Execution Verification

```bash
# Verify drive is what we expect
if [[ $(lsblk -dno TYPE $SYSTEM_DRIVE) != "disk" ]]; then
    echo "ERROR: $SYSTEM_DRIVE is not a disk!"
    exit 1
fi
```

### 4. Post-Operation Verification

```bash
# Verify partitions were created correctly
lsblk -o NAME,PARTLABEL "$SYSTEM_DRIVE" | grep -q "LUKS_ROOT" || {
    echo "ERROR: LUKS_ROOT partition not created!"
    exit 1
}
```

---

## How to Swap to fdisk Instead

If you prefer fdisk's interactive confirmation:

### Step 1: Replace Partitioning Section

Replace the parted commands in Part I.2 with this fdisk script:

```bash
# Create partition layout file
cat > /tmp/partition-layout.txt << 'EOF'
label: gpt
device: ${SYSTEM_DRIVE}
unit: sectors

${SYSTEM_DRIVE}p1 : start=2048, size=1048576, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, name="EFI"
${SYSTEM_DRIVE}p2 : start=1050624, size=2097152, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="BOOT"
${SYSTEM_DRIVE}p3 : start=3147776, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, name="LUKS_ROOT"
EOF

# Apply with sfdisk (shows what will happen)
sfdisk "$SYSTEM_DRIVE" < /tmp/partition-layout.txt
```

### Step 2: Verify

```bash
lsblk -o NAME,PARTLABEL,SIZE "$SYSTEM_DRIVE"
```

### Step 3: Continue with Formatting

The rest of the bootstrap (LUKS, BTRFS, etc.) works identically regardless of which partitioning tool was used.

---

## See Also

- `phases/phase0-base-system/encryption/why-luks2.md` - Encryption decisions
- `phases/phase0-base-system/partitioning/btrfs-subvolumes.md` - Subvolume architecture
- `DECISION-FRAMEWORK.md` - How decisions are documented

---

**Summary:** parted is chosen for scriptability and partition labeling. The critical tradeoff is safety—parted will destroy your data instantly if you make a typo. Mitigate this with explicit verification steps and variable-based device references.
