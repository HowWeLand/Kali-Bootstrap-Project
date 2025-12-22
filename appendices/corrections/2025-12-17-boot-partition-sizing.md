# Correction: Boot Partition Size

**Date Discovered:** 2025-12-17  
**Impact:** Minor (easily correctable during planning phase)  
**Affects:** phase1-automated-install.sh, phase-0-planning.md

---

## What Was Wrong

Script specified boot partition as **1GB**.

```bash
# Original configuration
BOOT_SIZE="1G"
```

## Why It Was Wrong

**1GB is too small** to store a Kali rescue ISO (4-5GB) alongside kernels and initramfs images.

**Space requirements:**
- Multiple kernel versions: ~1GB total
- Initramfs images: ~500MB
- GRUB files: ~100MB
- **Kali rescue ISO: 4-5GB** ← This doesn't fit
- Future-proofing: Additional space for backups

**Use case:** Having a rescue ISO stored in the boot partition allows for system recovery without requiring external bootable media.

**The problem:** With only 1GB, you can't include the rescue ISO. You're left with either:
1. Not having rescue ISO on system (requires external media)
2. Resizing partitions later (requires reinstall or complex resize operations)

## What's Correct

Boot partition should be **10GB minimum**:

```bash
# Corrected configuration
BOOT_SIZE="10G"
```

**Space allocation breakdown:**
- Multiple kernel versions: ~1GB
- Initramfs images: ~500MB  
- GRUB files: ~100MB
- Kali rescue ISO: 4-5GB
- Future expansion: ~3.5GB remaining

**Benefits:**
- Room for rescue ISO in boot partition
- Multiple kernel versions with their initramfs
- Space for kernel backups before major updates
- Future-proofing (ISOs may get larger)

## How We Discovered This

### Planning Phase Realization

While planning Phase 7 (Live ISO creation), realized:
1. Want rescue ISO available without external media
2. Boot partition is ideal storage location (already mounted, accessible to GRUB)
3. Current size (1GB) insufficient
4. Easier to plan correctly from start than resize later

### The Math

```
Kernel versions (3-4 kept):     ~1000 MB
Initramfs images:                 ~500 MB
GRUB + config:                    ~100 MB
Kali ISO (current):              ~4500 MB
Subtotal:                        ~6100 MB
Future-proofing:                 ~3900 MB
---
Total needed:                    ~10000 MB (10GB)
```

**1GB original plan:** Not enough room for ISO.

**10GB corrected plan:** Plenty of room with headspace.

## What Changed

### Script Update

**File:** `scripts/phase1-automated-install.sh`

```bash
# Before
BOOT_SIZE="1G"

# After  
BOOT_SIZE="10G"
```

### Documentation Update

**File:** `docs/phase-0-planning.md`

Added explanation in partition layout section:

```markdown
**Boot partition: 10GB**
- Large enough to store Kali rescue ISO
- Multiple kernel versions
- Future expansion space
- Enables recovery without external media
```

### Planning Guidance

Added to decision documentation:

**Storage is cheap, reinstalling is expensive.**

Planning for 10GB boot partition costs pennies in modern storage. Resizing partitions later costs hours and carries data loss risk.

## Lesson Learned

### Plan for Future Use Cases

**Mistake:** Calculated boot partition size based on *current* requirements only.

**Correction:** Calculate based on *planned* use cases, including:
- Rescue ISO storage
- Multiple kernel backups
- Future ISO size increases
- Margin for unexpected needs

### The "Just Enough" Fallacy

**Temptation:** "1GB is enough for kernels and GRUB, why waste space?"

**Reality:** 
- "Waste" is subjective (9GB unused out of 2TB drive is 0.45%)
- Future features may need that space
- Resizing requires significant effort
- Storage is cheap, time is expensive

**Better approach:** Overprovision slightly rather than precisely calculate minimums.

### Document the Rationale

Original script had:
```bash
BOOT_SIZE="1G"  # No comment explaining why
```

Corrected version:
```bash
BOOT_SIZE="10G"  # Large enough for rescue ISO + multiple kernels
```

**Comments matter.** Future you (or others) need to understand *why* a value was chosen.

---

## Related Decisions

This correction connects to:

**Phase 7 planning:**
- Live ISO creation
- Rescue system preparation
- Recovery workflows

**Phase 0 planning:**
- Partition layout strategy
- Future-proofing decisions
- Storage allocation philosophy

**Script architecture:**
- Configuration variables placement
- Documentation in code
- Explaining magic numbers

---

**Status:** Corrected  
**Related Docs:** 
- docs/phase-0-planning.md (updated)
- scripts/phase1-automated-install.sh (corrected)

---

*This correction is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*
