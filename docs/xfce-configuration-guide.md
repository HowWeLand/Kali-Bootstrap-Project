# XFCE Configuration for Kali Bootstrap

## Philosophy

XFCE is the professional's desktop environment. It's fast, stable, and configurable enough without requiring days of tweaking. Kali's XFCE configuration is "devastatingly well-done" - pre-configured by people who actually do pen-testing work, not ricing for screenshots.

This guide covers:
- Why XFCE over other DEs
- Window tiling configuration (i3-style keybindings)
- Panel organization and launcher stacking
- Whisker Menu (better than rofi/dmenu)
- Terminal configuration (qterminal)
- Essential tweaks for efficient workflow

---

## Why XFCE for Security/Pen-Testing Work

### The Requirements

**What pen-testing/security work needs:**
- **Stability** - System can't break mid-assessment
- **Performance** - Often running in VMs or on old hardware
- **Information visibility** - Need technical details accessible
- **Keyboard efficiency** - Fast, keyboard-driven workflow
- **Lightweight** - Minimal resource usage

**Why XFCE delivers:**
- Rock-solid stability across updates
- Low resource usage (< 500 MB RAM)
- Configurable without being overwhelming
- Traditional workflow (no relearning)
- Kali's config is actually good out-of-box

### Why NOT Other DEs

**GNOME:**
- ✗ Hides technical information
- ✗ Heavy resource usage
- ✗ Breaking changes with updates
- ✗ Limited customization
- ✗ Designed for "simplicity" not efficiency

**KDE:**
- ✗ Too much configuration (distraction)
- ✗ Heavy for VMs
- ✗ Easy to break during tweaking
- ✗ Updates can break custom configs
- ✗ Never "done" configuring

**i3/tiling WMs:**
- ✗ i3gaps is unmaintained (security lag)
- ✗ i3 mainline lacks gaps (community expects them)
- ✗ Learning curve (new paradigm)
- ✗ XFCE can replicate most of the benefits

**XFCE hits the sweet spot:**
- Stable + lightweight + efficient + pre-configured

---

## Initial XFCE Setup

### Installation (Phase 4)

```bash
# XFCE desktop environment
apt install xfce4 xfce4-goodies

# Essential additions
apt install xfce4-whiskermenu-plugin  # Application launcher
apt install thunar thunar-volman thunar-archive-plugin  # File manager
apt install xfce4-terminal  # Backup terminal (qterminal is primary)

# Optional but recommended
apt install xfce4-clipman-plugin  # Clipboard manager
apt install xfce4-screenshooter  # Screenshot tool
apt install xfce4-taskmanager  # Task manager
```

**On Kali:** Already included and pre-configured. This section is for reference or custom builds.

### First Boot Configuration

**Kali's XFCE config is good out-of-box. You'll want to tweak:**

1. Window tiling/timing behavior (30 minutes)
2. Panel launcher organization (stacking related apps)
3. Keyboard shortcuts (i3-style if desired)
4. Terminal settings (cursor blink off)

**Don't change:** The overall layout, theme, or defaults unless you have specific needs. Kali's choices are well-considered.

---

## Window Tiling Configuration

### Built-in Tiling Shortcuts

**XFCE has tiling built-in:**

```bash
# Access via:
Settings Manager → Window Manager → Keyboard

# Default keybindings (may vary):
Super + Left      # Tile window to left half
Super + Right     # Tile window to right half  
Super + Up        # Maximize window
Super + Down      # Restore window size
```

### i3-Style Keybindings (Optional)

**If you want i3-like behavior:**

**Settings Manager → Window Manager → Keyboard**

**Focus movement (vim-style):**
```
Super + h         # Focus left
Super + j         # Focus down
Super + k         # Focus up
Super + l         # Focus right
```

**Window movement:**
```
Super + Shift + h # Move window left
Super + Shift + j # Move window down
Super + Shift + k # Move window up
Super + Shift + l # Move window right
```

