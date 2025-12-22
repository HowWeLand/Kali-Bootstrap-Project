# Kali Bootstrap Project - Documentation Index

**Last Updated:** December 17, 2025

This index catalogs all documentation in the project, organized by purpose and phase.

---

## Core Philosophy Documents

### README.md
**Purpose:** Project overview, philosophy, and getting started  
**Key Concepts:**
- "If I can't teach it, do I really understand it?"
- "If I can't document and replicate it, did I really do it?"
- No gatekeeping, no cargo-culting
- Epistemological transparency

**Audience:** Everyone - read this first

---

## Project Status & Corrections

### Kali-Bootstrap-Project-Status.md
**Purpose:** Current state of the project and system  
**Contents:**
- System architecture overview
- OpenRC conversion success story
- Complete installation summary
- What's working, what's pending
- Outstanding decision points

**Status:** Living document, updated as project evolves

### CORRECTION-Init-System-Choice.md
**Purpose:** Major correction acknowledging OpenRC is viable  
**Why Critical:**
- Original docs dismissed OpenRC as "not viable"
- Real testing proved systemd fails for multi-drive encrypted setups
- OpenRC solves the problem completely
- Documents the learning process honestly

**Git Impact:** Major - changes primary installation path

**Key Lesson:** Document what actually works, not what should theoretically work

---

## Decision Matrices & Guides

### External-Repos-Decision-Matrix.md
**Purpose:** How to add external packages without creating FrankenKali  
**Contents:**
- 8 package source categories (Kali repos → Flatpak → manual)
- When to use which package source
- Prevention of dependency hell

**Use When:** Considering any package not in Kali repos

---

## Phase Documentation

### Phase Structure Overview

**Phase 0:** Hardware Decisions & Planning  
- Choose drives, encryption settings, filesystem layout
- Create configuration file
- Output: Config ready for automation

**Phase 1:** Destructive Operations → Bootable System  
- Secure erase, partition, encrypt, bootstrap
- **Automated via script**
- Output: System boots to TTY

**Phase 2:** Pre-Boot Customization (In Chroot)  
- XDG environment setup
- Tool installation
- User creation
- Output: Customized system ready for first boot

**Phase 3+:** Post-Boot Configuration  
- Network, desktop, development tools
- Security hardening

### docs/Phase-2-Pre-Boot-Customization.md
**Purpose:** What to do after Phase 1, before first boot  
**Key Topics:**
- ".local is a dumb @*#$!% idea" - XDG path customization
- Eliminating dotfile sprawl
- Tool installation (htop, ncdu, lnav, tmux/byobu)
- System-level defaults via /etc/skel
- Modular zsh deployment

**Opinionated:** Strong preferences with reasoning

---

## Configuration & Setup

### zsh-configs/
**Complete modular Zsh configuration**

**Contents:**
- `zshenv` - Minimal environment variables
- `user_profile.zsh` - Modular loader
- `aliases/` - Safe file ops, apt tagging, colors, GPG
- `env/` - Language environments (Python, Rust, Ruby, Go, JS)
- `DEPLOYMENT.md` - How to install
- `KALI_DEFAULT_ZSHRC.md` - Reference for Kali integration

**Philosophy:** Extends Kali's default, doesn't replace it

**XDG Compliant:** Custom paths to eliminate `.local` sprawl

---

## Automation Scripts

### scripts/phase1-automated-install.sh
**Purpose:** Complete automation of Phase 1  
**Features:**
- Variables at top (user edits, no interactive prompts except passwords)
- Serial number verification (prevents wrong-drive disasters)
- nvme-cli for NVMe secure erase
- smartmontools for SATA SSD secure erase
- OpenRC bootstrap from the start
- Extensive safety checks
- Color-coded logging
- Generates chroot finalization script

**Boot Partition Size:** 10G (for future live ISO storage)

**Critical:** Edit variables before running, especially drive paths and serials.  Edit the serials only if you're 

### docs/Script-Architecture.md
**Purpose:** Script design principles and patterns  
**Contents:**
- Why we edit variables instead of prompting
- Safety check patterns
- Error handling strategies
- Testing approach (syntax → VM → real hardware)
- Hardware quirks (NVMe, SATA freeze states)
- Recovery procedures

**Read Before:** Writing any automation scripts

---

## Documents from System Prompt (Referenced)

