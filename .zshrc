command -V neofetch > /dev/null && neofetch

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# chectl autocomplete setup
CHECTL_AC_ZSH_SETUP_PATH=/Users/zplewis/Library/Caches/chectl/autocomplete/zsh_setup && test -f $CHECTL_AC_ZSH_SETUP_PATH && source $CHECTL_AC_ZSH_SETUP_PATH;export PATH="/usr/local/sbin:$PATH"
source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add Laravel Sail alias
alias sail='bash vendor/bin/sail'

# highlights folders in blue using default settings
# https://www.cyberciti.biz/faq/apple-mac-osx-terminal-color-ls-output-option/
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
alias ls='ls -G'

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Set Homebrew Python 3 as the default
alias python=/usr/local/bin/python3

# Add brew ruby and gems path to use newer version
export PATH="/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/3.0.0/bin:$PATH"

# Set SDKROOT as needed for Jekyll on macOS
# https://jekyllrb.com/docs/installation/macos/
# xcode-select --install
# If the above command doesn't allow you to find xcrun, try
# sudo xcode-select --reset
export SDKROOT=$(xcrun --show-sdk-path)
