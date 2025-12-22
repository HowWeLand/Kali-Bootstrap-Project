# MAJOR CORRECTION: Init System Choice - OpenRC is Viable

**Date:** December 17, 2025  
**Impact:** Critical - Changes primary installation path  
**Scope:** Affects Phase -1, Appendix, and entire bootstrap procedure

---

## What Was Wrong

Previous documentation incorrectly stated that OpenRC and other systemd alternatives were **"not viable for this project"** and that we must **"accept systemd's complexity for ecosystem compatibility."**

**From `appendices/appendix-non-decisions.md`:**
> "### OpenRC, s6, runit, and other systemd alternatives
> 
> **Status: Acknowledged preference, but not viable for this project**
> 
> Kali uses systemd as the Debian default. Deviating creates a maintenance nightmare. Most Kali tools are init agnostic, but some assume systemd presence. The OpenRC documentation ecosystem has atrophied over the past decade.
> 
> **This is documented as a tradeoff:** accepting systemd complexity for tool ecosystem compatibility."

**From `docs/phase-minus-1-project-context.md`:**
> "**System layer:**
> - systemd init (alternatives not viable, see Appendix)"

**This was incorrect based on untested assumptions.**

---

## What Actually Happened

### The Systemd Failure

After completing a multi-drive encrypted Kali installation with:
- LUKS2 encryption on both NVMe (root) and SATA (home) drives
- BTRFS flat subvolume architecture across both drives
- USB keyfile for crypto unlocking
- All crypto components working perfectly
- GRUB and initramfs correctly configured

**Systemd failed catastrophically at mount ordering:**
- Crypto unlocked both drives successfully
- Root subvolume mounted correctly
- **Systemd refused to mount additional BTRFS subvolumes in the correct order**
- Resulted in emergency shell despite all underlying components working
- Multiple attempts to fix with systemd mount dependencies failed
- No amount of `After=`, `Requires=`, or unit file manipulation worked

**The fundamental issue:** Systemd's mount ordering for multiple encrypted BTRFS subvolumes across different physical drives is unreliable. The dependency resolver cannot handle:
- Multiple LUKS volumes unlocking in sequence
- BTRFS subvolumes needing specific mount order
- Cross-drive dependencies (home subvolumes depending on root being mounted first)

### The OpenRC Solution

**Rather than continue fighting systemd, converted to OpenRC in chroot from live environment:**

