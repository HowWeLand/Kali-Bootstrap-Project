# ~/.zsh/user_profile.zsh
# Sourced by .zshrc for INTERACTIVE shells.
# All directory creation is now handled by .zshenv.

# == Vim Mode ==
bindkey -v # Vim mode

# == Directory Creation ==
# Create all required directories at the start using 'mkdir -p'

# 1. Zsh config structure
mkdir -p $ZDORDIR/{aliases,completions,env,functions,plugins}

# 2. Local bin structure
mkdir -p $LOCAL_BIN/scripts

# 3. Language-specific directories
mkdir -p $SDKMAN_DIR
mkdir -p $PYENV_ROOT
mkdir -p $PIPX_HOME
mkdir -p $PIPX_BIN_DIR
mkdir -p $GOPATH
mkdir -p $CARGO_HOME # Also creates $LOCAL_RUST
mkdir -p $RUSTUP_HOME
mkdir -p $BUN_INSTALL # Also creates $LOCAL_JS
mkdir -p $NODE_PATH
mkdir -p $RBENV_ROOT
mkdir -p $PLENV_ROOT
mkdir -p $LUAVER_DIR
mkdir -p $PHPENV_ROOT

# == Sourcing Loops ==
# Source all modular configuration files

# 1. Functions
export ZSH_FUNCTIONS=$ZSHCONFIG/functions
for file in $ZSH_FUNCTIONS/*; do
  [[ -f $file ]] && source $file
done

# 2. Aliases, Env (Language files), Completions, Plugins
for dir in aliases env completions plugins; do
  local subdir=$ZSHCONFIG/$dir
  # Use unquoted glob
  for file in $subdir/*; do
    [[ -f $file ]] && source $file
  done
done
unset dir subdir file # Clean up loop variables