These documents are part of the project but were provided via system prompt:

### docs/phase-minus-1-project-context.md
**Purpose:** Why Kali? Distribution choice and rationale  
**Contents:**
- Use case definition (pen-testing, malware analysis)
- Why Kali over alternatives (Pentoo, Arch-based, etc.)
- Threat model overview
- Documentation methodology
- Bootstrap vs installer approach

**Note:** Needs updating to reflect OpenRC as viable option

### docs/threat-model.md
**Purpose:** Define what threats this documentation addresses  
**Structure:**
- Part 1: APT/Nation-State (outside our scope)
- Part 2: Regional Advanced Threats (limited protection)
- Part 3: Motivated Local Adversaries (effective protection)
- Part 4: Opportunistic Attackers (fully protected)

**Critical:** Helps readers determine if this setup matches their needs

### appendices/appendix-non-decisions.md
**Purpose:** Choices that are NOT presented as options  
**Contents:**
- UEFI vs Legacy (Legacy is obsolete)
- Distribution alternatives (why not Pentoo, BlackArch, etc.)
- Init systems (originally said OpenRC not viable - NEEDS CORRECTION)
- Filesystem choices (RAID, ZFS)

**Status:** Requires major revision per CORRECTION-Init-System-Choice.md

### appendices/on-ai-usage.md
**Purpose:** Transparency about AI in documentation  
**Contents:**
- What AI handles (formatting, structure, organization)
- What human provides (decisions, expertise, verification)
- Why this matters (quality over quantity)
- Conversations we're NOT having (singularity, etc.)

**Philosophy:** AI is a tool for documentation, not replacement for knowledge

### appendices/corrections-lessons-learned.md
**Purpose:** Mistakes and how they were fixed  
**Contents:**
- Deprecated crypttab syntax
- Arch-specific kernel parameters
- USB timing issues
- LUKS header backup timing
- Assumption corrections (systemd vs OpenRC)

**Growing Document:** Updated as mistakes discovered and corrected

---

## Documents To Create

Based on CORRECTION-Init-System-Choice.md, these are needed:

### docs/decision-init-system.md
**Purpose:** systemd vs OpenRC comparison  
**Needed:**
- When to use each
- Trade-offs clearly explained
- Desktop environment compatibility
- Service management differences

### docs/openrc-installation.md
**Purpose:** OpenRC installation from bootstrap  
**Needed:**
- Bootstrap command with OpenRC from start
- Why this is cleaner than converting
- Service configuration
- Troubleshooting

### docs/openrc-conversion-from-systemd.md
**Purpose:** Converting existing systemd to OpenRC  
**Needed:**
- Tested procedure (the one that worked)
- Chroot from live environment
- Step-by-step with verification
- Recovery if it fails

---

## Phase Breakout Documents (Planned)

### Phase 0 Breakouts
- ✅ why-parted.md (partitioning tool choice)
- ✅ why-luks2.md (encryption choice)  
- 🔲 why-btrfs.md (filesystem choice)
- 🔲 keyfile-strategy.md (USB vs TPM vs manual)

### Phase 2 Breakouts
- 🔲 firewall-choice.md (nftables, ufw, firewalld)
- 🔲 mac-framework.md (AppArmor, SELinux)

### Phase 4 Breakouts
- 🔲 desktop-environment.md (XFCE, KDE, GNOME comparison)
- 🔲 display-manager.md
- 🔲 wayland-vs-x11.md

### Phase 6 Breakouts
- 🔲 language-version-managers.md
- 🔲 xdg-compliance-tools.md
- 🔲 virtual-environment-strategies.md

---

## Organization by Audience

### For Beginners
**Start Here:**
1. README-new-repo.md (philosophy)
2. docs/phase-minus-1-project-context.md (why Kali)
3. docs/threat-model.md (is this for you?)
4. Follow phases in order

**Skip:** Appendices (unless curious about alternatives)

### For Experienced Users
**Start Here:**
1. Kali-Bootstrap-Project-Status.md (current state)
2. CORRECTION-Init-System-Choice.md (major change)
3. Review phase docs and breakouts
4. Adapt as needed

**Pay Attention To:** Decision matrices, trade-offs documented

### For Troubleshooting
**Go To:**
1. appendices/corrections-lessons-learned.md (common mistakes)
2. docs/Script-Architecture.md (recovery procedures)
3. Kali-Bootstrap-Project-Status.md (what should be working)