**Tiling actions:**
```
Super + v         # Tile vertically (custom script)
Super + s         # Tile horizontally (custom script)
Super + f         # Fullscreen toggle
Super + Shift + Space  # Toggle floating
```

**Workspace switching:**
```
Super + 1-9       # Switch to workspace 1-9
Super + Shift + 1-9  # Move window to workspace 1-9
```

### Quarter-Tiling (Advanced)

**For corner tiling, use xdotool scripts:**

```bash
# Create: ~/.local/bin/tile-top-left.sh
#!/bin/bash
xdotool getactivewindow windowmove 0 0 windowsize 50% 50%

# Create similar scripts for:
# tile-top-right.sh, tile-bottom-left.sh, tile-bottom-right.sh

# Make executable:
chmod +x ~/.local/bin/tile-*.sh

# Bind to numpad:
Super + KP_7   → tile-top-left.sh
Super + KP_9   → tile-top-right.sh
Super + KP_1   → tile-bottom-left.sh
Super + KP_3   → tile-bottom-right.sh
```

### Window Behavior Tweaks

**Settings Manager → Window Manager Tweaks → Focus**

**Recommended settings:**
```
Focus model: Focus follows mouse
  (or "Click to focus" if you prefer)

Raise on focus: Delay before raising (500ms)
  (Prevents windows jumping unexpectedly)

When a window raises itself:
  ☑ Bring window on current workspace
  ☑ Switch to window's workspace
  (Adjust based on preference)
```

**Settings Manager → Window Manager Tweaks → Accessibility**

```
☑ Raise windows when any mouse button is pressed
☐ Hide title of windows when maximized
☑ Use mouse wheel on title bar to roll up window
```

**Settings Manager → Window Manager Tweaks → Placement**

```
Window placement: Under mouse pointer
  (or "Center of screen" if preferred)

☐ Automatically tile windows when moving toward screen edge
  (Disable this - use keyboard shortcuts instead)
```

**This 30-minute configuration makes window behavior predictable and efficient.**

---

## Panel Configuration and Launcher Stacking

### The Problem: Panel Clutter

**Bad approach:**
```
Panel: [Firefox] [Chromium] [Chrome] [Brave] [GVim] [Mousepad] [Ghostwriter] [...]
Result: 20+ icons, cluttered, hard to find things
```

**Good approach (stacking):**
```
Panel: [Browsers▾] [Editors▾] [Files▾] [Terminal]
Result: Clean, organized, quick access
```

### How to Stack Launchers

**Method 1: Multiple Items in One Launcher**

```
1. Right-click panel → Panel → Add New Items → Launcher
2. Configure Launcher → Click the "+" to add items
3. Add multiple related apps:
   - Firefox
   - Chromium
   - Chrome
   - Brave
   - Tor Browser
4. Save

Result: One icon with dropdown arrow showing all browsers
```

**Method 2: Stack Icons in Same Position**

```
1. Right-click panel → Panel → Panel Preferences
2. Items tab → Select launcher
3. Note its position number
4. Add another launcher
5. Drag to same position
6. They automatically stack with dropdown arrow
```

### Recommended Launcher Organization

**Browsers (stacked):**
- Firefox (primary)
- Chromium
- Tor Browser
- Any others you use

**Text Editors (stacked):**
- GVim (code/config files)
- Mousepad (quick edits)
- Ghostwriter (documentation)
- LibreOffice Writer (if needed for .docx)

**File Managers (stacked or single):**
- Thunar (GUI)
- Could add alternate file manager if used

**Terminal:**
- qterminal (single icon, frequently used)

**System (stacked):**
- Task Manager
- Settings Manager
- System Monitor

**Result:** Clean panel with 4-6 visible icons instead of 20+

---

## Whisker Menu: Better Than rofi/dmenu

### What It Is

