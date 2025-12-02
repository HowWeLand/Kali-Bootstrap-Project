# Corrections and Lessons Learned

## Purpose

This document captures mistakes made during the development of this documentation, their fixes, and the lessons learned. These corrections are documented **before** being hidden in git history to demonstrate honest acknowledgment of errors.

Documenting what went wrong is as important as documenting what went right. If you can't admit and explain your mistakes, you don't really understand the problem space.

---

## Pre-Version Control Corrections

These issues were discovered during initial documentation development, before this project had proper version control. They're documented here to show the iterative process and prevent others from making the same mistakes.

### Deprecated crypttab Syntax and Device Identification

**What went wrong:**
Used deprecated syntax in `/etc/crypttab` configuration that worked on older Debian versions but not current Kali.

**The mistake:**
```
# Old deprecated syntax
encrypted_root /dev/sda2 none luks
```

**The fix:**
```
# Current correct syntax using labels
encrypted_root /dev/disk/by-label/crypt_root none luks,discard
```

**Why labels over UUIDs:**
- Labels are human-readable and easier to manage in automation
- Consistent naming across multiple devices (if scaling to multi-drive setups)
- Still stable across reboots (unlike `/dev/sdX` which can change)
- Easy to subdivide and track if dealing with more than 2 devices
- `by-label` is just as robust as `by-uuid` for device identification

**Alternative (also correct):**
```
# Using UUID instead
encrypted_root UUID=<uuid> none luks,discard
```

**Why it matters:**
- Deprecated syntax may work now but will break in future updates
- Device names (`/dev/sda2`) can change between boots
- Labels provide consistency and aid automation
- The `discard` option is important for SSD performance but has security tradeoffs (document these in Phase 0)

**Lesson learned:**
Always check current documentation for syntax, even if you've done this before. Debian/Kali evolve, and old knowledge becomes wrong knowledge. Device identification strategy matters for automation and multi-device scaling.

---

### Arch-Specific Kernel Parameters

**What went wrong:**
Included Arch Linux-specific kernel parameters in GRUB configuration that don't work on Debian-based systems.

**The mistake:**
Including parameters like certain `zswap` configurations or `rw` flags that are Arch defaults but not Debian defaults.

**Why it matters:**
Kali is Debian-based, not Arch-based. Kernel parameter handling differs between distributions. Arch wiki is excellent documentation but not everything applies to Debian derivatives.

**The fix:**
Remove Arch-specific parameters, use Debian/Kali defaults, document where parameters come from.

**Lesson learned:**
Know which distribution you're on and consult the appropriate documentation. The Arch wiki is great for concepts but verify everything against Debian docs for Kali.

---

### USB Timing Issues with Keyfiles

**What went wrong:**
LUKS keyfile on USB device wasn't accessible during boot because the USB device hadn't finished initializing.

**The mistake:**
Not accounting for USB device initialization time during the boot process.

**The fix:**
Added delay in initramfs scripts to wait for USB device availability before attempting to access keyfile.

```bash
# Wait for USB device to be ready
sleep 3
```

More sophisticated solutions involve polling for device availability rather than blind sleep, but the principle is the same: USB devices need initialization time.

**Why it matters:**
- Boot process happens fast
- USB devices are slow to initialize relative to boot speed
- System won't boot if keyfile is inaccessible
- This is a timing race condition that might work sometimes and fail others

**Lesson learned:**
Physical device access during boot requires accounting for hardware initialization timing. USB devices especially need time to enumerate.

---

### LUKS Header Backup Timing

**What went wrong:**
Originally planned to back up LUKS headers after completing the installation, which risks data loss if something goes wrong during installation.

**The mistake:**
Delaying critical backup steps until after they're no longer "critical."

**The fix:**
Move LUKS header backup to **immediately after** formatting the encrypted partition, before any data is written to it.

```bash
# Immediately after cryptsetup luksFormat
cryptsetup luksHeaderBackup /dev/sda2 --header-backup-file /path/to/backup/luks-header-backup.img
```

**Why it matters:**
- LUKS header corruption = total data loss
- The header is written during `luksFormat`
- Backup should happen immediately after header creation
- "I'll do it later" means "I'll forget until it's too late"

**Lesson learned:**
Critical backup steps should happen as close as possible to the creation of what's being backed up. Don't defer backups to "later" - later is when you've already lost data.

---

## Assumption Corrections

These are corrections to assumptions made during initial documentation that proved incorrect upon verification.

### Systemd Units and Kali's Service Policy

**Initial assumption:**
"Kali will need to write tons of custom systemd units when sysv compatibility is deprecated."

**Actual situation:**
Kali currently uses a custom `update-rc.d` wrapper (`kali-update-rc.d`) to implement their "network services disabled by default" security policy. This is sysv-era tooling.

When sysv compatibility is fully deprecated in Debian Forky's development cycle, Kali needs to migrate this policy to systemd-native mechanisms (preset files or unit overrides), not necessarily write tons of new units.

