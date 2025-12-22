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

### 2025-12-18
- **Mozilla in extrepo** - Mozilla repo IS available (thought it wasn't)
- **AppImage for OpenRC** - Primary recommendation (underestimated advantages)
- **Flatpak GUI Tools** - Warehouse and Flatseal exist for exploration

---

*These corrections inform the synthesized `corrections-lessons-learned.md` which provides professional documentation of all lessons learned.*
