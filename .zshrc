# highlights folders in blue using default settings
# https://www.cyberciti.biz/faq/apple-mac-osx-terminal-color-ls-output-option/
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
if [[ "$OSTYPE" == "darwin"* ]]; then
alias ls='ls -G'
elif [[ "$OSTYPE" == "linux"* ]]; then
alias ls='ls --color=always'
fi

