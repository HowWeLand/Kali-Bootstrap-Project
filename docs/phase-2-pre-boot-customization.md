# Phase 2: Pre-Boot Customization (In Chroot)

**Status:** After Phase 1 automation, before first boot  
**Environment:** Still in chroot from live USB  
**Goal:** Eliminate dotfile sprawl, setup professional tools, prepare custom environment

---

## Philosophy: .local is a Dumb Fucking Idea

### The Problem with XDG "Standards"

**The XDG Base Directory spec says:**
- Config: `$HOME/.config`
- Data: `$HOME/.local/share`
- State: `$HOME/.local/state`
- Cache: `$HOME/.cache`

**The problem:**
- `.local` is **hidden** (dot prefix)
- Contains **executables** (`~/.local/bin`)
- Mixed with **data** (`~/.local/share`)
- Creates **dotfile sprawl** in home directory

**Why this is bad:**
- Hidden executables are a security risk
- Mixing code and data violates separation of concerns
- Users don't see what's in `.local` without `ls -la`
- Tools that "respect XDG" still clutter home with hidden crap

### Our Approach: Visible, Organized, Separated

**Directory structure:**
```
$HOME/
├── bin/              # ALL executables (visible, obviously code)
│   ├── scripts/      # Your shell scripts
│   ├── python/       # pipx, pyenv
│   ├── rust/         # cargo, rustup
│   ├── ruby/         # rbenv, gems
│   ├── go/           # GOPATH
│   └── javascript/   # npm global, nvm
├── config/           # ALL configuration (visible, obvious purpose)
│   ├── zsh/
│   ├── tmux/
│   ├── nvim/
│   └── ...
├── local/            # Data and state (NOT executables)
│   ├── share/        # Application data
│   └── state/        # Application state
├── .cache/           # OK to be hidden (temporary, disposable)
└── Documents/        # Your actual files
    Projects/
    ...
```

**Benefits:**
- No hidden executables
- Clear separation: code vs config vs data
- Easy to see what's installed (`ls ~/bin`)
- Easy to backup configs (`tar -czf config-backup.tar.gz ~/config`)
- Tools that honor XDG work correctly
- Tools that don't can be forced via env vars or symlinks

---

## XDG Environment Variables

### Custom XDG Paths

**Set system-wide in `/etc/environment` or per-user in `~/.zshenv`:**

```bash
# Custom XDG paths (eliminate .local sprawl)
export XDG_CONFIG_HOME="$HOME/config"
export XDG_DATA_HOME="$HOME/local/share"
export XDG_STATE_HOME="$HOME/local/state"
export XDG_CACHE_HOME="$HOME/.cache"  # OK to be hidden

# Executables go in visible bin/
export LOCAL_BIN="$HOME/bin"
export PATH="$LOCAL_BIN:$PATH"
```

**Already in the modular zsh config** (`zsh-configs/env/custom.zsh`)

### System-Level Defaults (For All New Users)

**Create `/etc/skel/` structure:**

```bash
# In chroot, setup /etc/skel for all future users
mkdir -p /etc/skel/{bin,config,local/{share,state},.cache}

# Add XDG vars to /etc/skel/.zshenv
cat > /etc/skel/.zshenv << 'EOF'
# XDG Base Directory (custom paths - no .local sprawl)
export XDG_CONFIG_HOME="$HOME/config"
export XDG_DATA_HOME="$HOME/local/share"
export XDG_STATE_HOME="$HOME/local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Visible bin directory
export LOCAL_BIN="$HOME/bin"
export PATH="$LOCAL_BIN:$PATH"

# Zsh config location
export ZSHCONFIG="$HOME/.zsh"
EOF
```

**This ensures every new user gets clean structure by default.**

---

## Tool Installation (The Professional Command Line)

### Philosophy: Better Curses Tools

**Replace standard tools with better-maintained, more usable alternatives:**
- `top` → `htop` (better interface, colors, tree view)
- `du` → `ncdu` (ncurses disk usage, interactive)
- `tail -f /var/log/*` → `lnav` (log navigator, syntax highlighting)
- Plain shell → `tmux`/`byobu` (session management, multiplexing)

**What we DON'T use:**
- Zellij (Node hooks into shell environment - security nightmare)
- Overly "modern" tools that lose the plot
- Anything requiring sandboxing so tight "Meta and Google feel the squeeze on their balls"

### Essential Tools

**Install in chroot before first boot:**

```bash
# In chroot
apt install -y \
    htop \              # Better top
    ncdu \              # NCurses disk usage
    lnav \              # Log file navigator
    tmux \              # Terminal multiplexer
    byobu \             # Tmux wrapper with sane defaults
    zsh \               # Already installed, but verify
    vim \               # Editor
    git \               # Version control
    curl wget \         # Network tools
    tree \              # Directory visualization
    fd-find \           # Better find
    ripgrep \           # Better grep (rg)
    bat \               # Better cat (with syntax highlighting)
    fzf                 # Fuzzy finder
```