```bash
# The actual conversion process that worked:
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

**Why OpenRC succeeded where systemd failed:**
- Reads `/etc/fstab` and respects mount order directly
- Simpler, more predictable boot sequence
- `cryptdisks-early` and `cryptdisks` services handle crypto properly
- `mountall.sh` mounts filesystems in fstab order without complex dependency graphs
- No "smart" dependency resolution that gets confused by cross-drive encrypted subvolumes

---

## What This Means for Documentation

### 1. OpenRC is a Primary Path, Not a Non-Decision

**Old statement (WRONG):**
> "OpenRC... not viable for this project"

**New statement (CORRECT):**
> "OpenRC is the **recommended init system** for multi-drive encrypted BTRFS setups. Systemd's mount ordering fails in this scenario. For single-drive installations, systemd works fine."

### 2. The Tradeoff is Different Than Claimed

**Old claim:**
> "Accepting systemd complexity for tool ecosystem compatibility"

**Actual reality:**
- Most Kali tools are init-agnostic (they're just programs)
- Very few tools actually depend on systemd
- OpenRC provides equivalent service management
- elogind replaces systemd-logind for session management
- **The tradeoff is:** Slightly more manual service configuration vs actually having a working system

### 3. This Should Be Documented as TWO Installation Paths

**Path A: Single Drive or Simple Multi-Drive Setup**
- Systemd works fine
- Use standard Kali defaults
- Simpler initial setup
- Follow existing Kali documentation

**Path B: Multi-Drive Encrypted BTRFS (This Project)**
- **OpenRC required** (systemd will fail)
- Requires bootstrap with sysvinit-core + openrc
- Or: systemd → OpenRC conversion in chroot
- More initial setup work
- **Actually boots successfully**

### 4. The "GNOME Problem" is Acceptable

**Trade-off acknowledged:**
- GNOME assumes systemd presence
- Other desktop environments (XFCE, KDE, i3, etc.) work fine with OpenRC
- **This is an acceptable trade-off** for having a working system
- Document: "If you need GNOME, use single-drive systemd path"



## Lessons Learned

### Technical Lessons

1. **Test your assumptions**
   - "systemd is required" was assumption, not fact
   - Real-world testing proved otherwise
   - Document what you actually build and test

2. **Systemd mount ordering is a real problem**
   - Not theoretical - actually fails
   - Specifically fails with: multiple encrypted drives + BTRFS subvolumes
   - OpenRC's simpler approach works where systemd's complexity fails

3. **Init system conversion is viable**
   - Can be done in chroot
   - Doesn't require reinstall
   - Properly documented procedure works reliably

4. **Most tools don't actually need systemd**
   - Kali tools are mostly init-agnostic
   - Session management: elogind replaces systemd-logind
   - The "ecosystem requirement" was overstated

### Documentation Lessons

1. **Don't dismiss alternatives without testing**
   - OpenRC was dismissed as "not viable" without trying
   - Turned out to be the solution to an unsolvable systemd problem
   - Always test before declaring something impossible

2. **Document what works, not what should work**
   - Theoretical systemd configs didn't work
   - Practical OpenRC conversion did work
   - Primary documentation should reflect actual success

3. **Acknowledge when you were wrong**
   - This entire correction document exists because original assumptions were incorrect
   - That's fine - that's learning
   - Document the correction, explain what changed

4. **Experience trumps documentation**
   - Existing docs said "use systemd"
   - Real experience said "systemd fails here"
   - Update docs to match reality, not expectations

---

## Impact on Project Philosophy

**This correction reinforces the core philosophy:**

> "If I can't document and replicate it, did I really do it?"

**What happened:**
1. Assumed systemd was required (cargo-culting Kali defaults)
2. Hit real-world failure (systemd mount ordering)
3. Tested alternative (OpenRC conversion)
4. Alternative worked (documented success)
5. **Updated documentation to reflect reality**

**This is exactly what the project is about:**
- No cargo-culting "best practices" that don't work
- Test actual configurations in real scenarios
- Document what actually succeeds
- Acknowledge and correct mistakes
- Provide enough context for informed decisions

**The "radical epistemological honesty" principle:**
- We were wrong about OpenRC not being viable
- We tested it anyway when systemd failed
- It worked
- We document the correction
- Future readers benefit from the actual experience

---

## Recommendations

### For This Project

1. **Add OpenRC as primary path** in multi-drive documentation
2. **Keep systemd path** for single-drive simple setups
3. **Create decision matrix** for which to use when
4. **Document both** with clear use cases

### For Future Work

1. **Test OpenRC from bootstrap** (rather than convert after systemd failure)
2. **Document desktop environment** compatibility with OpenRC
3. **Create service management guide** for OpenRC
4. **Benchmark boot times** (OpenRC vs systemd)

### For Readers

**If you're installing:**
- Multi-drive encrypted BTRFS: Use OpenRC from start
- Single drive: Either works, systemd is simpler
- Hit mount issues with systemd: Convert to OpenRC

**If you're adapting this documentation:**
- Test both paths for your hardware
- Document what actually works for you
- Share your experience (PRs welcome)

---

## Git Commit Context

**This correction represents a major change in the project:**

**Before:** 
- "Use systemd, OpenRC not viable"
- Untested assumption
- Followed conventional wisdom

**After:**
- "Use OpenRC for multi-drive encrypted setups"
- Tested in real installation
- Documented working solution

**The git history will show:**
- Original docs dismissing OpenRC
- Mount ordering failure with systemd
- Successful OpenRC conversion
- This correction document
- Updated docs recommending OpenRC

**This is intentional transparency.** We don't hide mistakes - we document the learning process.

---

## Action Items

### Immediate

- [ ] Update `appendices/appendix-non-decisions.md`
- [ ] Update `docs/phase-minus-1-project-context.md`
- [ ] Create `docs/decision-init-system.md`
- [ ] Create `docs/openrc-installation.md`
- [ ] Create `docs/openrc-conversion-from-systemd.md`

### Phase Documentation

- [ ] Phase 0: Add init system choice point
- [ ] Phase 1: Update bootstrap commands for OpenRC path
- [ ] Phase 3: Document OpenRC service configuration
- [ ] Phase 4: Update desktop environment compatibility notes

### Supporting Docs

- [ ] Add to corrections-lessons-learned.md
- [ ] Update README with init system choice info
- [ ] Create troubleshooting guide for mount ordering issues

---

## Conclusion

**What we learned:**

1. Systemd mount ordering fails for complex encrypted multi-drive BTRFS setups
2. OpenRC solves this completely with simpler, predictable mounting
3. "Not viable" was wrong - OpenRC is viable and recommended for this use case
4. Most tools don't actually need systemd
5. GNOME trade-off is acceptable

**What changed in documentation:**

1. OpenRC moves from "non-decision" to "recommended for multi-drive"
2. systemd remains option for single-drive simple setups
3. Both paths documented with clear use cases
4. Conversion procedure documented for existing installations

**Why this matters:**

This correction exemplifies the project's philosophy: document reality, not assumptions. Test alternatives when defaults fail. Acknowledge mistakes. Provide enough context for informed decisions.

**The documentation now reflects actual tested experience, not theoretical "should work" approaches.**

---

**Document Status:** Complete correction  
**Next Actions:** Update referenced documents, create new decision guides  
**Git Impact:** Major - changes primary installation path recommendation

---

*This correction is licensed under the same terms as the rest of the project documentation.*
