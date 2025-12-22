# Perl environment - plenv for version management

[[ ! -d "$PLENV_ROOT" ]] && mkdir -p "$PLENV_ROOT"

export PATH="$PLENV_ROOT/bin:$PATH"

if command -v plenv &>/dev/null; then
    eval "$(plenv init -)"
fi
