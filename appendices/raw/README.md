# Raw Notes - WARNING

## What This Is

This directory contains **raw, unfiltered, stream-of-consciousness notes** from the actual installation process. These are the real-time recordings of what happened, mistakes made, and frustrations encountered.

## Content Warning

**These notes are NSFW.**

They contain profanity, frustrated venting, and the kind of language you'd hear in a NOC (Network Operations Center) when things go sideways at 3 AM. If you've worked in IT operations, you know exactly what this sounds like. If you haven't, consider yourself warned.

**Inside the NOC:** We all swear like 5th graders in a bathroom trying to impress their friends when the systems are on fire.

**Outside the NOC:** This is not professional documentation. This is the raw feed.

## Why These Exist

**Radical epistemological honesty** means documenting the real process, not a sanitized version.

These notes capture:
- The actual progression of the installation
- Real-time problem discovery
- Frustration when things break
- Relief when solutions work ("Just fucking works")
- In-the-moment research notes
- The thought process, unfiltered

**The value:** Future you (or others) can see what actually happened, not just the polished result.

## Example Files in This Directory

### actual-play.md
The step-by-step progression through the installation. Short, terse notes of what was done and when.

**Example entries:**
- "Identify drives lsblk"
- "Cryptsetup Hell"
- "Fuck it OpenRC"
- "Just fucking works"

### whoopsadoodle-bitch.md
Mistakes, corrections, and "oh shit" moments discovered during the process.

**Example entries:**
- "Can't actually do full drive encryption in uefi"
- "usb2 to slow for boot key"
- "Systemd failure, egg on face switch up"

## How to Use These

**If you're following this documentation:**
- Read the synthesized `corrections-lessons-learned.md` first
- Come here to see the raw source material
- Understand that frustration and mistakes are part of the process

**If you're contributing:**
- Feel free to add your own raw notes here
- Keep them unfiltered - that's the point
- Date them and note which installation/attempt they're from

**If you're easily offended by technical profanity:**
- Stay out of this directory
- Read the polished docs instead
- You were warned

## The Philosophy

From the main README:

> "If I can't document and replicate it, did I really do it?"

This applies to documenting failures and frustrations too. Sanitized documentation that only shows success is:
- Dishonest about the process
- Less useful for troubleshooting
- Doesn't prepare others for real-world challenges

**These raw notes are part of the documentation because they're part of the truth.**

## For Future Iterations

As the project evolves and installations are repeated:
- Create dated subdirectories for each attempt
- Keep the raw notes from each iteration
- Document what changed between attempts
- Track how the process improves (or doesn't)

**Structure example:**
```
raw-notes/
├── README.md (this file)
├── 2025-12-17-first-install/
│   ├── actual-play.md
│   └── whoopsadoodle-bitch.md
├── 2026-01-15-second-attempt/
│   └── notes.md
└── ...
```

## Legal Note

These raw notes are licensed under the same terms as the rest of the documentation (CC-BY-SA-4.0), but they're provided "as-is" with even less warranty than usual.

If you're offended by technical profanity, you chose to read files in a directory with a content warning. That's on you.

---

**Document Status:** Warning label for raw content

---

*You've been warned. Proceed at your own risk.*
