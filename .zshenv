# Followed the rules here for how to use the config files for zsh
# https://unix.stackexchange.com/a/71258

# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Add Python 3.6 via Homebrew
export PATH="/usr/local/bin/python3:$PATH"

# Add Homebrew's "sbin" to PATH
export PATH="/usr/local/sbin:$PATH"

# Add Composer to $PATH
export PATH="$HOME/.composer/vendor/bin"

# Set SDKROOT as needed for Jekyll on macOS
# https://jekyllrb.com/docs/installation/macos/
export SDKROOT=$(xcrun --show-sdk-path)
