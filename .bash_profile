#
#   mkcd command
#   This is an improvised version of the mkcd command at:
#   http://superuser.com/questions/152794/is-there-a-shortcut-to-mkdir-foo-and-immediately-cd-into-it
#
function mkcd {
  last=$(eval "echo \$$#")
  if [ ! -n "$last" ]; then
    echo "Enter a directory name"
  elif [ -d $last ]; then
    echo "\`$last' already exists"
  else
    mkdir $@ && cd $last
  fi
}

#
#   Update all Homebrew, Atom, and VS Code packages
function update_formulas {
    brew update
    brew upgrade
    brew cask upgrade
    brew cleanup -s
    brew doctor
    brew missing
    # Update all Atom packages
    apm upgrade -c false
    # Update all Mac App Store apps
    mas upgrade
}

function install_casks {
    # Install Homebrew Cask
        update_formulas

        # Ask for the administrator password
        sudo -v

        # Xcode Command Line Tools
        xcode-select --install

        # Agree to the Xcode license
        sudo xcodebuild -license accept

        # Install apps via Homebrew Cask
        casks=(
            'adobe-creative-cloud'
            'android-file-transfer'
            'atom'
            'docker'
            'firefox'
            'flycut'
            'google-backup-and-sync'
            'google-chrome'
            'iterm2'
            'itsycal'
            'java'
            'macpass'
            'microsoft-teams'
            'postman'
            'r-app'
            'rstudio'
            'safari-technology-preview'
            'sequel-pro'
            'spotify'
            'sublime-text'
            'virtualbox'
            'virtualbox-extension-pack'
            'visual-studio-code'
            'vlc'
            'youtube-to-mp3'
        )

    # loop through the formulas, install missing ones
    for t in ${casks[@]}; do
        #echo "checking if $t formula is installed..."
        brew ls --versions $t > /dev/null
        formula_installed=$?
        #echo "$t installed: $formula_installed"
        if [ ! "$formula_installed" -eq 0 ]; then
            echo "Installing '$t' cask..."
            brew cask install $t
        fi
    done 
}

#
#  Installs NPM packages.
#
function npm_install {
    # Install Node v8 via NVM using the official method
    # Node Version Manager
    # https://github.com/creationix/nvm
    curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
    nvm install 8 

    packages=(
        '@google/clasp'
        'eslint'
        'eslint-config-jquery'
        'generator-code'
        'gulp'
        'gulp-cli'
        'vsce'
        'yo'
    )

    # loop through the formulas, install missing ones
    for t in ${packages[@]}; do
        npm install -g $t
    done
}


function app_store_install {
    # list of apps
    apps=(
        '411643860'  # DaisyDisk
        '497799835'  # Xcode
        '441258766'  # Magnet
        '1295203466' # Microsoft Remote Desktop 10.0
        '462054704'  # Microsoft Word
        '784801555'  # Microsoft OneNote
        '462062816'  # Microsoft PowerPoint
        '462058435'  # Microsoft Excel
        '985367838'  # Microsoft Outlook
        '682658836'  # Garageband
        '926036361'  # LastPass Password Manager
        '507257563'  # Sip
        '823766827'  # Microsoft OneDrive
    )

    # loop through the formulas, install missing ones
    for t in ${apps[@]}; do
       mas install $t
    done

    # Upgrade all applications
    mas upgrade
}


function extensions_install {
    # Atom extensions
    atom=(
        'busy-signal'
        'docblockr'
        'file-icons'
        'intentions'
        'language-blade'
        'language-dotenv'
        'linter'
        'linter-eslint'
        'linter-markdown'
        'linter-php'
        'linter-phpcs'
        'linter-phpmd'
        'linter-ui-default'
        'monokai'
    )

    # Visual Studio Code extensions
    vscode=(
        '77qingliu.sas-syntax'
        'DavidAnson.vscode-markdownlint'
        'dbaeumer.vscode-eslint'
        'ecodes.vscode-phpmd'
        'ikappas.phpcs'
        'mikestead.dotenv'
        'ms-python.python'
        'ms-vscode.csharp'
        'neilbrayfield.php-docblocker'
        'onecentlin.laravel-blade'
        'PeterJausovec.vscode-docker'
    )

    # Install Atom extensions
    for t in ${atom[@]}; do
       apm install $t
    done

    # Install Visual Studio Code extensions
    for t in ${vscode[@]}; do
       code --install-extension $t
    done
}


