# Reference: Kali Linux Default zshrc

**DO NOT REPLACE YOUR ACTUAL zshrc WITH THIS FILE**

This is for REFERENCE ONLY to show where to add the modular loader.

---

## Overview

This file shows THE ONE LINE you need to add to Kali's default zshrc, marked with `>>>` and `<<<` arrows.

When `ZDOTDIR` is set in `/etc/zsh/zshenv`, zsh looks for config files in `$ZDOTDIR` **without dots**. So Kali's default zshrc will be at `$ZDOTDIR/.zshrc` (not `~/.zshrc`).

Near the end of the file (around line 263), ADD THIS LINE:
```bash
>>> [[ -f $ZDOTDIR/user_profile.zsh ]] && source "$ZDOTDIR/user_profile.zsh" <
```

That's it. One line. Everything else is handled by the modular loader.

---

## What Kali's Default Provides

Kali's default zshrc includes:

- Completion system initialization
- Syntax highlighting (fast-syntax-highlighting plugin)
- Auto-suggestions
- Prompt configuration (supports two-line and one-line modes, toggle with Ctrl+P)
- Color support for ls, grep, less, man
- Useful aliases and functions
- History configuration
- Keybindings

---

## What NOT To Do

❌ Don't replace Kali's default zshrc  
❌ Don't copy this entire file  
❌ Don't modify Kali's existing configurations

## What TO Do

✅ Keep Kali's default zshrc intact  
✅ Add ONE line to source the modular loader  
✅ Let the modular loader handle your custom configs

---

## Prerequisites

This document assumes you have set `$ZDOTDIR` in `/etc/zsh/zshenv` and XDG variables in `/etc/environment`:

**In `/etc/environment`:**
```bash
# Custom XDG paths (eliminate .local sprawl)
export XDG_CONFIG_HOME="$HOME/config"
export XDG_DATA_HOME="$HOME/local/share"
export XDG_STATE_HOME="$HOME/local/state"
export XDG_CACHE_HOME="$HOME/.cache"  # OK to be hidden

# Executables go in visible bin/
export LOCAL_BIN="$HOME/bin"
```

**In `/etc/zsh/zshenv`:**
```bash
# Zsh rehoming - this makes zsh look in $ZDOTDIR for its config files
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
```

This means zsh will look for `$ZDOTDIR/.zshrc`, not `$HOME/.zshrc`.

---

## The Actual Line To Add

Add to `$ZDOTDIR/zshrc` near the end (after color/alias setup, before completion):
```bash
[[ -f $ZDOTDIR/user_profile.zsh ]] && source "$ZDOTDIR/user_profile.zsh"
```

Or append it:
```bash
echo '[[ -f $ZDOTDIR/user_profile.zsh ]] && source "$ZDOTDIR/user_profile.zsh"' >> $ZDOTDIR/zshrc
```

---

## Verification

After adding the line:
```bash
# Check it's there
grep "user_profile" $ZDOTDIR/.zshrc

# Start new shell
exec zsh

# Alternatively
source $ZDOTDIR/.zshrc

# Check modular config loaded
echo $ZDOTDIR  # Should show: /home/youruser/config/zsh
type cp        # Should show: cp is aliased to `cp -iv'

# Verify file locations
ls -la $ZDOTDIR/  # Should show: zshrc (no dot), user_profile.zsh, etc.
```

---

## Why This Approach

**Benefits:**

1. Kali's zshrc is well-maintained and updated
2. Your custom configs are separated and version-controlled
3. Easy to disable (just comment out one line)
4. Updates to Kali's default don't break your setup
5. Modular approach makes configs easy to understand and modify
6. XDG-compliant from the start (no dotfile clutter in `$HOME`)

**Alternative Approaches (NOT RECOMMENDED):**

- Replacing entire zshrc → loses Kali updates
- Modifying Kali's default → creates merge conflicts on updates
- Sourcing configs directly → loses modularity
- Keeping dotfiles in `$HOME` → defeats XDG organization

This is the cleanest integration method.