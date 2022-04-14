#!/usr/bin/env bash

function install_composer {
    # Install PHP Composer
    command -v composer > /dev/null
    COMPOSER_INSTALLED=$?

    if [ ! "$COMPOSER_INSTALLED" -eq 0 ]; then
        echo "Composer not installed; downloading and installing now..."
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
        chmod +x /usr/local/bin/composer
    else
        echo "Composer is already installed."
    fi
}

#
#   Update all Homebrew, Atom, and VS Code packages
function update_formulas {
    # Make sure the xcode command line tools are installed
    # https://stackoverflow.com/a/15371967/1620794
    xcode-select -p 1>/dev/null
    XCODE_CLI_TOOLS_INSTALLED=$?

    if [ ! "$XCODE_CLI_TOOLS_INSTALLED" -eq 0 ]; then
	xcode-select --install
    fi

    brew update
    brew upgrade
    brew cleanup -s
    brew doctor
    brew missing
    # Update all Atom packages
    # apm upgrade -c false
    # Update all Mac App Store apps
    # mas upgrade
    # Install and Update PHP Composer
    install_composer
    composer selfupdate

    command -v docker > /dev/null
    DOCKER_INSTALLED=$?

    if [ "$DOCKER_INSTALLED" -eq 0 ]; then
        # Prune every docker object, including volumes
        # https://docs.docker.com/config/pruning/
        docker system prune --volumes -f
    else
        echo "Docker is not installed; system prune failed."
    fi
}

function oc-rsh {
    if [[ -z "$1" ]]; then
        echo "OpenShift pod name required."
        exit() { return 1; }
    fi

    # 1. Login with the OpenShift command-line tools (oc)
    # The "whoami" command gets your computer username; if your computer username is
    # not your Onyen, then use your Onyen instead
    oc whoami > /dev/null 2>&1 || oc login

    # Only keep running pods with the specified app name ($1)
    # Ignore deploy, build, and cronjob pods
    # cronjob pods have unix timestamps (10-digits)
    oc rsh "$(oc get pods --selector deploymentconfig="$1" | grep Running | grep -v deploy | grep -v build | grep -ve '\d{10}' | awk '{print $1}')"
}

function oc-logs {
    if [[ -z "$1" ]]; then
        echo "OpenShift pod name required."
        exit() { return 1; }
    fi

    oc whoami > /dev/null 2>&1 || oc login

    # Only keep running pods with the specified app name ($1)
    # Ignore shibboleth, deploy, build, and cronjob pods
    # cronjob pods have unix timestamps (10-digits)
    oc logs "$(oc get pods --selector deploymentconfig="$1" | grep Running | grep -v deploy | grep -v build | grep -ve '\d{10}' | awk '{print $1}')" -f
    # oc logs "$(oc get pods | grep "$1" | grep Running | grep -v deploy | grep -v build | grep -ve '\d{10}' | awk '{print $1}')" -f
}

# Merges the current branch into the specified branch and then switches back. Does a "git pull" before merging.
# TODO: use a loop so an infinite number of branches can be synced to the source branch
# TODO: make it so that no parameters shows help text
# TODO: make sure at least two branches are specified or show an error message
function gitsync {
    current=$(git symbolic-ref --short -q HEAD)
    if [[ -z "$1" ]]; then
        echo "Merges the current branch with the specified one, pushes the changes without leaving the current branch.";
        echo "usage: gitsync [destination]"
        exit() { return 1; }
    fi

    if [ -z "$current" ]; then
        echo "Could not determine the current branch. Make sure the current folder is a git repository."
        echo "usage: gitsync [destination]"
        exit() { return 1; }
    fi

    echo Merging "$current" branch into "$1" branch...
    echo Switching to "$1" branch...
    git checkout "$1" || { echo "The branch '$1' may not exist."; return 1; }
    echo Pulling latest changes into "$1" branch before merging...
    git pull
    echo Merging origin/"$current" branch into "$1" branch...
    git merge origin/"$current"
    git push
    git checkout "$current"
}

