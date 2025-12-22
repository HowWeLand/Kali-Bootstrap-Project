#
# Privilege level: NONE
# Risk level: LOW
# Use case: Safe for any system (personal/work/production)
#
# These add safety and visibility without privilege escalation
# These aliases add safety and visibility to common operations:
# - Interactive prompts prevent accidental overwrites/deletions
# - Verbose flags show what's happening
# - No privilege escalation (no sudo)
# - Safe to use on any system
#
# Philosophy:
# "Feedback from commands prevents mistakes"
# "Interactive prompts are safety rails, not annoyances"
#
# To bypass aliases when needed:
#   command rm file.txt    # Uses original rm
#   \rm file.txt           # Also bypasses alias
#   rmf file.txt           # Uses 'rmf' alias (force)

# =============================================================================
# File Operations - Interactive & Verbose
# =============================================================================
# These prevent accidental overwrites and deletions

alias cp='cp -iv' # Confirm before overwriting
alias mv='mv -iv' # Confirm before overwriting
alias rm='rm -Iv' # Confirm for 3+ files or recursive (less annoying)

# Explicit variants
alias rmi='rm -iv'        # Always interactive
alias rmf='command rm -f' # Force (bypasses alias) - USE WITH CAUTION

# =============================================================================
# Directory Operations
# =============================================================================

alias mkdir='mkdir -pv' # Create parents, show what's created
alias rmdir='rmdir -v'  # Show what's removed

# =============================================================================
# Permissions - Verbose
# =============================================================================
# Show what changed (helps catch mistakes)

alias chmod='chmod -v' # Show permission changes
alias chown='chown -v' # Show ownership changes

# =============================================================================
# Clipboard (X11)
# =============================================================================

if command -v xclip &>/dev/null; then
	alias clipboard='xclip -selection clipboard'
	alias pasteboard='xclip -selection clipboard -o' # Paste
fi

# =============================================================================
# Archive Operations
# =============================================================================
# Verbose only for operations where you want to see progress

# Tar - selective verbosity
alias tarc='tar -czv' # Create archive (verbose)
alias tarx='tar -xzv' # Extract archive (verbose)
alias tart='tar -tzv' # List contents (verbose)
# Leave 'tar' itself without default -v for quiet operations

# Rsync - with progress
alias rsync='rsync -v --progress'
alias rsync2='rsync -av --progress' # Archive mode + verbose

# Tree with reasonable defaults
if command -v tree &>/dev/null; then
	alias tree='tree -C'       # Colorize
	alias tree2='tree -L 2 -C' # 2 levels
	alias tree3='tree -L 3 -C' # 3 levels
fi

# =============================================================================
# Safety Nets
# =============================================================================
# Prevent common mistakes

# Confirm before overwriting with redirection
alias cp='cp -iv'
alias mv='mv -iv'