### tmux/tmuxinator Setup

**tmux provides session management:**
- Persist sessions across disconnects
- Multiple windows in one terminal
- Split panes
- Attach from anywhere

**tmuxinator provides project templates:**
- Pre-configured layouts for different workflows
- Automatic window/pane setup
- Save and restore workspace configurations

**Installation:**

```bash
# tmux already in package list above

# tmuxinator (Ruby gem, requires Ruby)
apt install -y ruby rubygems
gem install tmuxinator

# Or use system package if available
apt install -y tmuxinator
```

**Configuration locations (XDG-compliant):**

```bash
# tmux config
mkdir -p ~/config/tmux
ln -s ~/config/tmux/tmux.conf ~/.tmux.conf  # Compatibility symlink

# tmuxinator projects
mkdir -p ~/config/tmuxinator
export TMUXINATOR_CONFIG="$HOME/config/tmuxinator"  # Add to ~/.zshenv
```

**Sample tmux.conf:**

```tmux
# ~/config/tmux/tmux.conf
# Sane tmux configuration

# Change prefix from Ctrl+b to Ctrl+a (easier to reach)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Enable mouse support
set -g mouse on

# Start window numbering at 1 (not 0)
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# Increase scrollback buffer
set -g history-limit 50000

# Vi keys in copy mode
setw -g mode-keys vi

# Split panes with | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config with r
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Status bar
set -g status-position bottom
set -g status-justify left
set -g status-style 'bg=colour234 fg=colour137'
set -g status-left ''
set -g status-right '#[fg=colour233,bg=colour241] %Y-%m-%d #[fg=colour233,bg=colour245] %H:%M:%S '
```

**Sample tmuxinator project:**

```yaml
# ~/config/tmuxinator/kali-work.yml
# Usage: tmuxinator start kali-work

name: kali-work
root: ~/

windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - # Empty pane for commands
  - shell:
  - monitoring:
      layout: tiled
      panes:
        - htop
        - journalctl -f
        - lnav /var/log/syslog
```

### byobu Setup

**byobu is tmux with sane defaults and status bar:**

```bash
# Enable byobu for user (in chroot, setup for your user)
byobu-enable

# Configure byobu to use tmux backend (not screen)
byobu-select-backend tmux
```

**byobu provides:**
- Function key shortcuts (F2=new window, F3/F4=prev/next)
- Nice status bar (load, memory, network, time)
- Session management out of the box
- Can still use tmux commands underneath

---

## Application-Specific XDG Configuration

Some applications need explicit configuration to respect XDG or use custom paths.

### Zsh (Already Configured)

**Via modular config:**
- `~/.zshenv` sets `ZSHCONFIG=$HOME/.zsh`
- History, completions, functions all in `~/.zsh/`
- See `zsh-configs/` for complete setup

### Vim/Neovim

**Force XDG compliance:**

```bash
# ~/.vimrc (compatibility symlink)
# Real config in ~/config/vim/vimrc

ln -s ~/config/vim/vimrc ~/.vimrc

# In ~/config/vim/vimrc:
set runtimepath^=$XDG_CONFIG_HOME/vim
set runtimepath+=$XDG_CONFIG_HOME/vim/after
set packpath^=$XDG_CONFIG_HOME/vim

set viminfo+=n$XDG_STATE_HOME/vim/viminfo
set backupdir=$XDG_STATE_HOME/vim/backup
set directory=$XDG_STATE_HOME/vim/swap
set undodir=$XDG_STATE_HOME/vim/undo
```

### Git

**Git respects XDG natively:**

```bash
# Git config goes to ~/.config/git/config automatically
mkdir -p ~/config/git

# Set user details
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Git stores in ~/config/git/ if XDG_CONFIG_HOME set
```

### GPG

**Force GPG to use XDG paths:**

```bash
# GPG defaults to ~/.gnupg (hidden, sprawl)
# Force to ~/config/gnupg

export GNUPGHOME="$HOME/config/gnupg"  # Add to ~/.zshenv

# Create directory
mkdir -p ~/config/gnupg
chmod 700 ~/config/gnupg
```

### SSH

**SSH does NOT respect XDG (by design, for compatibility):**

**Options:**
1. **Leave it:** `~/.ssh` is acceptable (critical path, historical)
2. **Symlink to config:** `ln -s ~/config/ssh ~/.ssh`
3. **Force via alias:** `alias ssh='ssh -F ~/config/ssh/config'`

**Recommendation:** Leave `~/.ssh` alone. It's universally expected.

### Tool-by-Tool XDG Guide

**See project documentation:**
- `docs/xdg-compliance-audit.md` (comprehensive per-app guide)
- `configs/xdg-overrides/` (example configs forcing XDG)

---

