# Desktop Environment and Window Manager Taxonomy

## Philosophy

**"If I can't roast it, do I really understand it?"**

This is a comprehensive, brutally honest breakdown of the desktop environment and window manager landscape. Every choice has tradeoffs. Every DE has a personality type. Understanding these helps you make informed decisions rather than cargo-culting what's popular on /r/unixporn.

---

## The Desktop Environment Personality Matrix

### GNOME: Closeted Mac Envy

**What they say:**
"I appreciate GNOME's clean, focused design philosophy and lack of clutter."

**What they mean:**
"I want macOS but I'm too principled/cheap to buy a Mac."

**Evidence:**
- Removed minimize/maximize buttons (like macOS attempted)
- Activities corner (Exposé ripoff)
- Dock at bottom (macOS dock)
- "Everything should just work" philosophy (macOS philosophy)
- Removed customization options (like macOS, "we know best")
- App grid launcher (macOS Launchpad)
- Dropped the acronym (used to stand for GNU Network Object Model Environment)

**The "fractured tooling" complaint:**

GNOME users constantly lament: "Linux has too many competing standards! We need ONE way to do things!"

Translation: "macOS has one way, why can't Linux?"

**Reality:**
- macOS has one way because Apple controls everything
- Linux has many ways because freedom
- GNOME wants to be Apple but can't control the ecosystem
- Result: Eternal frustration

