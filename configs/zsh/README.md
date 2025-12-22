# XDG-Compliant Zsh Configuration for Kali Linux

## Philosophy

**".local is a dumb fucking idea"**

This configuration eliminates dotfile sprawl by:
1. Using visible, organized directories (`~/bin/`, `~/config/`)
2. Separating code, config, and data
3. Respecting XDG Base Directory specification (with custom paths)
4. Being modular and version-controllable

## Directory Structure
```
~/
├── bin/                          # ALL executables (visible, organized)
│   ├── scripts/                 # Your shell scripts
│   ├── rust/                    # Cargo, rustup
│   ├── python/                  # Pipx, pyenv
│   ├── ruby/                    # Rbenv
│   ├── go/                      # GOPATH
│   └── javascript/              # Node, bun, nvm
├── config/                       # ALL configuration
│   ├── zsh/                     # Zsh config (ZDOTDIR)
│   │   ├── user_profile.zsh    # Modular loader
│   │   ├── zshrc               # Kali default + one line
│   │   ├── env/                # Language environments
│   │   ├── aliases/            # Command aliases
│   │   ├── functions/          # Shell functions
│   │   └── plugins/            # Zsh plugins
│   ├── git/                     # Git config
│   └── ...                      # Other app configs
├── local/                        # Data and state (NOT executables)
│   ├── share/                   # Application data
│   └── state/                   # Application state (logs, history)
└── .cache/                       # OK to be hidden (temporary, disposable)
```

## What's Different

### Traditional XDG:
- Config: `~/.config`
- Data: `~/.local/share`
- State: `~/.local/state`
- Executables: `~/.local/bin` (HIDDEN!)

### This Configuration:
- Config: `~/config` (visible)
- Data: `~/local/share` (visible parent)
- State: `~/local/state` (visible parent)
- Executables: `~/bin` (VISIBLE, OBVIOUS)

## Features

### System-Wide
- XDG paths set in `/etc/zsh/zshenv` for all users
- Language directories defined before any package tries to use `~/.local`
- Compliance fixes for 20+ common tools

### Modular
- Language environments load only if language is installed
- Aliases organized by category
- Easy to add/remove components
- Version-controllable

### Integrated with Kali
- Preserves Kali's zshrc features
- One-line integration
- Updates don't break your config

## Installation

See [DEPLOYMENT.md](DEPLOYMENT.md) for complete instructions.

Quick version:
```bash
sudo cp zshenv /etc/zsh/zshenv
# ... deploy files to ~/config/zsh and ~/bin
echo '[[ -f $ZDOTDIR/user_profile.zsh ]] && source "$ZDOTDIR/user_profile.zsh"' >> ~/config/zsh/zshrc
exec zsh
```

## Included Utilities

- `apt-tag` - Tag packages with installation reason
- `tag-search` - Search packages by tag
- `pkg-info` - Enhanced package information
- `gpg-copy-pub` - Easy GPG public key export
- `upgrayyedd` - apt upgrade with tagging support

## License

MIT (or whatever you choose)

## Part of Kali-Bootstrap-Project

This configuration is part of the larger [Kali-Bootstrap-Project: Now with OpenRC!](link) documentation effort.