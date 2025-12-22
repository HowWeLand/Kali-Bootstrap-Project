# Correction: Mozilla Repository Availability in extrepo

**Date Discovered:** 2025-12-20  
**Impact:** Minor (changes recommendation)  
**Affects:** External-Repos-Decision-Matrix.md

---

## What Was Wrong

Documentation stated Mozilla repository was **NOT available in extrepo**:

```markdown
**The Firefox Case:**

Mozilla repo is NOT in extrepo (as of Dec 2024). Options:

1. **Use extrepo if Mozilla is added** (check: `extrepo search mozilla`)
2. **Add Mozilla repo manually** (more risk, see Category 4)
3. **Use Flatpak** (see Category 5) ← **RECOMMENDED**
```

## Why It Was Wrong

**Assumption made without verification.**

The documentation was written based on:
- General knowledge that extrepo is curated (doesn't have everything)
- Assumption that Mozilla wouldn't be in Debian's extrepo
- Not actually running `extrepo search mozilla` to check

**Classic mistake:** Stating something as fact ("is NOT in extrepo") without verifying.

## What's Correct

**Mozilla repository IS available in extrepo:**

```bash
extrepo search mozilla
# Output: mozilla - Mozilla packages

extrepo enable mozilla
apt update
apt install firefox
```

**However, there's a quirk:** extrepo requires sha256 verification of the GPG key itself (not just fingerprint):

```bash
# The process:
# 1. Download Mozilla's GPG key
wget https://packages.mozilla.org/apt/repo-signing-key.gpg

# 2. Get sha256 hash
sha256sum repo-signing-key.gpg
# Output: [hash] repo-signing-key.gpg

# 3. Verify against extrepo's expected hash
# extrepo has this hash in its database
# If it matches, repo is enabled
```

**This additional verification layer** ensures GPG key integrity during download - extrepo won't enable a repo if the GPG key doesn't match its expected sha256 hash.

## How We Discovered This

**User tested the actual command:**

```bash
extrepo search mozilla
```

And found Mozilla was actually available, contrary to what documentation claimed.

**The correction came from user feedback:**
> "I missed it earlier but... Mozilla IS available in extrepo"

**What happened:**
1. Documentation made assumption (Mozilla not in extrepo)
2. User ran actual command
3. Found Mozilla was available
4. Corrected the documentation

**This is exactly how it should work:** Test assumptions, correct errors, update docs.

## What Changed

### External-Repos-Decision-Matrix.md Update

**Category 3 (extrepo) Firefox section:**

```markdown
**The Firefox Case:**

**Mozilla repo IS available in extrepo:**

```bash
extrepo search mozilla
# Output: mozilla - Mozilla packages

extrepo enable mozilla
apt update
apt install firefox
```

**Note on sha256 verification:**
extrepo requires sha256 hash of the GPG key itself (not just fingerprint):

[details of verification process]

**Alternatives:** Flatpak (Category 5) or AppImage (Category 7) for latest Firefox
```

**Status changed:** Mozilla moved from "manual repo" territory to "curated extrepo" category.

### Recommendation Priority Update

**For OpenRC users, the updated priority is:**

1. **AppImage** (primary - zero daemon, full transparency)
2. **extrepo Mozilla repo** (if want native package)
3. **Flatpak** (if AppImage not available)
4. **firefox-esr** (Kali default, missing features)

**For systemd users:**

1. **Flatpak** or **extrepo Mozilla** (both good)
2. **AppImage** (also works, just different trade-offs)
3. **firefox-esr** (fallback)

## Lesson Learned

### Test Your Assumptions

**Don't state things as fact without verification.**

**Bad pattern:**
```markdown
Mozilla repo is NOT in extrepo (as of Dec 2024).
```

**Better pattern:**
```markdown
Check if Mozilla is in extrepo:
```bash
extrepo search mozilla
```

If not available, alternatives include...
```

**Let the user verify** rather than stating unverified facts.

### extrepo is More Comprehensive Than Expected

**Previous assumption:** extrepo is small, curated list of a few key repos.

**Reality:** extrepo includes many third-party repositories, including:
- Docker
- Mozilla
- Node.js
- PostgreSQL
- Many others

**Should have checked** before making statements about what's available.

### User Feedback is Valuable

**This correction came from user testing and feedback.**

Documentation can't catch everything. Users running commands and reporting back ("actually, this exists") improves accuracy.

**This is collaborative documentation at work:**
1. Initial docs based on knowledge/assumptions
2. Users test in real scenarios
3. Users provide corrections
4. Docs updated with reality
5. Future users benefit

**Git history will show this evolution.**

### The sha256 Quirk is Useful Knowledge

**Discovering Mozilla is in extrepo also revealed:**

extrepo's sha256 verification of GPG keys is **stricter than just checking fingerprints**.

**Why this matters:**
- Fingerprints verify the key itself
- sha256 of key file verifies the download integrity
- Extra protection against MITM during key download

**This is actually better security** than manual repo addition, where you might not verify the GPG key download integrity.

**Document the quirks** when you find them - they're valuable information.

---

## Related Decisions

This correction affects:

**Firefox installation choice:**
- Now three good options (AppImage, extrepo, Flatpak)
- Each with different trade-offs
- extrepo moves up from "risky manual" to "safe curated"

**extrepo evaluation:**
- Should be checked BEFORE assuming repos aren't available
- More comprehensive than initially thought
- Should be earlier in decision matrix

**Repository categorization:**
- Category 3 (extrepo) is larger than documented
- Should encourage checking extrepo first
- Manual repos (Category 4) should be last resort

---

**Status:** Corrected  
**Related Docs:** 
- External-Repos-Decision-Matrix.md (updated)
- Mozilla moved from Category 4 to Category 3

---

*This correction is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*