**GNOME Software (package manager):**
- Hides technical details (like Mac App Store)
- Simplifies everything (like macOS)
- Mixes Snap/Flatpak/system packages (confusing mess, no indication which is which)
- Won't show you dependencies (you don't need to know)
- Screenshots and ratings (like App Store)
- "Just click install" (don't ask questions)

**Perfect for:** People who want macOS UX on Linux but won't admit it

**Problems for power users:**
- Hides information you need
- Makes decisions for you
- Limited customization
- Heavy resource usage
- Breaking changes with updates

---

### KDE Plasma: Rainmeter Refugees

**What they say:**
"I enjoy KDE's flexibility and customization options."

**What they mean:**
"I spent 40 hours configuring Windows 7 with Rainmeter and I want to do it again."

**Evidence:**
- Everything is configurable (like Rainmeter)
- Widgets everywhere (like Rainmeter)
- Panel customization (Windows taskbar on steroids)
- 500 settings panels (Windows registry but with GUI)
- System tray icons (Windows notification area)
- "Make it look exactly how I want" (Rainmeter energy)

**The typical KDE workflow:**
```
Day 1:    Install KDE
Day 2-7:  Configure everything
Day 8:    Install more widgets
Day 9-10: Tweak colors and themes
Day 11:   Install latte-dock
Day 12-14: Configure latte-dock
Day 15:   Rice it perfectly
Day 16:   Screenshot for /r/unixporn
Day 17:   Rebuild from scratch because you broke something
```

**Stock KDE appearance:**
- Looks like Windows 95 had a baby with Windows Vista
- Blue and gray everywhere
- Oxygen theme (outdated)
- Weird font rendering
- Nobody uses stock KDE - it's meant as a blank canvas

**KDE Discover (package manager):**
- Shows technical details (for power users)
- Integrates Flatpak/Snap/native (confusing but honest)
- Lets you see dependencies (transparency)
- Multiple views and filters (customizable)
- Probably has a settings panel to configure the settings panel layout

**Perfect for:** Windows power users who discovered Rainmeter and think Windows could be good "if only I could configure it more"

**The Rainmeter connection:**

KDE Plasma IS Linux Rainmeter:
- Widgets (plasmoids) = Rainmeter skins
- Configurable everything = Rainmeter .ini files
- Scripting support (QML/JavaScript) = Rainmeter Lua
- System monitoring built-in
- Community themes
- Same personality type: Enjoys configuration as much as using the system

**Problems:**
- Too much configuration (can spend days tweaking)
- Easy to break
- Heavy resource usage
- Updates can break custom configs
- Never "done" configuring

---

### XFCE: The Professionals

**What they do:**
"Use Kali's devastatingly well-done XFCE config and maybe tweak window behavior for 30 minutes."

**Why this is correct:**

XFCE philosophy (done right):
```
"Here's a desktop that works.
It's fast.
It's stable.
It's configurable if you want.
But you don't HAVE to configure it for 8 hours.
Now go do actual work."
```

**Kali's XFCE config:**
- Actually well-thought-out (unlike stock anything)
- KDE compatibility layer enabled (Qt apps don't look broken)
- qterminal pre-configured (fast, Qt-based, no Konsole bloat)
- Panel-based but dock-friendly
- Window behavior that makes sense
- **Ships configured, not as blank canvas**
- Whisker Menu (better than rofi/dmenu)

**Why pen-testers choose XFCE:**
- Don't have time for KDE ricing
- GNOME hides too much (need technical info visible)
- Lightweight (runs in VMs well)
- Stable (doesn't break during critical work)
- Ships pre-configured (actually usable out of box)

**Perfect for:** People who need a desktop that doesn't get in the way of actual work

**The professional's approach:**
- Configure window tiling/timing once (30 minutes)
- Maybe tweak keybindings
- Never think about DE again
- Focus on actual work

**vs. KDE user:**
- Configure forever
- Tweaking IS the work
- Desktop is art project

**vs. GNOME user:**
- Accept defaults
- Complain when defaults don't work
- Extension hell

---

### LXDE/LXQt: People Who Hate Change

**Philosophy:** "If it was good enough for Windows XP, it's good enough for Linux."

**Characteristics:**
- Looks like Windows XP
- Acts like Windows XP
- Will always look like Windows XP
- Updates are: "Fixed a bug from 2008"

**Target audience:**
- People who peaked in 2004
- "Why would I want anything different?"
- "Change is bad"
- Corporate deployments that haven't updated since 2010

**Perfect for:** People whose ideal desktop was achieved in 2004 and see no reason to change

---

### Cinnamon: Windows That Doesn't Suck

**Philosophy:** "Windows 7 was peak desktop, we'll recreate it on Linux"

**Characteristics:**
- Windows 7 layout
- Panel at bottom
- Start menu that makes sense
- System tray that works
- Traditional workflow
- No surprises

**Target audience:**
- Windows refugees
- People who want familiar
- Linux Mint users

**Perfect for:** People who want Windows 7 but on Linux and without the Microsoft spyware

**Why it works:**
- Doesn't try to reinvent desktop (like GNOME)
- Doesn't try to be macOS (like GNOME)
- Doesn't require 8 hours of config (like KDE)
- Just works like Windows 7

---

### MATE: When GNOME Was Sane

**History:**
- GNOME 2 was good (1999-2011)
- GNOME 3 was terrible (2011-present)
- MATE forked GNOME 2 to preserve sanity
- "We'll keep it sane"

**What it is:**
- GNOME 2 but maintained
- Traditional desktop (panels, menus)
- Sensible defaults
- No Mac envy
- **What GNOME was before it became an acronym that nobody remembers**

**Target audience:**
- People who remember when GNOME was sane
- People who miss when GNOME stood for "GNU Network Object Model Environment"
- People who refuse GNOME 3's dumbing down

**Perfect for:** People who miss when GNOME was sane and an acronym

**The nostalgia factor:**
MATE users remember what was taken from them and refuse to forget.

---

### Deepin: GNOME in Qt + CCP Spyware

**What it looks like:**
- GNOME's Mac aesthetic
- But in Qt (because China)
- Actually quite pretty

**What it is:**
- Developed by Chinese company
- Sends telemetry to China
- Default search sends queries to Chinese servers
- "But it's so pretty!"

**Perfect for:** People who want macOS looks but are okay with the CCP having their data

**The irony:** Use Linux for privacy, install DE that phones home to China.

---

### Enlightenment: Drugs Required

**Experience:**
```
*Opens Enlightenment*
*Settings have settings*
*Settings for the settings have settings*
*Window decorations are animated*
*Everything bounces*
*Menus slide in from 4 dimensions*
*Question reality*
```

**What it is:**
What happens when developers discover 3D graphics and nobody says "maybe this is too much"

**Philosophy:** Acid trip as UI paradigm

**Perfect for:** People on drugs, or people who want to be

---

### Lumina: SPARCstation Nostalgia

**Characteristics:**
- Developed for FreeBSD (not Linux)
- Looks like CDE (1995 Unix desktop)
- "Lightweight and dependency-free!"
- No one uses it

**Target audience:**
- The 3 people who miss SPARCstations
- BSD users who hate change
- People who think "modern" peaked in 1995

**Philosophy:** "CDE was perfect, we just need to recreate it exactly."

**Perfect for:** People who miss the SPARCstation

---

### Herbstluftwm: Trolling as Design

**Characteristics:**
- Tiling window manager
- Configured via... sending commands to a Unix socket?
- Manual tiling (YOU decide where windows go)
- Name is German for "autumn window manager"

**Why it exists:**
```
Developer: "What if i3, but MORE confusing?"
Developer: "What if you had to manually tile?"
Developer: "What if configuration was through IPC?"
Developer: "Perfect. Ship it."
```

**Target audience:**
- People who think i3 is too simple
- People who want to confuse everyone who looks at their screen

**Perfect for:** People who can't resist the urge to fuck with people

---

### Blackbox: Self-Hatred as Workflow

**Characteristics:**
- Minimalist window manager from late 90s
- No window decorations
- No taskbar
- No system tray
- No nothing

**The experience:**
```
*Opens application*
*Window has no title bar*
*Can't move window*
*Can't resize window*
*Can't tell which window is active*
*Right-click for menu*
*Menu has 3 options*
*All are configuration*
```

**Philosophy:** "Desktop environments are bloat. I just need X11 and a menu."

**Reality:** Uses terminal multiplexer for everything because windows don't work right.

**Perfect for:** People who hate themselves

---

### Openbox: The LXDE Enabler

**What it is:**
- Window manager (not full DE)
- LXDE's default WM
- Configured via XML (yes, XML)

**Typical use:**
- Install LXDE
- LXDE uses Openbox
- Never think about it
- When it breaks, reinstall LXDE

**Standalone use:**
- Edit XML by hand
- Figure out why right-click menu doesn't show up
- Give up
- Install LXDE

**Perfect for:** People who use LXDE/LXQt (they're using it whether they know it or not)

---

## Window Manager Tier List

### i3: Ruined by i3gaps

**The original i3:**
- Tiling window manager
- Sensible defaults
- Config is readable
- Actually documented
- Still maintained

**The i3gaps problem:**

Timeline:
```
2009: i3 released (no gaps)
2014: i3gaps fork created (adds gaps between windows)
2015-2020: Everyone switches to i3gaps
2020: i3gaps maintenance slows
2022: i3gaps effectively dead
2024: Everyone still uses i3gaps
```

**The issue:**
- i3gaps became the de facto standard
- Everyone's configs/tutorials assume i3gaps
- Community moved to unmaintained fork
- Can't find pure i3 resources anymore
- i3 mainline won't merge gaps feature
- Wayland support via Sway (i3 for Wayland)

**The problem for people who want to use i3:**
```
"I want to use i3 mainline (maintained, secure, Wayland via Sway)"
Ecosystem: "Why? Everyone uses i3gaps"
"It's unmaintained and has security lag"
Ecosystem: "It still works!"
"For how long?"
Ecosystem: "¯\_(ツ)_/¯"
```

**Result:** Can't use i3 effectively because community knowledge is i3gaps-specific, dotfiles are i3gaps, troubleshooting assumes i3gaps features, and the gap aesthetic became required.

---

### dmenu and Replacements: User Hostility as Feature

**dmenu:**
- Launcher that shows programs alphabetically
- No features
- Configuration: Edit source code, recompile
- Documentation: "Read the source"

**Why people hate it:**
- No fuzzy search
- No icons
- No categories
- Requires recompiling to configure

**Philosophy:** "If you can't edit C code and recompile, you don't deserve a launcher."

**This is hostility disguised as minimalism.**

**rofi (the popular replacement):**
- Actually has features
- Configurable via config file
- Themes exist
- Everyone uses this instead

**The problem with both for certain workflows:**
- They search $PATH (all binaries)
- Shows command-line tools mixed with GUI apps
- For i3 users with 8 workspaces of terminals: Why search for CLI tools in a launcher?
- If you use CLI tools, you type them in terminals
- Only need launcher for GUI apps

---

### Awesome WM: Lua Config Hell

**What it is:**
- Window manager configured entirely in Lua
- "Very flexible!" (requires writing Lua programs)

**The experience:**
```lua
-- Want to switch window layouts?
-- First, understand the layout system:
awful.layout.suit.tile
awful.layout.suit.tile.left
awful.layout.suit.tile.bottom
awful.layout.suit.tile.top
awful.layout.suit.fair
awful.layout.suit.fair.horizontal
-- [... 20 more options ...]

-- Now write functions to switch between them
-- While understanding Lua closures
-- And Awesome's callback system
-- And the widget API
-- Just to switch layouts with a hotkey
```

**vs. i3:**
```
# Switch layout in i3 config:
Mod+e         # split horizontally
Mod+v         # split vertically  
Mod+s         # stacked
Mod+w         # tabbed
```

**The difference:** One is text config, one is programming.

**Perfect for:** People who like writing Lua more than using their computer

---

## The Complete Hierarchy

### Tier 1: For People Doing Actual Work
- **XFCE** (especially Kali's config) - Professionals
- **i3** (mainline, if gaps weren't the ecosystem standard) - Efficient tiling
- **Cinnamon** (if you want traditional and familiar) - Windows refugees

### Tier 2: For People Who Enjoy Configuration
- **KDE Plasma** (Rainmeter energy) - Configure everything forever
- **Awesome WM** (if you like Lua) - Programming as configuration
- **bspwm** (if you like shell scripts) - Scriptable tiling

### Tier 3: For People With Specific Ideologies
- **GNOME** (Mac envy) - Want macOS, won't admit it
- **MATE** (GNOME nostalgia) - Remember when GNOME was sane
- **Enlightenment** (drugs) - Visual overload as philosophy

### Tier 4: For People Who Hate Themselves
- **Blackbox** (minimalism as punishment) - No features is a feature
- **dwm** (must recompile to configure) - Edit C, recompile, repeat
- **ratpoison** (no mouse allowed) - Keyboard-only masochism

### Tier 5: For People Who Hate Others
- **Herbstluftwm** (trolling) - Confuse everyone
- **wmii** (confusing on purpose) - Deliberately obtuse
- **EXWM** (Emacs as window manager) - Yes, really

### Tier 6: For People Who Hate Change
- **LXDE/LXQt** (Windows XP forever) - 2004 was peak
- **Lumina** (CDE forever) - 1995 was peak
- **TWM** (1988 forever) - X11 reference implementation

### Tier 7: For People With Other Problems
- **Deepin** (CCP surveillance) - Pretty but phones home to China
- **Unity** (Ubuntu's failed experiment) - Dead
- **Pantheon** (elementary OS) - macOS clone #2

---

## Key Takeaways

**The choice of desktop environment reveals personality:**
- GNOME users want decisions made for them (Mac envy)
- KDE users want to make ALL decisions (Rainmeter energy)
- XFCE users want to work (professional choice)
- i3 users want efficiency (ruined by gaps)
- Tiling WM users value keyboard control
- Ancient WM users value stability/simplicity

**There is no "best" desktop environment.** There are only:
- Tradeoffs that match your workflow
- Personality types that fit different philosophies
- Use cases that benefit from specific features

**The professionally correct choice for security/pen-testing work:**
XFCE with Kali's configuration - it's pre-configured by people who actually use it for work, not for screenshots.

**The enthusiast choice:**
Whatever you want to spend 40 hours configuring. KDE if you like GUI configuration, tiling WM if you like text configs, Awesome if you like Lua.

**The "I just want it to work" choice:**
Cinnamon or MATE - traditional, familiar, stable, boring in the best way.

**The "I want to look cool" choice:**
i3gaps (dead), Awesome WM (Lua hell), or heavily riced KDE (maintenance nightmare).

**Understanding these tradeoffs prevents cargo-culting** - copying someone's setup because it looks cool on /r/unixporn without understanding whether it fits your actual workflow.
