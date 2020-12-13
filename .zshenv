# Followed the rules here for how to use the config files for zsh
# https://unix.stackexchange.com/a/71258

# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Add Python 3.6 via Homebrew
export PATH="/usr/local/bin/python3:$PATH"

# Add Homebrew's "sbin" to PATH
export PATH="/usr/local/sbin:$PATH"

# Allows you to use NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
