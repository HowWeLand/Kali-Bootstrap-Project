# Correction: Init System Choice - OpenRC is Viable

**Date Discovered:** 2025-12-17  
**Impact:** Critical - Changes primary installation path  
**Affects:** appendix-non-decisions.md, phase-minus-1-project-context.md, all phase documentation

---

## What Was Wrong

Original documentation stated OpenRC was **"not viable for this project"** and that we must **"accept systemd's complexity for tool ecosystem compatibility."**

**From `appendices/appendix-non-decisions.md`:**
> "### OpenRC, s6, runit, and other systemd alternatives
> 
> **Status: Acknowledged preference, but not viable for this project**
> 
> Kali uses systemd as the Debian default. Deviating creates a maintenance nightmare."

**From `docs/phase-minus-1-project-context.md`:**
> "**System layer:**
> - systemd init (alternatives not viable, see Appendix)"

## Why It Was Wrong

**Untested assumption.** The claim that OpenRC wasn't viable was made without actual testing of OpenRC in this specific scenario.

**What actually happened:**

After completing a full multi-drive encrypted Kali installation with:
- LUKS2 encryption on both NVMe (root) and SATA (home) drives
- BTRFS flat subvolume architecture across both drives
- USB keyfile for crypto unlocking
- All crypto components working perfectly
- GRUB and initramfs correctly configured

**systemd failed catastrophically** at mount ordering:
- Crypto unlocked both drives successfully
- Root subvolume mounted correctly
- **systemd refused to mount additional BTRFS subvolumes in the correct order**
- Resulted in emergency shell despite all underlying components working
- Multiple attempts to fix with systemd mount dependencies failed
- No amount of `After=`, `Requires=`, or unit file manipulation worked

**The fundamental issue:** systemd's mount ordering for multiple encrypted BTRFS subvolumes across different physical drives is unreliable.

## What's Correct

**OpenRC is not just viable but REQUIRED for multi-drive encrypted BTRFS setups.**

systemd's dependency resolver cannot reliably handle:
- Multiple LUKS volumes unlocking in sequence
- BTRFS subvolumes needing specific mount order
- Cross-drive dependencies (home subvolumes depending on root being mounted first)

**OpenRC solves this completely:**
- Reads `/etc/fstab` and respects mount order directly
- Simpler, more predictable boot sequence
- `cryptdisks-early` and `cryptdisks` services handle crypto properly
- `mountall.sh` mounts filesystems in fstab order without complex dependency graphs
- No "smart" dependency resolution that gets confused

## How We Discovered This

### The Systemd Failure

1. Completed full installation with systemd
2. System failed to boot to graphical environment
3. Emergency shell appeared
4. Investigation showed mount ordering issues
5. Attempted fixes with systemd unit dependencies
6. Multiple iterations, all failed
7. systemd simply could not handle the mount sequence reliably

### The OpenRC Solution

Rather than continue fighting systemd:

```bash
# Conversion in chroot from live environment:
1. Boot live Kali USB
2. Mount and chroot into installed system
3. Force-install systemd-standalone-sysusers (chicken-and-egg dependency)
4. Remove systemd completely
5. Install sysvinit-core (PID 1 init)
6. Install openrc (service manager)
7. Install elogind (session management, systemd-logind replacement)
8. Rebuild initramfs with OpenRC hooks
9. Regenerate GRUB config
10. Reboot
```

**Result:**
- ✅ System boots successfully to TTY login
- ✅ All BTRFS subvolumes mount correctly in proper order
- ✅ Both encrypted drives unlock via USB keyfile
- ✅ No mount ordering issues
- ✅ Clean boot process, no errors
- ✅ **Fully functional system**

## What Changed

### Documentation Updates Required

1. **appendices/appendix-non-decisions.md**
   - REMOVE: "Status: Acknowledged preference, but not viable"
   - ADD: Complete section on systemd vs OpenRC with use cases

2. **docs/phase-minus-1-project-context.md**
   - REMOVE: "systemd init (alternatives not viable)"
   - ADD: "OpenRC (sysvinit-core + openrc) for multi-drive encrypted setups"

3. **New Documentation Created:**
   - `docs/decision-init-system.md` - Full comparison
   - `docs/openrc-installation.md` - Bootstrap with OpenRC
   - `docs/openrc-conversion-from-systemd.md` - Conversion procedure

### Script Updates

**phase1-automated-install.sh** now bootstraps with OpenRC from start:
```bash
debootstrap --variant=minbase \
  --include=kali-archive-keyring,sysvinit-core,openrc,elogind,... \
  kali-rolling /mnt http://http.kali.org/kali
```

### Installation Paths

**Two paths documented:**

**Path A: Single Drive or Simple Multi-Drive Setup**
- systemd works fine
- Use standard Kali defaults
- Simpler initial setup

**Path B: Multi-Drive Encrypted BTRFS (This Project)**
- **OpenRC required** (systemd will fail)
- Requires bootstrap with sysvinit-core + openrc
- More initial setup work
- **Actually boots successfully**

## Lesson Learned

### Technical Lesson

**Don't trust assumptions about what "should" work.**

systemd's mount ordering was supposed to work. The theory said it should handle this. Multiple online sources said systemd was fine for encrypted BTRFS.

**Reality:** systemd fails in this specific scenario.

**OpenRC's simpler approach works where systemd's complexity fails.**

### Documentation Lesson

**Document what actually works, not what should theoretically work.**

The original documentation made assumptions based on:
- "Standard practices"
- What other guides said
- Conventional wisdom about systemd being "required"

**None of these assumptions were tested** until the actual installation.

**Correction:** Test your assumptions. Document reality, not theory.

### Process Lesson

**Iterative testing reveals truth.**

1. Started with systemd (conventional choice)
2. Hit failure (mount ordering)
3. Attempted fixes (unit dependencies)
4. Continued failure (systemd limitation)
5. Tried alternative (OpenRC)
6. **Success** (OpenRC works)
7. **Document the reality** (OpenRC required for this use case)

**This is the scientific method applied to system administration.**

### Philosophical Lesson

**Acknowledge when you were wrong.**

The original documentation dismissed OpenRC without testing. This was:
- Premature optimization
- Cargo-culting "best practices"
- Assuming expertise without verification

**Being wrong and correcting it is how we learn.**

This correction document exists to:
- Show the learning process
- Prevent others from the same assumption
- Demonstrate honest acknowledgment
- Improve future documentation

---

## The GNOME Trade-off

**Acknowledged trade-off:**

GNOME desktop environment assumes systemd presence. Other desktop environments (XFCE, KDE, i3, etc.) work fine with OpenRC.

**This is an acceptable trade-off** for having a system that actually boots.

**Decision:** Document both paths. Let users choose based on their priorities:
- Want GNOME? Use single-drive systemd path
- Want multi-drive encrypted BTRFS? Use OpenRC, choose different DE

---

**Status:** Corrected in main documentation  
**Related Docs:** 
- docs/decision-init-system.md
- docs/openrc-installation.md
- docs/openrc-conversion-from-systemd.md
- appendices/appendix-non-decisions.md (updated)

---

*This correction is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*
