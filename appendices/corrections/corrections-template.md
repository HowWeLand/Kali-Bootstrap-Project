# Correction: [Topic]

**Date Discovered:** YYYY-MM-DD  
**Impact:** [Critical/Major/Minor]  
**Affects:** [Which documents/code]

---

## What Was Wrong

[Clear statement of the incorrect information/assumption]

**Example:**
> Original documentation stated OpenRC was "not viable for this project."

## Why It Was Wrong

[Explanation of why the original was incorrect]

**Example:**
> Real-world testing showed systemd fails at mounting multiple encrypted BTRFS subvolumes across drives. OpenRC handles this correctly through sequential fstab mounting.

## What's Correct

[The corrected information]

**Example:**
> OpenRC is not just viable but **required** for multi-drive encrypted BTRFS setups. systemd's mount ordering cannot handle this scenario reliably.

## How We Discovered This

[The process that revealed the error]

**Example:**
> After completing full installation with systemd, system failed to boot. Mount ordering issues persisted despite multiple attempts to fix with systemd unit dependencies. Conversion to OpenRC in chroot resolved all mount issues immediately.

## What Changed

[Concrete changes made to documentation/code]

**Example:**
> - Updated `appendix-non-decisions.md` to remove OpenRC dismissal
> - Created `decision-init-system.md` with full comparison
> - Added OpenRC as recommended path for multi-drive setups
> - Documented conversion procedure

## Lesson Learned

[The broader principle or insight]

**Example:**
> Don't dismiss alternatives without testing. "Conventional wisdom" isn't always correct. For complex setups, simpler approaches (OpenRC's sequential mounting) can be more reliable than complex "smart" systems (systemd's dependency resolver).

---

**Status:** Corrected in main documentation  
**Related Docs:** decision-init-system.md, openrc-installation.md, openrc-conversion-from-systemd.md