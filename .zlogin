function install_composer {
    # Install PHP Composer
    which composer > /dev/null
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
    brew update
    brew upgrade
    brew cask upgrade
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

    which docker > /dev/null
    DOCKER_INSTALLED=$?

    if [ "$DOCKER_INSTALLED" -eq 0 ]; then
        docker system prune -f
    else
        echo "Docker is not installed; system prune failed."
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
        elif [ -z "$current" ]; then
            echo "Could not determine the current branch. Make sure the current folder is a git repository."
            echo "usage: gitsync [destination]"
            exit() { return 1; }
        else
            echo Merging "$current" branch into "$1" branch...
            echo Switching to "$1" branch...
	        git checkout $1
            echo Pulling latest changes into "$1" branch before merging...
            git pull
            echo Merging "$current" branch into "$1" branch...
            git merge $current
	        git push
	        git checkout $current
        fi
}

function add_dock_items {
    # make sure brew installed
    which dockutil > /dev/null
    DOCKUTIL_INSTALLED=$?

    # 1. If Homebrew is not installed, go ahead and install it
    if [ ! "$DOCKUTIL_INSTALLED" -eq 0 ]; then
        echo "Dockutil not installed; attempting installation..."
        brew install dockutil
        which dockutil > /dev/null
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
        'ms-azuretools.vscode-docker'
        'ms-python.python'
        'ms-vscode-remote.remote-containers'
    )

    # Install Atom extensions
    which apm > /dev/null
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
        '1295203466' # Microsoft Remote Desktop 10.0
        '462054704'  # Microsoft Word
        '784801555'  # Microsoft OneNote
        '462062816'  # Microsoft PowerPoint
        '462058435'  # Microsoft Excel
        '985367838'  # Microsoft Outlook
        '682658836'  # Garageband
        '926036361'  # LastPass Password Manager
        '823766827'  # Microsoft OneDrive
    )

    # loop through the formulas, install missing ones
    for t in ${apps[@]}; do
       mas install $t
    done

    # Upgrade all applications
    mas upgrade
}

#
#  Installs NPM packages.
#
function npm_install {
    # Install Node via NVM using the official method
    # Best method since it does not require root!
    # Node Version Manager
    # https://github.com/nvm-sh/nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
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
            'adobe-creative-cloud'
            # 'atom'
            'brave-browser'
            'docker'
            'firefox'
            'flycut'
            'google-backup-and-sync'
            'google-chrome'
            'iterm2'
            'itsycal'
            'java'
            'lastpass'
            'macpass'
            'microsoft-teams'
            'netbeans-php'
            'podman'
            'powershell'
            'postman'
            'sequel-pro'
            'soapui'
            'spotify'
            'sublime-text'
            'tableau-reader'
            'virtualbox'
            'virtualbox-extension-pack'
            'visual-studio-code'
            'vlc'
            'youtube-to-mp3'
            'zoomus'
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
        else
            echo "Cask '$t' is already installed; skipping..."
        fi
    done

    # Install PHP Composer
    install_composer
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
        # bash
        brew-cask-completion
        cask
        ctags
        # Command line tool for managing dock items
        # https://github.com/kcrawford/dockutil
        dockutil
        git
        lastpass-cli
        libiconv
        # mac app store - https://github.com/mas-cli/mas
        mas
        neofetch
        mame
        # ntfs-3g
        openshift-cli
        # Pandoc - a universal document converter (https://pandoc.org)
        pandoc-citeproc
        source-to-image
        tmux
        tree
        webp
        zsh
        zsh-autosuggestions
        zsh-completions
        zsh-syntax-highlighting
    )

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
    extensions_install
    add_dock_items
    install_oh_my_zsh

    # open Neofetch
    neofetch
}


function myip {
    echo $(ifconfig | grep -v 127.0.0.1 | grep -v ::1 | grep -i "broadcast" | grep "inet")
}

# install Homebrew and some formulas, then run neofetch
brew_install