function add_dock_items {
    apps=(
        "Visual Studio Code.app"
        'Spotify.app'
        'Microsoft Teams.app'
        'Microsoft Remote Desktop.app'
        'Google Chrome.app'
        'Microsoft Outlook.app'
    )

    # Add items to dock
    for t in "${apps[@]}"; do
       dockutil --add "/Applications/$t"
    done
}


function brew_install {
    # make sure brew installed
    which brew > /dev/null
    BREW_INSTALLED=$?

    # 1. If Homebrew is not installed, go ahead and install it
    if [ ! "$BREW_INSTALLED" -eq 0 ]; then
        echo "Homebrew not installed; installing now..."
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        which brew > /dev/null
        BREW_INSTALLED=$?
        if [ ! "$BREW_INSTALLED" -eq 0 ]; then
        return 1;
        fi
    fi

    # stop here if neofetch is already installed;
    # verifying installed formula can take seconds
    which neofetch > /dev/null
    NEOFETCH_INSTALLED=$?

    if [ "$NEOFETCH_INSTALLED" -eq 0 ]; then
        neofetch
        return 0;
    fi

    # list of formulas to install
    formulas=(
        cask
        ctags
        neofetch
        tree
        webp
        mame
        mas
        ntfs-3g
        bash
        brew-cask-completion
        tmux
        git
        # Command line tool for managing dock items
        # https://github.com/kcrawford/dockutil
        dockutil
    )

    # Needed taps for casks (are they still needed?)
    brew tap caskroom/cask
    brew tap caskroom/versions
   
    # loop through the formulas, install missing ones 
    for t in ${formulas[@]}; do
        #echo "checking if $t formula is installed..."
        brew ls --versions $t > /dev/null
        formula_installed=$?
        #echo "$t installed: $formula_installed"
        if [ ! "$formula_installed" -eq 0 ]; then
            echo "Installing '$t' formula..."
            brew install $t
        fi
    done

    # Install Homebrew Casks, NPM packages, and Mac App Store apps
    install_casks
    npm_install
    app_store_install
    extensions_install
    add_dock_items

    # open Neofetch
    neofetch
}

#
#    Opens php.ini for the current version of PHP, even if there are warnings.
#
function phpconf {
	if [[ -z "$1" ]]; then
	#1. php -v           - prints the current PHP version
	#2. head -1          - keeps only the first line of the output from php -v
	#3. awk '{print $2}' - splits the line by whitespace and keeps the second token ($2)
	#4. awk '{split($0, a, "."); print a[1] "." a[2];}' - splits the second token by a period character and then stores the array in a variable "a". Then, a second awk command is used to print the first and second elements with a period in the middle (the major and minor version of PHP).
	version=$(php -v | awk '/^PHP [0-9]+/ {print}' | awk '{print $2}' | awk '{split($0, a, "."); print a[1] "." a[2];}')
	else
	version="$1"
	fi

	# open the config file for PHP if it exists
	file="/usr/local/etc/php/$version/php.ini"

	if [ -e "$file" ]; then
	vi "$file"
	else
	echo "No php.ini file exists for version $version"
	fi
}

function oc-rsh {
    if [[ -z "$1" ]]; then
        echo "OpenShift pod name required."
        exit() { return 1; }
    else
    # ignore shibboleth pods
    # cronjob pods have unix timestamps (10-digits); ignore those
    # ignore build pods
    # ignore deploy pods
    oc rsh $(oc get pods | grep "$1" | grep Running | grep -v deploy | grep -v shibboleth | grep -v build | grep -ve '\d\d\d\d\d\d\d\d\d\d' | awk '{print $1}')
    fi
}

# Merges two or more branches and pushes the changes to the repo.
# TODO: use a loop so an infinite number of branches can be synced to the source branch
# TODO: make it so that no parameters shows help text
# TODO: make sure at least two branches are specified or show an error message
function gitsync {
        current=$(git symbolic-ref --short -q HEAD)
        if [[ -z "$1" ]]; then
            echo "Merges the current branch with the specified one, pushes the changes without leaving the current branch.";
            echo "usage: gitsync [destination]"
            exit() { return 1; }
        elif [ -z "$current" ]; then
            echo "Could not determine the current branch. Make sure the current folder is a git repository."
            echo "usage: gitsync [destination]"
            exit() { return 1; }
        else
            echo Merging "$1" branch into "$current" branch...
	    git checkout $1
            git merge $current
	    git push
	    git checkout $current
        fi
}