### For Contributing
**Read:**
1. README-new-repo.md (philosophy - must maintain)
2. appendices/on-ai-usage.md (transparency)
3. All correction documents (learn from mistakes)
4. CONTRIBUTING.md (when it exists)

---

## File Organization

```
Kali-Bootstrap-Project/
├── README-new-repo.md                    # Start here
├── LICENSE.md                            # Not created yet
├── CONTRIBUTING.md                       # Not created yet
├── Kali-Bootstrap-Project-Status.md      # Current state
├── CORRECTION-Init-System-Choice.md      # Major correction
├── External-Repos-Decision-Matrix.md     # Package sources
│
├── docs/                                 # Phase documentation
│   ├── phase-minus-1-project-context.md  # Why Kali
│   ├── threat-model.md                   # Threat model
│   ├── Phase-2-Pre-Boot-Customization.md # Phase 2 procedure
│   ├── Script-Architecture.md            # Script design
│   └── [phase 0-7 docs to be created]
│
├── appendices/                           # Supporting docs
│   ├── appendix-non-decisions.md         # Eliminated alternatives
│   ├── on-ai-usage.md                    # AI transparency
│   └── corrections-lessons-learned.md    # Mistakes fixed
│
├── scripts/                              # Automation
│   └── phase1-automated-install.sh       # Phase 1 automation
│
├── zsh-configs/                          # Modular zsh
│   ├── DEPLOYMENT.md
│   ├── KALI_DEFAULT_ZSHRC.txt
│   ├── zshenv
│   ├── user_profile.zsh
│   ├── aliases/
│   └── env/
│
└── [future directories]
    ├── configs/                          # Reference configs
    ├── modular-decisions/                # Breakout docs
    └── package-lists/                    # Reproducible installs
```

---

## Search Strategy

**When you need to find something:**

### By Topic
- **Init systems:** CORRECTION-Init-System-Choice.md, appendix-non-decisions.md
- **Packages:** External-Repos-Decision-Matrix.md
- **XDG/dotfiles:** Phase-2-Pre-Boot-Customization.md, zsh-configs/
- **Encryption:** phase-minus-1 (when created), threat-model.md
- **Scripts:** Script-Architecture.md, scripts/
- **Tools:** Phase-2-Pre-Boot-Customization.md
- **Mistakes:** corrections-lessons-learned.md, CORRECTION-*.md

### By Phase
- **Phase 0:** Decision docs (to be created)
- **Phase 1:** scripts/phase1-automated-install.sh
- **Phase 2:** Phase-2-Pre-Boot-Customization.md
- **Phase 3+:** To be documented

### By Question Type
- **"Why?"** → README, phase-minus-1, decision matrices
- **"How?"** → Phase docs, scripts
- **"What went wrong?"** → corrections-lessons-learned.md
- **"What changed?"** → CORRECTION-*.md files
- **"Is this safe?"** → threat-model.md, External-Repos-Decision-Matrix.md

---

## Document Status Key

- ✅ **Complete** - Fully documented, tested, ready
- 🔲 **Planned** - Identified need, not yet created
- ⚠️ **Needs Update** - Exists but requires correction (see CORRECTION docs)
- 🚧 **In Progress** - Being actively worked on

---

## Maintenance

**This index should be updated when:**
- New documents are created
- Major corrections are made
- Organization changes
- New phases are documented

**Last comprehensive review:** December 17, 2025

---

## Project Principles (Reminder)

Every document in this project follows:

1. **No gatekeeping** - Accessible without dumbing down
2. **No cargo-culting** - Explain WHY, not just WHAT
3. **Epistemological transparency** - Make assumptions explicit
4. **Document reasoning** - Every decision has rationale
5. **Acknowledge tradeoffs** - No solution is perfect
6. **Honest about mistakes** - Corrections are part of learning

**If a document doesn't follow these principles, it needs revision.**

---

**Next Steps:**

1. Create missing OpenRC documentation (per CORRECTION-Init-System-Choice.md)
2. Update appendix-non-decisions.md (remove OpenRC dismissal)
3. Create phase 0-7 documentation
4. Break out modular decisions
5. Test Phase 1 script and document findings

---

*This index is part of the project documentation and is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/).*
