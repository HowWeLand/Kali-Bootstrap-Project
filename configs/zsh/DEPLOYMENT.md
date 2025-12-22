# Zsh Configuration Deployment

## Quick Start
```bash
# 1. Install /etc/zsh/zshenv (requires root)
sudo cp zshenv /etc/zsh/zshenv

# 2. Create XDG-compliant directory structure
mkdir -p ~/config/zsh/{env,aliases,functions,plugins}
mkdir -p ~/bin
mkdir -p ~/local/{share,state}
mkdir -p ~/.cache

# 3. Deploy configuration files
cp user_profile.zsh ~/config/zsh/
cp env/*.zsh ~/config/zsh/env/
cp aliases/*.zsh ~/config/zsh/aliases/
cp plugins/*.zsh ~/config/zsh/plugins/
cp functions/*.zsh ~/config/zsh/functions/

# 4. Deploy utility scripts
cp bin/* ~/bin/
chmod +x ~/bin/*

# 5. Integrate with Kali's zshrc
# Kali's zshrc will be at $ZDOTDIR/zshrc due to ZDOTDIR being set
echo '[[ -f $ZDOTDIR/user_profile.zsh ]] && source "$ZDOTDIR/user_profile.zsh"' >> ~/config/zsh/zshrc

# 6. Start new shell
exec zsh
```

## What Gets Set Where

### `/etc/zsh/zshenv` (System-wide, all shells)
- XDG base directories
- LOCAL_BIN path
- Language environment base paths
- XDG compliance fixes for common tools

### `$ZDOTDIR/user_profile.zsh` (Interactive shells)
- Creates XDG subdirectories
- Sources modular configs (env, aliases, functions, plugins)
- Sets vim keybindings

### Language environment files
- Create language-specific directories
- Add language tools to PATH
- Initialize version managers (rbenv, pyenv, etc.)

### Aliases
- Safe file operations
- Package management helpers
- GPG shortcuts
- XDG compliance fixes

### Plugins
- direnv integration
- keychain (SSH/GPG agent)

## Verification
```bash
# Check environment
echo $ZDOTDIR          # ~/config/zsh
echo $XDG_CONFIG_HOME  # ~/config
echo $LOCAL_BIN        # ~/bin
echo $CARGO_HOME       # ~/bin/rust/cargo

# Check aliases loaded
type cp               # Should show: cp is aliased to 'command cp -iv'
type apt-update       # Should show: apt-update is aliased to...

# Check history file location
echo $HISTFILE        # ~/local/state/zsh/history

# Check no dotfile sprawl in home
ls -la ~ | grep "^\."  # Should only see .cache and essential dotfiles
```

## Troubleshooting

### "ZDOTDIR not set"
- `/etc/zsh/zshenv` not installed or not being sourced
- Check: `cat /etc/zsh/zshenv`

### "Aliases not loading"
- `user_profile.zsh` not being sourced from Kali's zshrc
- Check: `grep "user_profile" $ZDOTDIR/zshrc`

### "Language tools not in PATH"
- Language environment file not sourced
- Check: `ls $ZDOTDIR/env/`

### "Git still using ~/.gitconfig"
- Git respects XDG automatically if `$XDG_CONFIG_HOME/git/config` exists
- Move: `mv ~/.gitconfig $XDG_CONFIG_HOME/git/config`

## XDG Compliance Status

**Compliant (via environment variables):**
- zsh (ZDOTDIR, HISTFILE)
- cargo/rustup
- npm
- gnupg
- wine
- Java preferences
- X11 authority files

**Compliant (via aliases):**
- wget (HSTS cache)
- adb (Android)
- keychain

**Not compliant (upstream won't fix):**
- Firefox (`.mozilla` in home)
- Bash (`.bashrc`, `.bash_history`)
- SSH (`.ssh` - intentionally left alone)
- Flatpak (`.var`)

**Manually moved:**
- git → `$XDG_CONFIG_HOME/git/config`
- NSS/PKI → `$XDG_DATA_HOME/pki` (may reappear due to Chromium)

## Benefits

- No dotfile clutter in `$HOME`
- Language tools isolated in `~/bin/lang/`
- Everything version-controllable
- Modular (add/remove languages easily)
- Kali updates don't break your config