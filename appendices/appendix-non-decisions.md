# Appendix: Eliminated Alternatives and Non-Decisions

## Purpose

This document captures choices that are not presented as options in the main installation phases, with explanations of why. This serves two purposes: prevent confusion when encountering outdated tutorials that present these as viable choices, and document the reasoning so future readers understand what changed and why.

---

## Hardware and Boot Configuration

### UEFI vs Legacy Boot

**Status: Not a choice**

Legacy BIOS is effectively obsolete as of 2025. The economic reality makes this clear: try finding a non-garbage HDD under 2TB nowadays, or anything not running modern SATA. Modern storage universally requires or supports UEFI. Any hardware worth running Kali on supports UEFI.

The security benefits are also worth noting. UEFI provides Secure Boot capability and better firmware standards compared to legacy BIOS.

**What this means:** All documentation assumes UEFI. Legacy boot is not covered.

---

## Distribution Choices

### Arch-based Pen-testing Distros

#### Arch-Strike
**Status: Dead project**

No longer supported or maintained. Not presented as an alternative.

#### BlackArch
**Status: Different philosophy**

BlackArch maintains a collection of 2000+ security tools. This is a different approach from Kali's curated selection - not wrong, just different priorities. For this documentation's use case (focused pen-testing workstation), Kali's curated approach is preferred. BlackArch may suit users wanting comprehensive tool availability.

### WeakerTHAN
**Status: Abandoned**

Severely out of date. Frequently appears in listicles despite being dead.

### BlackLion  
**Status: Abandoned**

Severely out of date. Frequently appears in listicles despite being dead.

---

## Distro Category Confusion

### The Listicle Problem

Many "security distro" lists conflate fundamentally different use cases. This creates serious confusion about which tool to use for which job.

**Privacy Distros** (TAILS, Whonix)

Purpose: Anonymity and privacy protection

Excellent at their intended use case. Not suitable for pen-testing/malware analysis because the security model conflicts with running offensive tools and analyzing malware behavior.

**Security Distros** (Qubes, KickSecure)

Purpose: Hardened environments, compartmentalization, security research

Excellent at their intended use case. The architectural approach here differs: we start with pen-testing tools (Kali) and layer in hardening/compartmentalization as needed. Starting with a hardened platform and then installing offensive tools would undermine the security model these distros provide.

Different approach for different priorities - both are valid for their respective use cases.

**Pen-testing Distros** (Kali, Pentoo)

Purpose: Offensive security tooling and research

This is our use case. Tool ecosystem compatibility is the primary constraint.

**Forensics Distros** (CAINE, Paladin, Tsurugi)

Purpose: Evidence preservation and analysis

Status: All need desperate refreshing as of 2025

**Why this matters:** Using the wrong distro category for your use case means either the tools don't work (trying to pen-test from TAILS), or the security model is undermined (installing Kali tools in Qubes), or you're fighting the distribution's design philosophy.

---

## Init Systems

### OpenRC, s6, runit, and other systemd alternatives

### Init System Choice: systemd vs OpenRC

**Status: BOTH are viable - choice depends on your setup**

**Use systemd if:**
- Single drive installation
- Simple partition layout
- Want GNOME desktop
- Prefer Kali defaults

**Use OpenRC if:**
- Multiple encrypted drives with BTRFS subvolumes
- Experienced systemd mount ordering failures
- Prefer simpler, more predictable boot process
- Don't need GNOME

**OpenRC conversion procedure documented in:** [link to new OpenRC section]

**What changed:** Original documentation assumed systemd was required. Real-world testing proved that systemd fails at mounting multiple encrypted BTRFS subvolumes across different drives. OpenRC solves this completely.

---

## Filesystem Choices

### RAID configurations

**Status: Not covered**

RAID is designed for redundancy and uptime. These are enterprise concerns. A pen-testing workstation needs snapshots, integrity checking, and fast iteration. RAID adds complexity without addressing actual use case needs.

