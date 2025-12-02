# Phase -1: Project Context and Distribution Choice

## What This Project Is

This documentation covers the complete bootstrap installation process for a Kali Linux pen-testing workstation, from encrypted partitions through live ISO creation. The goal is comprehensive documentation that explains not just what to do, but why specific choices are made, what alternatives exist, and what tradeoffs are being accepted.

This is a systematic approach to building a pen-testing workstation for:
- Security research and testing
- Malware analysis and development (in controlled environments)
- Professional penetration testing
- Learning offensive security techniques

The documentation emphasizes epistemological transparency. Each decision point is documented with the reasoning behind it, available alternatives, and accepted tradeoffs. This prevents cargo-culting where users blindly copy configurations without understanding the implications.

## Documentation Philosophy

This project follows four core principles:

### 1. No Gatekeeping

This documentation is for everyone interested in learning these topics. We cannot assume perfect enterprise training or college degrees for everyone interested in learning. I wasn't enterprise trained when I started and still haven't finished my bachelor's degree.

By presenting security topics as something that requires perfect understanding of unrelated methodologies, we create our own brain drain and potentially push people toward less ethical methods of learning.

**First principle: No gatekeeping.** If your answer to a question is "you don't know enough to ask that question," I have to wonder if you know enough to answer it. After all, if you can't explain something well enough to be understood, do you really understand the material?

### 2. Anti-Cargo-Culting Through Documentation

However, accessibility creates a second problem: cargo-culting. Copying configurations without understanding leads to brittle systems and security issues you can't debug.

**Second principle: Document the reasoning.** We attempt to document inline in configuration files where possible (this is not always feasible, and in those cases we provide separate files in the repository with wiki links in the markdown). Each choice is documented with why it was made, or where to seek further documentation when we are replicating someone else's choices and why we followed their logic.

At least with the reasoning documented, you will be more fairly armed to ask intelligent questions and make your own informed decisions.

### 3. Threat Model Boundaries

**Third principle: We cannot help you with individualized threat modeling.** This document assumes a threat model similar to mine (see separate threat modeling document for details).

If you are facing targeted threats from APT level adversaries, national intelligence agencies, or well-resourced organizations actively pursuing you as a specific target, this documentation cannot address your needs. Even if I sympathize with your situation, I cannot be responsible for your threat modeling in those circumstances. The operational security requirements are beyond the scope of technical setup documentation.

This project documents a pen-testing workstation setup for security research, malware analysis, professional testing, and learning offensive security techniques. The threat model focuses on privacy from commercial surveillance, protection against opportunistic attacks, and maintaining a secure research environment.

### 4. Topics Not Covered

**Fourth principle: Ethics and legality matter.** This documentation will not help you:
- Hack someone else's accounts or devices
- Track another person's physical location without their consent
- Develop malware for malicious purposes
- Engage in any legally questionable activities targeting others

Full stop. If you need the reasoning explained, this documentation isn't for you.

## Why Kali Linux?

### The Tool Ecosystem Problem

The fundamental constraint in choosing a pen-testing distribution is the tool ecosystem. Major security tools assume specific environments and distributions.

**Key tools that assume Kali defaults:**
- Metasploit Framework
- Social Engineering Toolkit (SET)
- Many source-available tools that expect Debian packaging and paths

These tools are maintained, updated, and tested against Kali. Using alternative distributions creates friction, requires patching, and often results in tools that simply don't work as expected.

### Alternative Distributions Evaluated

**Pentoo (Gentoo-based)**
- Technically viable for pen-testing
- Source-based distribution provides control
- Problems: Metasploit and SET assume Kali defaults, source-only tools expect Debian paths, Chromium rebuilds are nightmare compile times
- Tool ecosystem friction outweighs benefits

**Arch-based options**
- Arch-Strike: Dead project, no longer maintained
- Other Options: Unmaintained cargo-cult repository with some tools not updated since before Kali 1.0

**Privacy distros (TAILS, Whonix)**
- Wrong use case: designed for anonymity, not pen-testing
- Tools don't work, or work poorly

**Security distros (Qubes, KickSecure)**
- Wrong approach: hardened platforms where installing offensive tools undermines the security model
- Results in neither good pen-testing nor good compartmentalization

**Forensics distros (CAINE, Paladin, Tsurugi)**
- Different use case entirely
- All desperately need refreshing as of 2025

### The Debian Foundation

Kali is built on Debian Testing. This means:
- Kali inherits Debian's defaults: systemd, GRUB, ext4
- Kali follows Debian's development cycle
- Understanding Debian helps understand Kali

**Upcoming changes to be aware of:**
- Debian Forky is actively deprecating sysv compatibility during this development cycle (maintainers told to migrate now, not wait for freeze)
- Since Kali-rolling tracks Debian testing (Forky), this affects Kali immediately
- Kali's "network services disabled by default" policy currently relies on a custom `update-rc.d` wrapper (sysv-era tooling)
- Kali needs to migrate to systemd preset files or unit overrides to maintain this security policy
- BTRFS potentially becoming standard installer option during Forky development