**Whisker Menu** is XFCE's application launcher. It's better than rofi/dmenu for most use cases because:
- Only searches GUI applications (not $PATH spam)
- Organized by categories
- Favorites system
- Recent applications
- Fast fuzzy search
- Mouse + keyboard navigation

### Configuration

**Access:** Settings Manager → Whisker Menu

**Recommended settings:**
```
General:
  ☑ Show application descriptions
  ☑ Show application icons
  Position: Bottom (or top, preference)
  
Search Actions:
  ☐ Search web (disable if you don't want web searches)
  ☑ Search desktop files
  
Commands:
  Configure custom commands if needed
```

### Keybinding

**Set Super key to open Whisker Menu:**

```
Settings Manager → Keyboard → Application Shortcuts

Add:
  Command: xfce4-popup-whiskermenu
  Shortcut: Super (or Super_L)
```

**Now:** Press Super → Whisker Menu opens → Type to search → Enter to launch

### Why It's Better Than rofi/dmenu

**rofi/dmenu problems:**
```
Open rofi → Type "py"

Shows:
- python
- python3
- python3.11
- python3.12
- pydoc
- pydoc3
- pytest
- [50 more binaries from $PATH]

You wanted: PyCharm (the GUI app)
```

**Whisker Menu:**
```
Open Whisker Menu → Type "py"

Shows:
- PyCharm
- [Maybe Python IDLE]

That's what you wanted.
```

**The difference:**
- rofi searches $PATH (all binaries, including CLI tools)
- Whisker searches .desktop files (actual GUI applications)

**For workflows with heavy terminal use:**
- CLI tools are launched from terminals (already open)
- GUI tools are launched from launcher
- Don't need to search for `grep`, `awk`, `python3` in launcher
- Whisker Menu solves the right problem

### Usage

**Search:**
- Open Whisker Menu (Super key)
- Start typing
- Arrow keys or mouse to select
- Enter to launch

**Categories:**
- Browse by category if you forget the name
- Accessories, Development, Graphics, Internet, etc.

**Favorites:**
- Right-click app → Add to Favorites
- Favorites show at top
- Quick access to frequently used apps

**Recent:**
- Recently used apps shown
- Quick re-launch

---

## Terminal Configuration (qterminal)

### Why qterminal Over Alternatives

