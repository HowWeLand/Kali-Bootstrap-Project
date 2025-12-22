# Ruby environment - rbenv for version management

[[ ! -d "$RBENV_ROOT" ]] && mkdir -p "$RBENV_ROOT"

export PATH="$RBENV_ROOT/bin:$PATH"

if command -v rbenv &>/dev/null; then
    eval "$(rbenv init - zsh)"
fi
