# JavaScript/Node environment - bun and node

[[ ! -d "$BUN_INSTALL" ]] && mkdir -p "$BUN_INSTALL/bin"
[[ ! -d "$NODE_PATH" ]] && mkdir -p "$NODE_PATH/.bin"

export PATH="$BUN_INSTALL/bin:$NODE_PATH/.bin:$PATH"

# NVM if system-installed
if [[ -f "/usr/share/nvm/init-nvm.sh" ]]; then
    export NVM_DIR="$LOCAL_BIN/javascript/nvm"
    [[ ! -d "$NVM_DIR" ]] && mkdir -p "$NVM_DIR"
    source /usr/share/nvm/init-nvm.sh
fi
