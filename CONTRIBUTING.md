# Contributing to Kali-Bootstrap-Project

Thank you for your interest in contributing to this project. This guide outlines how to submit corrections, improvements, and new content while maintaining the project's philosophy.

## Project Philosophy

Before contributing, understand the core principles:

1. **No gatekeeping** - Make it accessible without dumbing it down
2. **No cargo-culting** - Explain WHY, not just WHAT
3. **Epistemological transparency** - Make assumptions explicit
4. **Document reasoning** - Every decision has a rationale
5. **Acknowledge tradeoffs** - No solution is perfect

**If you can't explain why something works, don't just provide the commands.**

## Types of Contributions

### Corrections

Found an error? Great! Submit a correction that includes:

1. **What's wrong** - Specific, with examples
2. **Why it's wrong** - Not just "doesn't work" but "here's the issue"
3. **The correction** - What should it be instead?
4. **Verification** - How you confirmed the fix

**Example of a good correction:**

```markdown
## Issue: Deprecated crypttab syntax

**What's wrong:**
Phase 1 uses `--hash sha512` in crypttab options.

**Why it's wrong:**
As of cryptsetup 2.0+, `--hash` has been replaced with `--pbkdf`.
Using `--hash` generates deprecation warnings and may break
in future versions.

**Correction:**
Replace:
`luks,discard,hash=sha512`

With:
`luks,discard,pbkdf=argon2id`

**Verification:**
Tested on Kali 2024.1 with cryptsetup 2.6.1.
```

### Improvements

Enhancing existing documentation:

- Clarifying confusing sections
- Adding examples
- Expanding explanations
- Improving organization

**Always explain WHY the improvement helps.**

### New Content

Adding new phases, modular decisions, or scripts:

- Follow existing structure and style
- Include reasoning and tradeoffs
- Provide alternatives considered
- Document assumptions explicitly
- Add proper licensing headers

## Licensing Your Contributions

By submitting contributions, you agree to license them under the project's existing licenses:

- **Documentation contributions:** CC-BY-SA-4.0
- **Script contributions:** MIT
- **GPL-covered config contributions:** GPL-3.0-or-later

You retain copyright but grant permission to distribute under these licenses.

See [LICENSE.md](LICENSE.md) for full details.

## Contribution Process

### 1. Fork and Branch

```bash
git clone https://github.com/[username]/Kali-Bootstrap-Project.git
cd Kali-Bootstrap-Project
git checkout -b fix/issue-description
# or
git checkout -b feature/new-content
```

### 2. Make Your Changes

**For documentation:**
- Follow existing markdown style
- Add licensing footer to new files
- Update internal links if structure changes
- Run spellcheck before committing

**For scripts:**
- Add MIT license header with SPDX identifier
- Include usage documentation in comments
- Test on fresh Kali install if possible
- Follow existing naming conventions

**For configurations:**
- Determine appropriate license (MIT or GPL)
- Add extensive comments explaining each option
- Note any platform-specific considerations

### 3. Test Your Changes

- Verify all internal links work
- Check markdown rendering (GitHub preview)
- For scripts: test on clean Kali install
- For configs: verify syntax and functionality

### 4. Commit with Clear Messages

```bash
git add [files]
git commit -m "type(scope): brief description

Longer explanation if needed.

Fixes #issue-number"
```

**Commit types:**
- `docs`: Documentation changes
- `fix`: Corrections to existing content
- `feat`: New content or features
- `config`: Configuration file changes
- `script`: Script additions or modifications
- `chore`: Maintenance tasks

### 5. Push and Create Pull Request

```bash
git push origin fix/issue-description
```

Then create a pull request on GitHub with:
- Clear description of changes
- Reasoning for the change
- Testing performed
- Any related issues

## Style Guidelines

### Documentation Style

**Do:**
- Explain WHY, not just WHAT
- Provide context for decisions
- Document alternatives considered
- Acknowledge tradeoffs
- Use clear, direct language
- Break complex concepts into digestible pieces

