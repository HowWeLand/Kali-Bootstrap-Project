# Zsh Configuration Deployment Guide

## Overview

This modular Zsh configuration integrates with Kali Linux's default Zsh setup.

**Important:** This does NOT replace Kali's zshrc. It extends it.

## Quick Start

```bash
# 1. Create directory structure
mkdir -p ~/.zsh/{aliases,env,completions,functions,plugins}
mkdir -p ~/bin ~/config ~/local/{share,state}

# 2. Deploy core files
cp zshenv ~/.zshenv
cp user_profile.zsh ~/.zsh/

# 3. Deploy aliases
cp aliases/*.zsh ~/.zsh/aliases/

# 4. Deploy environment files (only for languages you use)
cp env/python.zsh ~/.zsh/env/     # If using Python
cp env/rust.zsh ~/.zsh/env/       # If using Rust
cp env/ruby.zsh ~/.zsh/env/       # If using Ruby
cp env/go.zsh ~/.zsh/env/         # If using Go
cp env/javascript.zsh ~/.zsh/env/ # If using Node
cp env/custom.zsh ~/.zsh/env/     # Always deploy this one

# 5. Add ONE LINE to your existing ~/.zshrc
echo '[[ -f $ZSHCONFIG/user_profile.zsh ]] && source "$ZSHCONFIG/user_profile.zsh"' >> ~/.zshrc

# 6. Start new shell
exec zsh
```

## File Descriptions

### Core Files (Always Deploy)

- `zshenv` → `~/.zshenv`
  - Sets ZSHCONFIG and LOCAL_BIN variables
  - Sourced by ALL shells (interactive and non-interactive)

- `user_profile.zsh` → `~/.zsh/user_profile.zsh`
  - Modular loader that sources all configs
  - Sets vim keybindings
  - Creates directories as needed

### Alias Files (Always Deploy)

- `aliases/aliases.zsh` - Safe file operations (cp -iv, rm -Iv)
- `aliases/apt.zsh` - Aptitude tagging system
- `aliases/colors.zsh` - Color enforcement for ls, grep, etc.
- `aliases/gpg.zsh` - GPG key management helpers

### Environment Files (Deploy Only What You Need)

- `env/python.zsh` - pipx and pyenv configuration
- `env/rust.zsh` - rustup and cargo paths
- `env/ruby.zsh` - rbenv configuration
- `env/go.zsh` - GOPATH setup
- `env/javascript.zsh` - npm and nvm configuration
- `env/custom.zsh` - GPG_TTY, EDITOR, XDG directories (ALWAYS DEPLOY)
- `env/lang.zsh` - Documentation only (don't deploy)

### Reference Files (DO NOT Deploy)

- `KALI_DEFAULT_ZSHRC.txt` - Reference showing Kali's default zshrc
- This shows where to add the source line
- Your actual ~/.zshrc should remain Kali's default

## Integration with Kali Default

Kali's default zshrc provides:
- Completion system setup
- Syntax highlighting (fast-syntax-highlighting)
- Auto-suggestions
- Prompt configuration (two-line/one-line toggle with Ctrl+P)
- Color support
- Useful aliases and functions

**This configuration extends those features**, it doesn't replace them.

## XDG Base Directory Compliance

This configuration uses custom XDG paths:

- Config: `$HOME/config` (not `$HOME/.config`)
- Data: `$HOME/local/share` (not `$HOME/.local/share`)
- State: `$HOME/local/state` (not `$HOME/.local/state`)
- Cache: `$HOME/.cache` (standard)

Applications are configured individually for XDG compliance. See the main project documentation for per-application XDG configuration.

## Language Environments

Each language environment file:
1. Checks if the language directory exists
2. Creates it if needed
3. Sets environment variables
4. Adds tools to PATH
5. Initializes version managers if present

**If a language isn't installed**, its env file is harmless - it just creates empty directories.

## Verification

After deployment:

```bash
# Check variables are set
echo $ZSHCONFIG      # Should show: /home/youruser/.zsh
echo $LOCAL_BIN      # Should show: /home/youruser/bin
echo $XDG_CONFIG_HOME  # Should show: /home/youruser/config

# Check directories exist
ls -la ~/.zsh
ls -la ~/bin

# Test an alias
type cp  # Should show: cp is aliased to `cp -iv'

# Check language environments (if installed)
echo $CARGO_HOME     # If rust.zsh deployed
echo $PIPX_HOME      # If python.zsh deployed
```

## Uninstall

```bash
# Remove custom files
rm -rf ~/.zsh ~/.zshenv

# Edit ~/.zshrc and remove the line containing "user_profile.zsh"

# Or restore Kali's default
cp /etc/skel/.zshrc ~/.zshrc
```

## Troubleshooting

**"ZSHCONFIG: not set"**
- `~/.zshenv` isn't being sourced
- Check: `ls -la ~/.zshenv`

**Aliases not working**
- Source line not in zshrc
- Check: `grep "user_profile" ~/.zshrc`

**Language paths not set**
- Env file not deployed or has errors
- Check: `ls ~/.zsh/env/` and `source ~/.zsh/env/python.zsh` manually

**"command not found" for language tools**
- The env files only set paths, they don't install tools
- Install rustup, pipx, rbenv, etc. separately

## Apt Tagging System

The apt.zsh aliases reference a Python script: `~/bin/apt-tag.py`

This script must be created separately. It provides:
- Tag packages with installation reason
- List packages by tag
- Search for packages and their tags
- Identify safe-to-remove packages

See the main project documentation for the apt-tag.py implementation.

## Additional Tools

This configuration expects certain tools to be installed:

- vim (set as $EDITOR)
- less (set as $PAGER)
- Language-specific tools (rustup, pipx, rbenv, etc.) - optional

## Philosophy

This configuration follows the project's core principle:

**"If I can't teach it, do I really understand it?"**

Every choice is documented. Every file has a clear purpose. Nothing is cargo-culted from other configurations without understanding why.

The modular structure allows you to:
- Deploy only what you need
- Understand what each piece does
- Modify individual components without breaking others
- Version control your entire shell environment

## License

Same as main project (to be determined - likely MIT for configs)
