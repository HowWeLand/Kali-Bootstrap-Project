# Correction: Boot Partition Size

**Date Discovered:** 2025-12-17  
**Impact:** Minor (easily correctable)  
**Affects:** phase1-automated-install.sh, phase-0-planning.md

---

## What Was Wrong

Script specified boot partition as 1GB.

## Why It Was Wrong

1GB is too small to store a Kali rescue ISO (4-5GB) alongside kernels and initramfs images.

## What's Correct

Boot partition should be 10GB minimum:
- Multiple kernel versions: ~1GB
- Initramfs images: ~500MB
- GRUB files: ~100MB
- Kali rescue ISO: 4-5GB
- Future-proofing: remaining space

## How We Discovered This

Planning to include rescue ISO in boot partition for recovery scenarios. Realized 1GB wasn't sufficient.

## What Changed

- Updated `BOOT_SIZE="1G"` to `BOOT_SIZE="10G"` in phase1 script
- Updated phase-0-planning.md documentation
- Added explanation of why 10GB in decision rationale

## Lesson Learned

Plan for future use cases during initial setup. Storage is cheap, reinstalling to resize partitions is expensive.

---

**Status:** Corrected  
**Related Docs:** phase-0-planning.md, phase1-automated-install.sh