**Why the correction matters:**
- Understanding the actual implementation (custom `update-rc.d` wrapper) vs assumption (future unit files)
- Recognizing that Kali-rolling tracks Debian testing (Forky), so this migration is happening **now**
- Accurate technical depth prevents spreading misinformation

**How it was corrected:**
Researched Kali's GitLab repository, examined `kali-update-rc.d` source, verified against Debian Forky development discussions.

**Lesson learned:**
Verify assumptions before stating them as fact. "I think Kali will do X" requires checking what Kali actually does. Primary sources (Kali's GitLab, Debian dev mailing lists) trump assumptions.

---

### UEFI vs Legacy Boot as a Meaningful Choice

**Initial assumption:**
UEFI vs legacy boot should be presented as a choice users need to make.

**Actual situation:**
Legacy BIOS is effectively obsolete in 2025. Any hardware worth running Kali on supports UEFI. The economic reality (finding non-garbage storage <2TB, modern SATA standards) makes legacy boot impractical.

**Why the correction matters:**
- Presenting obsolete options as choices wastes time
- Users might think they need to research a "decision" that isn't actually a decision
- Documentation should acknowledge when technology has moved on

**How it was corrected:**
Moved to "Eliminated Alternatives and Non-Decisions" appendix with explanation of why it's not a choice anymore.

**Lesson learned:**
Not every historical choice remains relevant. Document what changed and when options became non-options.

---

## Known Issues Pending Resolution

These are issues that have been identified but not yet fully resolved or documented.

### BTRFS Tuning Parameters

**Issue:**
BTRFS configuration uses flat subvolumes and basic settings, but tuning parameters are not well documented or optimized.

**Status:**
Acknowledged in documentation as "tuning is suspect" - parameters work but may not be optimal for all use cases.

**Next steps:**
- Research BTRFS tuning for single-drive workstation scenarios
- Document which parameters matter and why
- Explain tradeoffs of different tuning choices

**Why it's listed here:**
Acknowledging what you don't know yet is as important as documenting what you do know. This is a known gap.

---

### Multi-Device Scaling (Future Consideration)

**Issue:**
Initial documentation assumes 1-2 device setup (system drive + optional USB keyfile). Device label strategy (`/dev/disk/by-label/`) supports scaling to multiple devices but isn't fully documented yet.

**Status:**
Label-based identification chosen specifically to make multi-device scenarios easier when they arise. Not currently documented because hardware isn't available yet.

**Future scenario:**
If upgrading to desktop with 3090 (or other multi-drive setup), label strategy will allow:
- Easy identification of which encrypted volume is which
- Automation across multiple devices
- Consistent naming scheme (`crypt_root`, `crypt_data`, `crypt_backup`, etc.)
- No UUID confusion when managing 3+ encrypted volumes

**Why it's listed here:**
Planning for future scalability even if current setup is simple. The label strategy was chosen intentionally to make this easier when hardware allows.

**Note:** The 3090 acquisition would be a significant windfall and isn't planned/budgeted - just preparing the architecture in case hardware situation improves.

---

### Plausible Deniability Approaches Not Covered

**Issue:**
Documentation mentions `cryptsetup-nuke-password` but explicitly does not cover plausible deniability strategies.

**Reasoning:**
- Plausible deniability requires certainty that adversary won't use physical coercion
- Failed deniability dramatically increases suspicion and consequences
- This is highly context-dependent and outside the scope of general documentation

**Status:**
Intentionally not covered. Users are directed to Kali's official documentation to make their own informed decisions.

**Why it's listed here:**
To acknowledge this is a conscious choice, not an oversight. The gap is intentional and explained.

---

## Correction Methodology

When mistakes are discovered:

1. **Document immediately** - Don't wait until "the documentation is done"
2. **Explain what was wrong** - Not just the fix, but why it was wrong
3. **Show the correction** - Before and after, with explanation
4. **Extract the lesson** - What broader principle does this illustrate?
5. **Update source documentation** - Fix the original error
6. **Keep this record** - So others can learn from it

This document grows as mistakes are discovered. An empty corrections document would mean either:
- Nothing was ever wrong (impossible)
- Mistakes are being hidden (dishonest)

A growing corrections document means iterative improvement and honest acknowledgment of the learning process.

---

## Contributing Corrections

If you find errors in this documentation:

1. **Document what's wrong** - Specifically, with examples
2. **Explain why it's wrong** - Not just "this doesn't work" but "here's why"
3. **Provide the correction** - What should it be instead?
4. **Show your verification** - How did you confirm the fix?

Corrections that follow this format will be integrated with credit.

---

**Document Status:** Living document. Updated as new mistakes are discovered and corrected.

**Last Updated:** [Date]

---

**Remember:** If you're not making mistakes, you're not learning. If you're not documenting mistakes, you're not teaching.

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*

