# $ZDOTDIR/user_profile.zsh
# Modular configuration loader
# Sourced by Kali's zshrc after their defaults are loaded

# Create XDG subdirectories if needed
[[ ! -d "$XDG_STATE_HOME/zsh" ]] && mkdir -p "$XDG_STATE_HOME/zsh"
[[ ! -d "$XDG_CACHE_HOME/zsh" ]] && mkdir -p "$XDG_CACHE_HOME/zsh"
[[ ! -d "$XDG_CACHE_HOME/X11" ]] && mkdir -p "$XDG_CACHE_HOME/X11"

# Override compinit to use XDG cache directory
# Must be set before completion system initializes
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Source modular configuration directories
for dir in env aliases functions plugins; do
    [[ ! -d "$ZDOTDIR/$dir" ]] && mkdir -p "$ZDOTDIR/$dir"
    for file in "$ZDOTDIR/$dir"/*.zsh(N); do
        source "$file"
    done
done

# Vim keybindings (personal preference)
bindkey -v
