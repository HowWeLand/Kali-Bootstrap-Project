# Kali Bootstrap Documentation

## Philosophy

**If I can't teach it, do I really understand it?**

**If I can't document and replicate it, did I really do it?**

This project is built on the principle that true understanding requires three things:

1. **Documentation** - Forces deep enough understanding to explain clearly
2. **Replication** - Proves the documentation is complete and correct
3. **Teaching** - Tests whether you actually understand or just memorized

If you can't do all three, you're cargo-culting.

This philosophy drives every aspect of this project: from the systematic phase documentation to the modular decision points to the explicit acknowledgment of what we don't know.

## What This Project Is

A systematic, reproducible approach to Kali Linux installation from encrypted partitions through live ISO creation. This is not a quick-start guide. This is comprehensive documentation that explains:

- **What** to do (the actual commands and configurations)
- **Why** specific choices are made (the reasoning and tradeoffs)
- **What alternatives** exist (and why they were rejected or accepted)
- **What assumptions** underlie the decisions (so you can evaluate if they fit your needs)

The goal is **epistemological transparency**: preventing cargo-culting by documenting the decision-making process, not just the final configuration.

## What This Project Is Not

- **Not a tutorial to blindly follow** - You should understand each decision
- **Not "best practices"** - These are informed choices with documented tradeoffs
- **Not comprehensive security guidance** - See the threat model document for scope
- **Not a replacement for understanding** - This is a learning tool, not a shortcut

## Project Status

**Active Development** - Currently documenting phases 0-7 of the bootstrap installation process, with modular decision documents being broken out as work progresses.

## Documentation Structure

### Core Documentation

**[Phase -1: Project Context](docs/phase-minus-1-project-context.md)**
- Why Kali? (Distribution choice and rationale)
- Use case definition (pen-testing, malware analysis)
- Threat model overview
- Documentation methodology

**Phases 0-7: Installation Process**
- Phase 0: Encryption and partition setup
- Phase 1: Partition layout and boot configuration
- Phase 2: Filesystem creation and mount structure
- Phase 3: Base system installation
- Phase 4: Desktop environment and graphical system
- Phase 5: Network configuration and services
- Phase 6: Package selection and tool installation
- Phase 7: Live ISO creation (optional)

Even-numbered phases (0, 2, 4, 6) contain the most significant architectural decisions and are being broken out into modular decision documents first.

### Supporting Documentation

**[Threat Model](docs/threat-model.md)**
- Four-tier threat model from opportunistic attackers to APT/nation-state
- What this documentation can and cannot protect against
- How to determine your own threat model

**[Appendix: Eliminated Alternatives and Non-Decisions](docs/appendix-non-decisions.md)**
- Choices that are not presented as options (and why)
- Outdated approaches and dead projects
- Tutorial red flags to watch for

**[On the Use of AI](docs/on-ai-usage.md)**
- How AI was used in this documentation project
- What AI does vs what human expertise provides
- Why this matters for documentation quality

### Modular Decision Documents

As phases are documented, significant decision points are broken out into standalone documents:

- Encryption choices (LUKS2 configuration, cipher selection)
- Filesystem decisions (BTRFS vs alternatives)
- Desktop environments (GNOME vs KDE vs others)
- Package selection strategies

Each modular document explains:
- Available options
- Tradeoffs and implications
- Recommended choice for this use case
- How to evaluate alternatives for your needs

## No Gatekeeping, No Cargo-Culting

### No Gatekeeping

This documentation is for everyone interested in learning, regardless of background. You don't need:
- Enterprise training
- A college degree
- Perfect understanding of unrelated methodologies
- To already be an expert

If someone says "you don't know enough to ask that question," they probably don't know enough to answer it. If you can't explain something clearly enough to be understood, you don't really understand it.

### No Cargo-Culting

However, accessibility should not mean blind copying of configurations. This documentation prevents cargo-culting by:

- Explaining **why** each choice is made
- Documenting **what alternatives** exist
- Describing **what tradeoffs** are accepted
- Providing **enough context** to make informed decisions

You should understand what you're doing and why. If something breaks, you should be able to debug it because you understand the underlying system.

## Corrections and Iterative Refinement

This documentation incorporates lessons learned through iteration. Mistakes are documented, not hidden:

- Removed Arch-specific kernel parameters that don't work on Debian
- Fixed deprecated crypttab syntax
- Added USB timing delays for keyfile access
- Moved LUKS header backups to immediately after formatting
- Platform-specific incompatibilities and their fixes

The `corrections/` directory contains detailed explanations of what went wrong and how it was fixed. This is part of the learning process.

## Use of AI in This Project

This documentation was developed through an iterative research and synthesis process using AI as a research assistant and technical writing aid.

**AI handles:**
- Markdown formatting and structure
- Organizing scattered knowledge into coherent flow
- Maintaining consistent voice and tone

**I provide:**
- All technical decisions and reasoning
- Domain expertise (Debian ecosystem, Kali specifics, security)
- Verification against authoritative sources
- Corrections when assumptions prove incorrect

AI is a tool for documentation, not a replacement for knowledge. See [On the Use of AI](docs/on-ai-usage.md) for complete methodology.

## Target Audience

**Primary:** People who want to understand Kali Linux installation at a deep level, not just get it working.

**Secondary:** Experienced users evaluating whether this approach fits their needs and threat model.

**Tertiary:** Anyone interested in systematic technical documentation methodology.

If you just want Kali installed quickly, use the official installer. If you want to understand what you're building and why, this documentation is for you.

## Contributing

This project welcomes contributions that maintain the core philosophy:

- **Document the reasoning** - Don't just provide commands, explain why
- **Acknowledge tradeoffs** - No solution is perfect, document what you're accepting
- **Maintain epistemological transparency** - Make assumptions explicit
- **No gatekeeping** - Make it accessible without dumbing it down
- **Prevent cargo-culting** - Provide enough context for informed decisions

See CONTRIBUTING.md for detailed guidelines.

## Roadmap

**Phase 1: Core Documentation (Current)**
- Complete phases 0-7 base documentation
- Break out all major modular decision points
- Comprehensive threat model
- Correction/lessons learned integration

**Phase 2: Automation Layer**
- Scripts to automate documented manual processes
- Config management integration
- Deployment tooling
- Everything builds on the manual documentation

**Phase 3: Advanced Topics**
- Hardening strategies beyond base install
- Compartmentalization approaches
- Integration with other tools and workflows
- Advanced threat model scenarios

The documentation comes first. Automation implements what's documented. This ensures we understand the system before we script it.

## Related Projects

**[Security-Lab-Infrastructure](https://github.com/[username]/Security-Lab-Infrastructure)** [ARCHIVED]
- Exploratory work that led to this systematic approach
- Contains proof-of-concept scripts with useful patterns
- Reference material, not active development

## License

[Choose appropriate license - MIT, GPL, CC-BY-SA, etc.]

## Contact

[Your preferred contact method]

---

**Remember:** If you can't teach it, you don't understand it. If you can't document and replicate it, you didn't really do it.

This documentation is an attempt to actually understand Kali Linux installation, not just get it working.