function add_dock_items {
    # make sure brew installed
    command -v dockutil > /dev/null
    DOCKUTIL_INSTALLED=$?

    # 1. If Homebrew is not installed, go ahead and install it
    if [ ! "$DOCKUTIL_INSTALLED" -eq 0 ]; then
        echo "Dockutil not installed; attempting installation..."
        brew install dockutil
        command -v dockutil > /dev/null
        DOCKUTIL_INSTALLED=$?
        if [ ! "$DOCKUTIL_INSTALLED" -eq 0 ]; then
        echo "Dockutil unavailable; stopping here..."
        return 1;
        fi
    fi

    apps=(
        "Visual Studio Code.app"
        'Microsoft Teams.app'
        # 'Microsoft Remote Desktop.app'
        'Microsoft Outlook.app'
        'Brave Browser.app'
        'LastPass.app'
        'iTerm.app'
        'Google Chrome.app'
    )

    # Add items to dock
    for t in "${apps[@]}"; do
       dockutil --add "/Applications/$t"
    done

    apps=(
        'Reminders'
        'Mail'
        'Launchpad'
        'News'
        'Podcasts'
    )

    # Remove items from dock
    for t in "${apps[@]}"; do
        dockutil --remove "$t"
    done

    dockutil --move 'Brave Browser' --after 'Safari'
    dockutil --move 'Google Chrome' --after 'Brave Browser'
    dockutil --move 'iTerm' --after 'Notes'
    dockutil --move 'Visual Studio Code' --after 'Notes'
    dockutil --move 'Microsoft Outlook' --after 'Google Chrome'
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
        # Official Microsoft extension for Docker
        'ms-azuretools.vscode-docker'
        # Official Microsoft extension for Python
        'ms-python.python'
        # Official Microsoft extension for using Docker containers
        'ms-vscode-remote.remote-containers',
        # ShellCheck linter for Bash Scripts
        'timonwong.shellcheck'
    )

    # Install Atom extensions (if atom is installed)
    command -v apm > /dev/null
    ATOM_INSTALLED=$?

    if [ "$ATOM_INSTALLED" -eq 0 ]; then
        for t in ${atom[@]}; do
            apm install $t
        done
    fi;

    # Install Visual Studio Code extensions
    which code > /dev/null
    VSCODE_INSTALLED=$?

    if [ "$VSCODE_INSTALLED" -eq 0 ]; then
        for t in ${vscode[@]}; do
            code --install-extension $t
        done
    fi;
}

function app_store_install {
    # list of apps
    apps=(
        '411643860'  # DaisyDisk
        '497799835'  # Xcode
        '441258766'  # Magnet
        # '1295203466' # Microsoft Remote Desktop 10.0
        '462054704'  # Microsoft Word
        '784801555'  # Microsoft OneNote
        '462062816'  # Microsoft PowerPoint
        '462058435'  # Microsoft Excel
        '985367838'  # Microsoft Outlook
        '682658836'  # Garageband
        '926036361'  # LastPass Password Manager
        '823766827'  # Microsoft OneDrive
        '1274495053' # Microsoft To Do
        # '1287752517' # Alto's Adventure
        '634159523'  # MainStage 3 (3.4.4)
        # '1495097700' # Alto's Odyssey (1.0.7)
        '1099120373' # Exporter (2.1.4)
        '408981434'  # iMovie (10.1.15)
        '1378806557' # TeraCopy (1.0)
        '1032755628' # Duplicate File Finder (6.7.4)
        '1496833156' # Playgrounds (3.3.1)
        '640199958'  # Developer (8.4)
        '409203825'  # Numbers
	'1193539993' # Brother iPrint&Scan
    )

    command -V mas > /dev/null
    MAS_INSTALLED=$?

    if [ "$MAS_INSTALLED" -eq 0 ]; then
        # loop through the formulas, install missing ones
        for t in ${apps[@]}; do
        mas install $t
        done

        # Upgrade all applications
        mas upgrade
    fi;
}

#
#  Installs NPM packages.
#
function npm_install {
    # Install Node via NVM using the official method
    # Best method since it does not require root!
    # Node Version Manager
    # https://github.com/nvm-sh/nvm
    touch ~/.zshrc
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    nvm install node

    packages=(
        '@google/clasp'
        'eslint'
        'eslint-config-jquery'
        'generator-code'
        'gulp'
        'gulp-cli'
        'inquirer'
        'vsce'
        'yo'
    )

    # loop through the formulas, install missing ones
    for t in ${packages[@]}; do
        npm install -g $t
    done
}

