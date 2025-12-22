# PHP environment - phpenv for version management

[[ ! -d "$PHPENV_ROOT" ]] && mkdir -p "$PHPENV_ROOT"

export PATH="$PHPENV_ROOT/bin:$PATH"

if command -v phpenv &>/dev/null; then
    eval "$(phpenv init -)"
fi
