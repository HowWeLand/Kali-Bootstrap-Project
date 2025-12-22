# Rust environment - cargo and rustup
# Base paths set in /etc/zsh/zshenv

[[ ! -d "$CARGO_HOME" ]] && mkdir -p "$CARGO_HOME"
[[ ! -d "$RUSTUP_HOME" ]] && mkdir -p "$RUSTUP_HOME"

export PATH="$CARGO_HOME/bin:$PATH"