**qterminal chosen because:**
- Qt-based (matches XFCE's KDE compatibility layer)
- Lightweight (LXQt project, no heavy KDE/GNOME deps)
- Built-in tabs
- **Built-in splits** (horizontal/vertical terminal splitting)
- Fast startup
- Good enough for all use cases

**Why NOT alternatives:**

**GNOME Terminal:**
- Pulls GNOME dependencies (~30 MB of GNOME libs)
- Heavier
- No splits without external multiplexer

**Terminator:**
- GTK dependencies (still lighter than GNOME Terminal)
- Has splits, but qterminal does too
- No advantage

**Konsole:**
- Pulls 40+ MB of KDE frameworks
- Those frameworks enable features (bookmarks, plugins, network transparency)
- But overkill for most use
- Can configure cursor blink speed (who cares?)

**Alacritty/kitty/wezterm:**
- GPU-accelerated (overkill for terminal)
- Different configuration paradigms
- More dependencies

### Installation and Configuration

```bash
# Install qterminal
apt install qterminal

# Configuration location:
~/.config/qterminal.org/qterminal.ini
```

### Recommended Settings

**Settings → Appearance:**
```
Color scheme: Choose high-contrast dark theme
Font: Monospace font of choice (Hack, Fira Code, JetBrains Mono)
  Size: 10-12pt (readable)

☐ Cursor blink: OFF
  Reason: Less distraction, lower power, professional
  
Cursor shape: Block or Beam (preference)
```

**Settings → Behavior:**
```
☑ Open new terminals in split
☑ Show close button on tabs
☐ Confirm exit when closing
  (Adjust based on preference)

Scrollback: 10000 lines (or more if needed)
```

**Settings → Shortcuts:**
```
Review and adjust keybindings:
  New tab: Ctrl+Shift+T
  Close tab: Ctrl+Shift+W
  Next tab: Ctrl+Tab
  Prev tab: Ctrl+Shift+Tab
  
  Split horizontal: Ctrl+Shift+H
  Split vertical: Ctrl+Shift+V
  Close split: Ctrl+Shift+Q (or similar)
```

### Built-in Terminal Multiplexing

**qterminal has built-in split support:**

```
File → Split Terminal Horizontally (Ctrl+Shift+H)
File → Split Terminal Vertically (Ctrl+Shift+V)

Result:
┌───────────┬─────────────┐
│ Terminal 1│ Terminal 2  │
│           │             │
└───────────┴─────────────┘

Can nest:
┌───────────┬─────────────┐
│ Terminal 1│ Terminal 2  │
│           ├─────────────┤
│           │ Terminal 3  │
└───────────┴─────────────┘
```

**Advantages over tmux (for local work):**
- GUI controls (mouse resize)
- Simpler (no prefix key)
- Visual handles
- Easier to configure

**When to add tmux:**
- SSH sessions (need detach/reattach)
- Long-running processes
- Session persistence
- Work over network

**Best practice:**
- Local work: qterminal splits alone
- Remote work: qterminal + tmux

---

## Essential XFCE Tweaks

### Disable Cursor Blinking Everywhere

**Why:**
- Distracting (movement pulls focus)
- Power waste (constant screen redraws)
- Annoying in multiplexed sessions
- Pointless (you know where cursor is)

**Where to disable:**

**qterminal:**
Settings → Appearance → Cursor blink: OFF

**GTK applications:**
```bash
# Add to ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-cursor-blink = false
```

**Vim/Neovim:**
```vim
" Add to ~/.vimrc
set guicursor=n-v-c:block-blinkon0
```

### Compositor Settings

**Settings Manager → Window Manager Tweaks → Compositor**

**Recommended:**
```
☑ Enable display compositing
☐ Show shadows under regular windows
☐ Show shadows under dock windows
☐ Show shadows under popup windows

Opacity of window decorations: 100%
Opacity of inactive windows: 100%
```

**Why:** Compositing is needed for some features, but transparency/shadows are just visual noise and performance cost.

### File Manager (Thunar) Tweaks

**Edit → Preferences**

**Display:**
```
☑ Show hidden files
☑ Sort folders before files
```

**Behavior:**
```
Single click to activate items: Disabled
  (Double-click is more predictable)
```

**Advanced:**
```
☑ Enable volume management
```

### Clipboard Manager

**Install if not present:**
```bash
apt install xfce4-clipman-plugin
```

**Add to panel:**
Right-click panel → Panel → Add New Items → Clipman

**Useful for:** Keeping clipboard history during pen-testing/note-taking

### Power Management

**Settings Manager → Power Manager**

**Configure based on hardware:**
- Display power management
- Sleep/suspend settings
- Battery thresholds (if laptop)

**For VM:** Disable sleep/suspend (annoying in VMs)

---

## Keyboard Shortcuts Summary

### Essential Shortcuts

**Application launching:**
```
Super                # Open Whisker Menu
Super + T            # Open terminal (set this)
Super + E            # Open file manager
```

**Window management:**
```
Super + Left/Right   # Tile window to half
Super + Up           # Maximize
Super + Down         # Restore
Super + f            # Fullscreen
Alt + Tab            # Switch windows
```

**Workspaces:**
```
Ctrl + Alt + Left/Right   # Switch workspace
Ctrl + Alt + Shift + L/R  # Move window to workspace
```

**Screenshots:**
```
Print                     # Full screen
Shift + Print            # Select area
Alt + Print              # Active window
```

### Custom Shortcuts

**Settings Manager → Keyboard → Application Shortcuts**

**Add useful shortcuts:**
```
Super + T → qterminal
Super + E → thunar
Super + B → firefox
Super + L → xflock4 (lock screen)
```

---

## Themes and Appearance (Optional)

**Kali's defaults are good. If you want to customize:**

**Settings Manager → Appearance**

**Recommended themes:**
- Adwaita-dark (clean, professional)
- Arc-Dark (popular, looks good)
- Kali-Dark (Kali's default, well-integrated)

**Don't:**
- Use transparent terminals (hard to read)
- Use complex themes (performance cost)
- Change for aesthetics during active work (distraction)

**If you customize:**
- High contrast (readable)
- Consistent colors
- Professional appearance
- Test readability in different lighting

---

## The 30-Minute Configuration Checklist

**After fresh XFCE install (or on Kali first boot):**

```
☐ Window Manager Tweaks
  ☐ Focus: Focus follows mouse (if preferred)
  ☐ Placement: Under mouse pointer
  ☐ Accessibility: Raise on button press
  
☐ Window Tiling Keybindings
  ☐ Super + arrows for half-tiling
  ☐ Optional: i3-style vim keys (h/j/k/l)
  ☐ Optional: Quarter-tiling scripts
  
☐ Panel Organization
  ☐ Stack related apps (browsers, editors)
  ☐ Remove unused launchers
  ☐ Clean layout with 4-6 icons
  
☐ Whisker Menu
  ☐ Set Super key binding
  ☐ Add favorites
  ☐ Verify search works
  
☐ Terminal Configuration
  ☐ Cursor blink: OFF
  ☐ Color scheme
  ☐ Font choice
  ☐ Test splits (Ctrl+Shift+H/V)
  
☐ Keyboard Shortcuts
  ☐ Super + T for terminal
  ☐ Super + E for file manager
  ☐ Any others you use frequently
  
☐ Compositor
  ☐ Disable shadows (performance)
  ☐ Disable transparency (distraction)
  
☐ Done - Never touch again - Do actual work
```

**After this:** You have a fast, stable, efficient desktop that stays out of your way.

---

## Troubleshooting

### Whisker Menu Won't Open with Super Key

**Problem:** Super key opens something else or does nothing

**Solution:**
```bash
# Check what Super is bound to:
xfconf-query -c xfce4-keyboard-shortcuts -lv | grep Super

# Remove conflicting bindings:
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_L" -r

# Set Whisker Menu:
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_L" -n -t string -s "xfce4-popup-whiskermenu"
```

### Window Tiling Shortcuts Not Working

**Problem:** Super + arrows does nothing

**Solution:**
```
Settings Manager → Window Manager → Keyboard
  Verify shortcuts are set
  Look for "Tile window to ..." entries
  Set if missing:
    Super + Left → "Tile window to left"
    Super + Right → "Tile window to right"
    etc.
```

### Panel Launchers Not Stacking

**Problem:** Adding launchers to same position doesn't create dropdown

**Solution:**
- Use "Launcher" plugin (not "Application Launcher")
- In Launcher properties, add multiple items
- This creates dropdown automatically

### qterminal Splits Not Available

**Problem:** Can't find split options

**Solution:**
- Check version: `qterminal --version`
- Update if old: `apt update && apt upgrade qterminal`
- Menu: File → Split Terminal [Horizontally/Vertically]
- Keybindings: Settings → Shortcuts

---

## Summary

**XFCE for professional work:**
- Fast, stable, pre-configured (Kali)
- 30-minute setup for window tiling
- Panel stacking for organization
- Whisker Menu beats rofi/dmenu
- qterminal with built-in splits
- Cursor blink disabled everywhere
- Never think about DE again

**Key principle:** Configure once, efficiently, then focus on actual work. Not configuration as hobby (KDE), not accepting limitations (GNOME), but finding the balance.

**Result:** A desktop environment that enhances workflow without demanding attention or maintenance.