function install_oh_my_zsh {
    # Install Oh My Zsh - https://github.com/ohmyzsh/ohmyzsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    # Install Powerlevel10k theme for Oh My Zsh
    # https://github.com/romkatv/powerlevel10k#installation
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>! ~/.zshrc
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
            '4k-video-downloader'
            'adobe-creative-cloud'
	    'audacity'
            # Like SQL Developer, but for SQL Server
            'azure-data-studio'
            'brave-browser'
            'calibre'
            'clone-hero'
            'docker'
            'dotnet-sdk'
            'firefox'
            'flycut'
            'google-chrome'
	    'google-drive'
            # 'grammarly'
            'intellij-idea-ce'
            'iterm2'
            'itsycal'
            'lastpass'
            'mactex'
            'macpass'
            'microsoft-teams'
            'mysqlworkbench'
	    'obs'
            'onedrive'
            'openemu'
            'powershell'
            'postman'
            'proxyman'
            'retroarch'
            'sf-symbols'
            'skype'
            'slack'
            'soapui'
            'spotify'
            # 'sublime-text'
            # 'tableau-reader'
            'virtualbox'
            'virtualbox-extension-pack'
            'visual-studio-code'
            'vlc'
	    'wine-stable'
            'youtube-to-mp3'
            'zoom'
        )

    # Apps that cannot be installed via shell
    # Cisco AnyConnect Secure Mobility Client
    # Oracle SQL Developer
    # Citrix Workspace 

    # loop through the formulas, install missing ones
    for t in ${casks[@]}; do
        #echo "checking if $t formula is installed..."
        brew ls --versions $t > /dev/null
        formula_installed=$?
        #echo "$t installed: $formula_installed"
        if [ ! "$formula_installed" -eq 0 ]; then
            echo "Installing '$t' cask..."
            brew install --cask $t
        else
            echo "Cask '$t' is already installed; skipping..."
        fi
    done

    # Install PHP Composer
    # install_composer
}

function brew_install {
    touch ~/.zshrc

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
    # This prevents the rest of this function from running more than once.
    command -v neofetch > /dev/null
    NEOFETCH_INSTALLED=$?

    if [ "$NEOFETCH_INSTALLED" -eq 0 ]; then
        return 0;
    fi

    # list of formulas to install
    formulas=(
        # bash
        brew-cask-completion
        cask
	coreutils
        ctags
        # Command line tool for managing dock items
        # https://github.com/kcrawford/dockutil
        # dockutil
        gh
        git
        git-extras
        java
        jq
        lastpass-cli
        # https://www.videolan.org/developers/libdvdcss.html
        libdvdcss
        libiconv
        # mac app store - https://github.com/mas-cli/mas
        mas
        neofetch
        mame
        # ntfs-3g
        openshift-cli
        # Pandoc - a universal document converter (https://pandoc.org)
        # https://github.com/jgm/pandoc
        pandoc
        php
        podman
        romkatv/powerlevel10k/powerlevel10k
	ruby
        # Linter for Bash scripts
        shellcheck
        source-to-image
	# Open source file recovery utility (https://www.cgsecurity.org/)
	# TestDisk and PhotoRec are installed
	testdisk
        tmux
        tree
	vagrant
        webp
        # zsh
        zsh-autosuggestions
        zsh-completions
        zsh-syntax-highlighting
    )

    # loop through the formulas, install missing ones
    for t in ${formulas[@]}; do
        #echo "checking if $t formula is installed..."
        brew ls --versions "$t" > /dev/null
        formula_installed=$?
        #echo "$t installed: $formula_installed"
        if [ ! "$formula_installed" -eq 0 ]; then
            echo "Installing '$t' formula..."
            brew install "$t"
        fi
    done

    # Install Homebrew Casks, NPM packages, and Mac App Store apps
    install_casks
    npm_install
    extensions_install
    configure_git
    app_store_install
    # add_dock_items
    # install_oh_my_zsh

    # open Neofetch
    neofetch
}

# Configure global git settings
function configure_git {
    git config --global alias.lol "log --graph --decorate --pretty=oneline --abbrev-commit"
    git config --global alias.lola "log --graph --decorate --pretty=oneline --abbrev-commit --all"
    git config --global branch.autosetuprebase always
    git config --global color.branch true
    git config --global color.diff true
    git config --global color.interactive true
    git config --global color.status true
    git config --global color.ui true
    git config --global core.autocrlf input
    git config --global init.defaultBranch main
    # Should use appropriate credentials based on repo
    # https://git-scm.com/docs/gitcredentials#Documentation/gitcredentials.txt-useHttpPath
    git config --global credential.useHttpPath true
    echo "Your name to appear as author of git commits: "
    read namevar
    echo "Entered name: $namevar"
    git config --global user.name "$namevar"
    echo "Your email for git commits (use work email if work computer): "
    read emailvar
    git config --global user.email "$emailvar"
}


function myip {
    echo $(ifconfig | grep -v 127.0.0.1 | grep -v ::1 | grep -i "broadcast" | grep "inet")
}

# install Homebrew and some formulas, then run neofetch
brew_install