RAID is anti-modularity for single user workstation scenarios.

**If you need RAID:** Consider ZFS on a proper multi-drive server, not a pen-testing workstation.

### ZFS for root/home on single drive systems

**Status: Viable but not recommended for this use case**

ZFS is designed for multi-drive pools. Using it on a single drive system means accepting out-of-tree kernel module maintenance burden and GPL licensing complications. The overhead is not justified for a single drive pen-testing workstation.

**When ZFS makes sense:**

Multi-drive server scenarios where you explicitly need ZFS features (advanced RAID, deduplication) and you accept the maintenance and licensing tradeoffs.

**Why BTRFS instead:**

BTRFS provides mainline kernel support. You get snapshots and integrity checking without RAID overhead. It's single drive friendly. BTRFS is semi-supported by Kali (partman-btrfs exists in the Kali fork of debian-installer, even if the defaults are suboptimal). BTRFS has been upstreamed and will become a standard installer option during Forky's development cycle.

BTRFS builds in snapshots and rollback, with checksums and integrity checks as long as you avoid certain RAID configurations. Honestly, if you need RAID, maybe ZFS is the way to go. But why run RAID on a penetration testing system?

I wouldn't argue against building the module to support ZFS, just don't have your system depend on it for root or home unless you already know what you're signing up for and have enough drives to justify the overhead.

---

## Alternative Approaches

### Using Qubes/KickSecure as base and adding pen-testing tools

**Status: Backwards approach**

Qubes and KickSecure are hardened security platforms. Installing offensive tools requires undermining the security model. This results in neither good pen-testing nor good compartmentalization.

**Correct approach:**

Start with the pen-testing foundation (Kali). Layer in hardening and compartmentalization appropriate for malware analysis. Add Whonix on top if you need anonymity.

Since malware development and analysis is on the menu, it makes more sense to look into hardening and compartmentalization on Kali than ripping holes in Qubes or KickSecure's security models. Run Whonix on top of that if you need anonymity on your laptop that badly.

### Using Pentoo (Gentoo-based) instead of Kali

**Status: Technically viable, pragmatically problematic**

Metasploit assumes Kali defaults. SET (Social Engineering Toolkit) assumes Kali defaults. Source only tools expect Debian packaging and paths. Chromium rebuilds on Gentoo are nightmare tier compile times. The tool ecosystem friction outweighs the benefits of a source-based distribution.

If it weren't for a few tools assuming Kali defaults (even if they don't have a systemd dependency), this would be done in Pentoo. But metasploit, SET, and some of the source available, no binary distribution tools make that a nightmare choice. And god forbid you need a chromium rebuild for something.

**When Pentoo makes sense:**

You have specific Gentoo workflow requirements. You're willing to patch and adapt tools for Gentoo. Compile times aren't a constraint for you.

---

## Tutorial Red Flags

### Signs a tutorial is outdated or cargo-cult:

- Presents UEFI vs legacy boot as a meaningful choice (2025+)
- Treats any distro not actively maintained as current options
- Conflates privacy/security/pen-testing/forensics distros
- Doesn't explain why specific choices are made
- Uses deprecated crypttab syntax (see Phase 0 corrections)
- Recommends RAID for single user workstations

The problem with these tutorials is they create cargo-culting. Someone copies a configuration because it looks cool, not realizing the implications. They might follow a ZFS tutorial without understanding they're taking on licensing complications (ZFS isn't GPL-compatible), out-of-tree kernel module maintenance, and different snapshot/backup workflows.

Or they might use systemd-boot without understanding they're diverging from Kali's default tooling and update mechanisms.

This documentation aims to prevent that by explaining what Kali and Debian default to and why, what alternatives exist, why specific choices were made, and what tradeoffs are being accepted.

---

**Document Status:** Living document. Will be updated as the landscape changes and new non-decisions emerge.

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*









