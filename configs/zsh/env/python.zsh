# Python environment - pipx for application installation
# Base paths set in /etc/zsh/zshenv

[[ ! -d "$PIPX_HOME" ]] && mkdir -p "$PIPX_HOME"
[[ ! -d "$PIPX_BIN_DIR" ]] && mkdir -p "$PIPX_BIN_DIR"

export PATH="$PIPX_BIN_DIR:$PATH"

# Pyenv if installed
if [[ -d "$LOCAL_BIN/python/pyenv" ]]; then
    export PYENV_ROOT="$LOCAL_BIN/python/pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi
