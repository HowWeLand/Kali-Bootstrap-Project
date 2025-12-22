# ~/.zsh/plugins/direnv.zsh
# Hooks direnv into the shell if the command exists.
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi
