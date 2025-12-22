# General system aliases

# =============================================================================
# File Operations - Interactive & Verbose (FIXED)
# =============================================================================
# Use 'command' to prevent recursive alias loops.
alias cp='command cp -iv'
alias mv='command mv -iv'
alias rm='command rm -Iv'
alias rmi='command rm -iv'
alias rmf='command rm -f'
alias mkdir='command mkdir -pv'
alias rmdir='command rmdir -v'
alias chmod='command chmod -v'
alias chown='command chown -v'

# =============================================================================
# Clipboard (X11)
# =============================================================================
if command -v xclip &>/dev/null; then
  alias clipboard='xclip -selection clipboard'
  alias pasteboard='xclip -selection clipboard -o' # Paste
fi

# =============================================================================
# Archive & Sync Operations
# =============================================================================
alias tarc='tar -czv'
alias tarx='tar -xzv'
alias tart='tar -tzv'
alias rsync='rsync -v --progress'
alias rsync2='rsync -av --progress'

if command -v tree &>/dev/null; then
  alias tree='tree -C'
  alias tree2='tree -L 2 -C'
  alias tree3='tree -L 3 -C'
fi
