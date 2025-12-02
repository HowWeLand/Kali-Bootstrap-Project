# Repository Structure

**Internal Reference Document** - Structure overview for maintainer reference.

## Directory Layout

```
Kali-Bootstrap-Project/
├── README.md                          # Project philosophy, overview, getting started
├── LICENSE.md                         # Combined licensing information
├── CONTRIBUTING.md                    # Contribution guidelines (TBD)
├── .gitignore                         # Comprehensive secret/cruft prevention
│
├── docs/                              # Core documentation (CC-BY-SA-4.0)
│   ├── phase-minus-1-project-context.md
│   ├── threat-model.md
│   ├── phase-0-foundation.md          # TBD: Bootable media, initial setup
│   ├── phase-1-encryption.md          # TBD: LUKS2, partition layout
│   ├── phase-2-filesystem.md          # TBD: BTRFS, subvolumes, mount structure
│   ├── phase-3-base-system.md         # TBD: Debootstrap, base packages
│   ├── phase-4-desktop.md             # TBD: GNOME/KDE, graphical system
│   ├── phase-5-network.md             # TBD: Network configuration, services
│   ├── phase-6-packages.md            # TBD: Kali tools, package selection
│   └── phase-7-live-iso.md            # TBD: Optional live ISO creation
│
├── appendices/                        # Supporting documentation (CC-BY-SA-4.0)
│   ├── appendix-non-decisions.md      # Eliminated alternatives, outdated approaches
│   ├── on-ai-usage.md                 # AI methodology transparency
│   └── corrections-lessons-learned.md # Pre-git mistakes and lessons
│
├── modular-decisions/                 # Broken-out decision documents (CC-BY-SA-4.0)
│   ├── encryption-choices.md          # TBD: LUKS2 config, cipher selection
│   ├── filesystem-decisions.md        # TBD: BTRFS vs alternatives
│   ├── desktop-environment.md         # TBD: GNOME vs KDE vs others
│   └── package-selection.md           # TBD: Metapackage strategies
│
├── configs/                           # Configuration files (mixed licensing)
│   ├── reference/                     # Example/reference configs (document license in headers)
│   │   ├── crypttab.example
│   │   ├── fstab.example
│   │   └── grub.example
│   └── custom/                        # Actual working configs (document license in headers)
│       ├── .zshrc
│       ├── ssh-config
│       └── README.md                  # Notes on custom configs
│
├── scripts/                           # Automation and tooling (MIT)
│   ├── bootstrap/                     # Bootstrap automation (future)
│   │   └── README.md                  # Explains bootstrap scripts
│   ├── deployment/                    # Deployment helpers (future)
│   │   └── README.md                  # Explains deployment tools
│   └── utilities/                     # Utility scripts (future)
│       └── README.md                  # Explains utility scripts
│
├── licenses/                          # Full license texts
│   ├── MIT.txt                        # MIT License full text
│   ├── CC-BY-SA-4.0.txt              # Creative Commons full text
│   └── GPL-3.0.txt                    # GNU GPL v3 full text
│
└── .git/                              # Git internals
    └── hooks/
        └── pre-commit                 # Secret prevention hook (install manually)
```

## Content Organization Principles

### Phase Documentation (Even Phases Priority)

**Even-numbered phases** (0, 2, 4, 6) contain the most significant architectural decisions and are broken out into modular decision documents first.

**Phase -1:** Project context (why Kali, methodology, threat model overview)  
**Phase 0:** Foundation (bootable media, BIOS/UEFI, initial partition setup)  
**Phase 1:** Encryption (LUKS2 configuration, keyfiles, headers)  
**Phase 2:** Filesystem (BTRFS subvolumes, mount structure) ← **Modular decisions**  
**Phase 3:** Base system (debootstrap, essential packages)  
**Phase 4:** Desktop (GNOME/KDE/other, graphical system) ← **Modular decisions**  
**Phase 5:** Network (configuration, services, firewall)  
**Phase 6:** Packages (Kali tools, metapackages) ← **Modular decisions**  
**Phase 7:** Live ISO (optional, creating bootable ISO)  

### Modular Decision Documents

Each major decision point is broken into a standalone document explaining:
- Available options
- Tradeoffs and implications
- Recommended choice for this use case
- How to evaluate alternatives for your needs

These reference the phase documentation but can be read independently.

### Configuration Files

