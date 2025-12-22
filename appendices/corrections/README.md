# Corrections Directory

**What this is:** Documentation of mistakes, incorrect assumptions, and corrections made during the project.

**Why it exists:** 
- Shows the iterative learning process
- Prevents others from making the same mistakes
- Demonstrates honest acknowledgment of errors
- Provides context for why decisions changed

**How to read these:**
- Each file documents a specific correction
- Dated by when the mistake was discovered/corrected
- Explains what was wrong, why it was wrong, what's correct
- Shows the learning process, not just the final answer

**These are NOT:**
- Instructions to update other docs (that's inside baseball)
- Git commit messages (git history shows that)
- Comprehensive guides (see main docs for that)

**These ARE:**
- Lessons learned through iteration
- Mistakes made and corrected
- Assumptions challenged and updated
- Real-world experience documented

**Philosophy:** If you can't admit and document your mistakes, you don't really understand the problem space.

---

## Index of Corrections

### 2025-12-17
- **Init System Choice** - OpenRC is viable for multi-drive encrypted setups (was incorrectly dismissed)
- **Boot Partition Sizing** - Should be 10GB for live ISO storage (was 1GB)
- **nvme-cli Syntax** - Requires `-H` flag for human-readable output

### 2025-12-20
- **Mozilla in extrepo** - Mozilla repo IS available (thought it wasn't)
- **AppImage for OpenRC** - Primary recommendation (underestimated advantages)
- **Flatpak GUI Tools** - Warehouse and Flatseal exist for exploration

---

## Template for New Corrections

When adding a correction, use this structure:

```markdown
# Correction: [Topic]

**Date Discovered:** YYYY-MM-DD  
**Impact:** [Critical/Major/Minor]  
**Affects:** [Which documents/code]

---

## What Was Wrong
[Clear statement of the incorrect information/assumption]

## Why It Was Wrong
[Explanation of why the original was incorrect]

## What's Correct
[The corrected information]

## How We Discovered This
[The process that revealed the error]

## What Changed
[Concrete changes made to documentation/code]

## Lesson Learned
[The broader principle or insight]

---

**Status:** [Corrected/In Progress]  
**Related Docs:** [Links to affected documentation]
```

---

*These corrections inform the synthesized `corrections-lessons-learned.md` which provides professional documentation of all lessons learned.*

---

**Document Status:** Index of corrections  
**Updated:** As new corrections are added

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*