## Creating a Clean User

**In chroot, create your primary user:**

```bash
# Create user with zsh shell
useradd -m -s /bin/zsh -G sudo youruser

# Set password
passwd youruser

# User gets /etc/skel/ contents automatically
# Which now includes XDG-compliant structure
```

**Verify user's home structure:**

```bash
ls -la /home/youruser
# Should show:
# bin/
# config/
# local/
# .cache/
# .zsh/
# .zshenv
```

---

## Setting Up Modular Zsh Config

**Deploy the modular zsh config created earlier:**

```bash
# In chroot, for your user
cd /home/youruser

# Copy modular configs
cp -r /path/to/zsh-configs/.zsh ./
cp /path/to/zsh-configs/zshenv ./.zshenv
cp /path/to/zsh-configs/user_profile.zsh ./.zsh/

# Copy Kali's default zshrc
cp /etc/skel/.zshrc ./

# Add the modular loader line to .zshrc
echo '[[ -f $ZSHCONFIG/user_profile.zsh ]] && source "$ZSHCONFIG/user_profile.zsh"' >> ./.zshrc

# Fix ownership
chown -R youruser:youruser /home/youruser
```

**See `zsh-configs/DEPLOYMENT.md` for full details.**

---

## Documentation Strategy for Phase 2

**What to document:**
1. Every XDG override (why and how)
2. Every tool installed (why this tool vs alternatives)
3. Every config file (what each option does)
4. Every system-level change (`/etc/skel`, `/etc/environment`)

**Example documentation format:**

```markdown
## Tool: lnav (Log File Navigator)

**Why:** Better than tail -f, syntax highlighting, filtering, queries
**Alternative:** tail, less, journalctl -f
**Trade-off:** Slight learning curve vs immense productivity gain

**Installation:**
```bash
apt install lnav
```

**Configuration:**
XDG-compliant by default: `~/.config/lnav/`

**Usage:**
```bash
lnav /var/log/syslog  # Open log
# Press 'h' for help
# ':filter-in <pattern>' to filter
# 'q' to quit
```
```

---

## What NOT to Do

**Don't install these in Phase 2:**

❌ **Desktop environment** - That's Phase 4 (requires booted system, display manager)  
❌ **Network services** - Phase 5 (configure after boot)  
❌ **Development environments** - Phase 6 (can do in chroot but easier after boot)  
❌ **Security tools** - Phase 6 (kali-tools-* metapackages after boot)

**Phase 2 is ONLY:**
- System-level XDG setup
- Command-line tools
- Shell configuration
- User creation
- Pre-boot customization

---

## Verification Checklist

**Before exiting chroot, verify:**

```bash
# Check XDG environment
grep XDG /home/youruser/.zshenv

# Check tool installation
which htop ncdu lnav tmux

# Check user exists and has correct shell
getent passwd youruser | grep zsh

# Check /etc/skel structure
ls -la /etc/skel

# Check modular zsh config
ls -la /home/youruser/.zsh

# Check ownership
ls -la /home/youruser | grep "^d" | awk '{print $3}' | sort -u
# Should only show: youruser
```

---

## After Phase 2

**Exit chroot:**

```bash
sync
exit  # Leave chroot
```

**Unmount everything:**

```bash
umount -R /mnt
cryptsetup close crypthome
cryptsetup close cryptroot
sync
```

**Remove USB keyfile drive** (keep it safe!)

**Reboot:**

```bash
shutdown -r now
```

**Expected result:**
- System boots to TTY login
- Log in as youruser
- Zsh with modular config loads
- XDG-compliant directory structure
- All tools available

**If it doesn't boot:** Boot live USB, mount, chroot, check GRUB and initramfs.

---

## Next Steps: Phase 3+ (After First Boot)

**Phase 3: Networking**
- Configure NetworkManager or systemd-networkd (wait, OpenRC, so... what's the OpenRC equivalent?)
- WiFi setup
- VPN configuration

**Phase 4: Desktop Environment**
- XFCE (recommended for OpenRC)
- Display manager
- Graphical applications

**Phase 5: Development Tools**
- Language runtimes (Python, Rust, etc.)
- IDEs and editors
- Version managers

**Phase 6: Security Tools**
- kali-tools-* metapackages
- Custom tool selection
- Configuration for pen-testing

---

## Related Documentation

- `zsh-configs/DEPLOYMENT.md` - Complete zsh setup guide
- `docs/xdg-compliance-audit.md` - Per-application XDG configuration
- `docs/tool-choices.md` - Why each tool over alternatives
- `configs/tmux/` - tmux and tmuxinator examples
- `configs/xdg-overrides/` - XDG override configs for stubborn apps

---

**Document Status:** Phase 2 planning complete  
**Next:** Script automation for Phase 2 (optional, can be done manually)

---

*This documentation is licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/). You are free to remix, correct, and make it your own with attribution.*
