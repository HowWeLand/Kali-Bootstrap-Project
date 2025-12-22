# XDG compliance fixes via aliases
# For tools that don't respect environment variables

# adb (Android Debug Bridge)
alias adb='HOME="$XDG_DATA_HOME"/android adb'

# wget (HSTS cache)
alias wget="wget --hsts-file=$XDG_DATA_HOME/wget-hsts"

# keychain (SSH agent)
alias keychain="keychain --absolute --dir $XDG_RUNTIME_DIR/keychain"