**reference/**: Example configurations with extensive comments explaining each option. MIT licensed unless derivative of GPL software.

**custom/**: Actual working configurations from the bootstrap process. May contain personal preferences but should be documented. License depends on derivation status.

### Scripts

All automation in `/scripts` is MIT licensed. Organization by function:
- **bootstrap/**: Scripts to automate documented manual processes
- **deployment/**: Tools for deploying configurations
- **utilities/**: Helper scripts for common tasks

**Rule:** Scripts implement what documentation describes. Documentation comes first.

## File Naming Conventions

### Documentation Files
- Use `kebab-case-with-dashes.md`
- Phase files: `phase-N-description.md` (e.g., `phase-0-foundation.md`)
- Appendices: `appendix-description.md`
- Modular decisions: `specific-decision.md` (e.g., `encryption-choices.md`)

### Configuration Files
- Use standard config names where possible (`sshd_config`, `.zshrc`)
- Examples end in `.example` (e.g., `crypttab.example`)
- Add `.template` for templates meant to be filled in

### Scripts
- Use `kebab-case-with-dashes.sh` or `.py`
- Descriptive names: `bootstrap-encryption.sh`, `deploy-zsh-config.sh`
- Utilities: `check-luks-headers.sh`, `backup-configs.sh`

## Licensing Per Directory

| Directory | License | Why |
|-----------|---------|-----|
| `/docs` | CC-BY-SA-4.0 | Educational content, copyleft for improvements |
| `/appendices` | CC-BY-SA-4.0 | Educational content, copyleft for improvements |
| `/modular-decisions` | CC-BY-SA-4.0 | Educational content, copyleft for improvements |
| `/configs/reference` | MIT (or GPL if derivative) | Maximum flexibility for examples |
| `/configs/custom` | MIT (or GPL if derivative) | Share actual working configs |
| `/scripts` | MIT | Maximum flexibility for tooling |
| `/licenses` | N/A | License texts themselves |

## Git Workflow

### Branch Strategy
- `main`: Stable, tested documentation
- Feature branches: `feature/phase-N-description` or `feature/decision-name`
- Correction branches: `fix/issue-description`

### Commit Messages
```
type(scope): brief description

Longer description if needed, explaining why (not what, git diff shows what).

Fixes #issue-number (if applicable)
```

**Types:** docs, config, script, fix, refactor, chore

### Before Every Commit
1. Run pre-commit hook (should be automatic)
2. Check `git status` for unintended files
3. Review `git diff --cached` for secrets
4. Verify licensing headers present

### Before Every Push
```bash
# Scan for secrets (paranoia is good)
gitleaks protect --staged

# Visual confirmation
git log --oneline -5
git status
```

## Development Workflow

### Adding New Phase Documentation

1. Create `docs/phase-N-description.md`
2. Add CC-BY-SA footer
3. Identify modular decision points
4. Create separate documents in `modular-decisions/` if needed
5. Cross-reference between phase doc and modular decisions
6. Update README.md if phase structure changes

### Adding New Scripts

1. Create script in appropriate `/scripts` subdirectory
2. Add MIT license header with SPDX identifier
3. Add usage documentation in script header comments
4. Update relevant `/scripts/*/README.md`
5. Test script before committing
6. Document what phase/decision it implements

### Adding Configuration Files

1. Determine if derivative of GPL software (if yes, use GPL)
2. Add appropriate license header
3. Add extensive comments explaining each option
4. Add `.example` suffix if it's a reference, not actual config
5. Document in relevant phase or decision document

## Maintenance Tasks

### Regular
- Review open issues
- Respond to corrections/contributions
- Test scripts on fresh Kali install
- Update phase documentation based on corrections

### Periodic
- Review threat model for relevance (Debian Forky changes, new attacks)
- Check for outdated information (software versions, deprecated tools)
- Update modular decisions if new options become viable
- Scan for secrets (even with pre-commit hook, paranoia is good)

### Before Major Release/Announcement
- Verify all internal links work
- Spellcheck all documentation
- Test full bootstrap process
- Review licensing headers
- Update CONTRIBUTING.md with any new patterns
- Verify .gitignore is comprehensive

## Known Gaps (TBD)

### Documentation
- [ ] Phases 0-7 core content
- [ ] CONTRIBUTING.md with contribution guidelines
- [ ] Modular decision documents for major choices
- [ ] BTRFS tuning parameters (acknowledged gap)

### Scripts
- [ ] Bootstrap automation (Phase 2 goal)
- [ ] Deployment tooling
- [ ] Utility scripts for common tasks
- [ ] Testing framework for scripts

### Configurations
- [ ] Reference examples for all phases
- [ ] Custom configs with full documentation
- [ ] Templates for common scenarios

## Evolution Path

**Phase 1 (Current):** Core documentation
- Complete phase documents 0-7
- Break out major modular decisions
- Comprehensive threat model ✓
- Corrections/lessons learned ✓

**Phase 2:** Automation layer
- Scripts implement documented processes
- Config management integration
- Deployment tooling
- Everything builds on manual documentation

**Phase 3:** Advanced topics
- Hardening beyond base install
- Compartmentalization approaches
- Integration with other tools/workflows
- Advanced threat model scenarios

## Meta Notes

**This document is for maintainer reference only.** End users don't need to know the internal structure rationale - it should be obvious from organization once implemented.

**Keep this updated** as structure evolves. Document WHY decisions were made, not just WHAT the structure is.

**Structure serves philosophy:** "If I can't teach it, do I really understand it? If I can't document and replicate it, did I really do it?"

Organization should make teaching and replication natural.

---

*Internal document - not included in public distribution (or include if transparency serves the project)*