### The Pragmatic Choice

We use Kali because we are doing pen-testing and need tool ecosystem compatibility. We accept Debian's and Kali's defaults as the cost of having maintained, working tooling.

The modular decisions documented in this project are about doing Kali well, not about whether to use Kali at all.

## Hardening Approach

Since malware development and analysis is part of the use case, the architectural approach is:

1. Start with the pen-testing foundation (Kali)
2. Layer in hardening and compartmentalization appropriate for malware analysis
3. Add anonymity layers (Whonix) if needed for specific operations

This is the correct approach versus trying to start with a hardened security platform (Qubes, KickSecure) and then undermining the security model by installing offensive tools.

**Hardening techniques covered in later phases:**
- Encrypted BTRFS setup with snapshots for rollback after malware testing
- Proper user separation and privilege management
- AppArmor profiles for risky applications
- Compartmentalization using VMs, containers, or namespaces as appropriate
- Network isolation for malware analysis

## Installation Approach: Bootstrap vs Installer

This documentation uses bootstrap installation (cdebootstrap/debootstrap) rather than the Kali installer for several reasons:

**Installer limitations:**
- Kali's partman-btrfs exists but defaults are suboptimal
- Multi-drive handling is problematic
- Less control over exact configuration

**Bootstrap advantages:**
- Complete control over partition layout
- Custom BTRFS subvolume configuration
- Better understanding of system components
- Easier to document decision points
- Reproducible builds

The tradeoff is complexity. Bootstrap requires more steps and more understanding. However, for a project emphasizing epistemological transparency and informed decision making, this tradeoff is acceptable.

## System Architecture Overview

The installation creates:

**Storage layer:**
- LUKS2 encrypted partitions
- Creation of keyfile for passwordless unlocking of file system with backup high entropy passphrase 
- BTRFS filesystem with flat subvolume layout
- Exploring appropriate BTRFS tuning based on subvolume use cases
- Snapshots at each phase for system rollback and backup as well as overall backup strategy

**Boot layer:**
- UEFI boot (legacy not covered, see Appendix)
- GRUB bootloader (Kali default)
- Encrypted boot partition for full disk encryption
- Keyfiles on seperate USB works for booting
- Configuring luks-nuke-password per Kali documentation

**System layer:**
- Debian/Kali base system
- systemd init (alternatives not viable, see Appendix)
- Modular configuration structure
- Intial Shell Setup(zshenv checks leaving PATH clear for automated login shells)

**Desktop layer:**
- Desktop environment choice (Phase 4 modular decision)
- XDG-compliant directory structure
- Modular shell configuration (Zsh with language-specific modules)

## Documentation Structure

The installation is divided into phases:

**Phase 0:** Encryption and partition setup
**Phase 1:** Partition layout and boot configuration  
**Phase 2:** Filesystem creation and mount structure
**Phase 3:** Base system installation
**Phase 4:** Desktop environment and graphical system
**Phase 5:** Network configuration and services
**Phase 6:** Package selection and tool installation
**Phase 7:** Live ISO creation (optional)

**Even-numbered phases** (0, 2, 4, 6) contain the most significant architectural decisions and are broken out into modular decision documents first.

**Odd-numbered phases** (1, 3, 5, 7) also contain important modular decisions and will be broken out as documentation continues.

**Appendix:** Eliminated alternatives and non-decisions explains why certain choices are not presented as options.

## Corrections and Iterative Refinement

This documentation incorporates lessons learned through iteration:

**Captured corrections include:**
- Removing Arch-specific kernel parameters that don't work on Debian
- Fixing deprecated crypttab syntax
- Adding USB timing delays for keyfile access
- Moving LUKS header backups to immediately after formatting for data loss prevention
- Platform-specific incompatibilities and their fixes

These corrections are integrated into the main documentation to prevent others from encountering the same issues.

## How to Use This Documentation

**For beginners:**
1. Read this Phase -1 for context
2. Follow Phases 0-7 in order
3. Reference modular decision documents when making choices
4. Skip the Appendix unless curious about alternatives

**For experienced users:**
1. Review Phase -1 and modular decision documents
2. Evaluate if choices match your needs
3. Reference Appendix to understand what was considered and rejected
4. Adapt as needed for your specific requirements

**For all users:**
- Don't cargo-cult: understand why each choice is made
- Check inline configuration comments for reasoning
- Follow wiki links to supporting documentation
- The goal is understanding, not just copying commands

## Next Steps

With project context established, proceed to Phase 0 to begin the installation process. Phase 0 covers encryption choices and is the first major architectural decision point.

---

**Document Status:** Living document. Will be updated as the project evolves and new context emerges.

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*