function filestokeep {
	echo 'Please make sure these files and folders are backed up before reinstalling macOS:'
	echo '~/.bash_profile'
	echo '~/.eslintrc'
	echo '~/.exrc'
	echo '~/.gitconfig'
	echo '~/.vimrc'
	echo '~/documents'
	echo '~/games/'
	echo '~/Music/iTunes/'
	echo '~/sites/certs/'
}

function install_apps {
        echo 'Adobe Creative Cloud - https://adobe.com'
        echo 'Atom                 - https://atom.io/'
        echo 'Backup & Sync        - https://www.google.com/drive/download/backup-and-sync/'
        echo 'Brother MFC-9130CW   - https://support.brother.com/g/b/producttop.aspx?c=us&lang=en&prod=mfc9130cw_us'
        echo 'Citrix Workspace     - https://toolbox.its.unc.edu'
        echo 'DaisyDisk            - https://itunes.apple.com/us/app/daisydisk/id411643860?mt=12'
        echo 'Docker               - https://www.docker.com/'
        echo 'Flycut               - https://github.com/TermiT/Flycut/releases'
        echo 'iTerm2               - https://iterm2.com/'
        echo 'Itsycal              - https://www.mowglii.com/itsycal/'
        echo 'JasperSoft Studio    - https://support.tibco.com/s/'
        echo 'MacPass              - https://macpassapp.org/'
        echo 'Magnet               - https://itunes.apple.com/us/app/magnet/id441258766?mt=12'
        echo 'MS Remote Desktop 10 - https://itunes.apple.com/us/app/microsoft-remote-desktop-10/id1295203466?mt=12'
        echo 'MS Teams             - https://teams.microsoft.com'
        echo 'Oracle SQL Developer - https://www.oracle.com/database/technologies/appdev/sql-developer.html'
        echo 'Postman              - https://www.getpostman.com/'
        echo 'SAS University       - https://www.sas.com/en_us/software/university-edition.html'
        echo 'VirtualBox           - https://www.virtualbox.org/'
        echo 'VLC                  - https://www.videolan.org/'
        echo 'VS Code              - https://code.visualstudio.com/'
        echo 'Xcode                - https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12'
}


function mycommands {
	echo 'apacheconf   - edit the configuration file for Apache'
	echo 'apachelog    - shows the error log for local apache instance'
	echo 'edithosts    - opens the virtual hosts config file for editing'
	echo 'filestokeep  - lists files and folders to keep before reinstalling macOS' 
	echo 'gitsync      - merges a branch with current one, pushes the changes without leaving the current branch'
        echo 'install_apps - lists all apps used for productivity'
        echo 'mkcd         - creates and changes to a new folder simultaneously'
        echo 'oc-rsh       - opens an SSH session into the pod of an application (if max pods = 1)'
	echo 'phpconf      - edit the configuration file for the current version of PHP'
	echo 'vsprojects   - changes to Visual Studio 2015 Projects folder on Windows 10'
}

function edithosts {
	vim '/usr/local/etc/httpd/extra/httpd-vhosts.conf'
}

function apachelog {
        apachelogfile="/usr/local/var/log/httpd/error_log"
        if [[ "$1" = "--clear" ]]; then
            sudo rm "$apachelogfile"
            echo "Apache log file '$apachelogfile' deleted."
        else
	    vim "$apachelogfile"
        fi
}

function apacheconf {
	vim '/usr/local/etc/httpd/httpd.conf'
}

function vsprojects {
	cd "/mnt/c/Users/Username/Documents/Visual\ Studio\ 2015/Projects"
}

export PATH="~/.composer/vendor/bin:$PATH"

# Setting PATH for Python 2.7
# The original version is saved in .bash_profile.pysave
#PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"

export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

export ANSIBLE_CONFIG="~/ansible/ansible.cfg"
ORACLE_HOME=/usr/local/lib

# Add Visual Studio Code (code)
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Add Python 2.7 wheel to PATH
# export PATH="~/Library/Python/2.7/bin:$PATH"

# Add Python 3.6 via Homebrew
export PATH="/usr/local/bin/python3:$PATH"

# highlights folders in blue using default settings
# https://www.cyberciti.biz/faq/apple-mac-osx-terminal-color-ls-output-option/
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
alias ls='ls -G'

# Homebrew Personal Access Token @ GitHub
# https://stackoverflow.com/a/20130816/1620794
export HOMEBREW_GITHUB_API_TOKEN=""

# install Homebrew and some formulas, then run neofetch
brew_install

# Allows you to use NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