**Don't:**
- Assume reader knowledge without explanation
- Use jargon without defining it first
- Present opinion as fact
- Make unqualified absolute statements
- Skip over important details
- Be condescending or gatekeeping

### Code Style

**Scripts:**
- Use bash or Python 3
- Clear variable names
- Extensive comments
- Error handling
- Usage documentation in header

**Configurations:**
- Inline comments explaining each option
- Note platform-specific considerations
- Provide context for non-obvious choices
- Document sources for values

## What Makes a Good Contribution

### Good: Correction with Context

```markdown
## USB Keyfile Timing Issue

The current Phase 1 doesn't account for USB initialization delays.

**Problem:** If the keyfile is on a USB device, `initramfs` may
attempt to read it before the USB subsystem initializes, causing
boot failure.

**Solution:** Add `rootdelay=10` to kernel parameters to allow
USB initialization before cryptsetup attempts to read keyfile.

**Alternative:** Use `initramfs-tools` hooks to ensure USB
initialization. This is more complex but doesn't add artificial
delays on systems with non-USB keyfiles.

Tested on: [hardware], [Kali version]
```

### Bad: Unexplained Command

```markdown
Add this to grub:
rootdelay=10

It fixes the problem.
```

**Why it's bad:** No context, no explanation, no alternatives, no verification.

## Review Process

1. **Automated checks** - Linting, link checking, secret scanning
2. **Manual review** - Content, reasoning, style
3. **Discussion** - Questions, clarifications, improvements
4. **Revision** - Based on feedback
5. **Merge** - Once approved

**Reviews may request:**
- More context or explanation
- Alternative approaches
- Verification details
- Style adjustments

**This is normal.** The goal is quality, not speed.

## Recognition

Contributors will be:
- Credited in git history (automatic)
- Acknowledged in documentation where appropriate
- Listed in contributors file (if one is created)

Significant contributions may warrant co-authorship on specific documents.

## Questions?

- **Documentation unclear?** Open an issue asking for clarification
- **Unsure about contribution?** Open an issue to discuss before coding
- **Found a bug?** Document it in an issue with reproduction steps
- **Want to propose new content?** Open an issue to discuss structure first

## Anti-Patterns to Avoid

### Cargo-Cult Contributions

**Bad:**
"Here's a config I found that works great!"

**Good:**
"Here's a config that addresses [specific problem]. It works by [explanation]. Alternatives include [X, Y, Z]. I chose this because [reasoning]. Tradeoffs: [what you're accepting]."

### Gatekeeping Language

**Bad:**
"Anyone who doesn't understand this shouldn't be using Kali."

**Good:**
"This requires understanding [concept]. Here's a brief explanation: [explanation]. For deeper understanding, see [resource]."

### Unqualified Absolutes

**Bad:**
"This is the best way to do X."

**Good:**
"This approach to X has advantages: [list]. It has tradeoffs: [list]. Alternatives include [Y, Z] which may be better if [conditions]."

## Code of Conduct

**Be kind.** Be respectful. Be patient.

- Assume good faith in questions and corrections
- Remember: confusion often signals unclear documentation
- Don't mock or belittle questions
- Don't assume malice or incompetence
- Disagree without being disagreeable

**We're all learning.** That's the point.

## Legal Notes

### Not a Lawyer (NAL)

Contributors are encouraged to add "NAL" disclaimers when discussing legal or security topics outside their expertise.

**Example:**
"Based on my understanding of GPL, [explanation]. However, I'm not a lawyer (NAL). For legal certainty, consult actual legal counsel."

### Security Disclaimers

Security-related contributions should acknowledge limitations:

**Example:**
"This mitigates [specific threat] but does not protect against [other threats]. See threat model for applicability to your situation."

## Thank You

Quality contributions take time and effort. We appreciate:
- Your patience with the review process
- Your willingness to explain reasoning
- Your commitment to preventing cargo-culting
- Your contributions to collective knowledge

**Together, we can create documentation that actually teaches, not just tells.**

---

*This document is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/).*
