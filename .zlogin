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
    apm upgrade -c false
    # Update all Mac App Store apps
    # mas upgrade
    # Install and Update PHP Composer
    install_composer
    composer selfupdate
    docker system prune -f
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
        'Microsoft Remote Desktop.app'
        'Microsoft Outlook.app'
        'Brave Browser.app'
        'LastPass.app'
        'iTerm.app'
    )

    # Add items to dock
    for t in "${apps[@]}"; do
       dockutil --add "/Applications/$t"
    done
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
       # mas install $t
    done

    # Upgrade all applications
    # mas upgrade
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
            'atom'
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
            'postman'
            'sequel-pro'
            'slack'
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
        fi
    done

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
        bash
        brew-cask-completion
        cask
        ctags
        # Command line tool for managing dock items
        # https://github.com/kcrawford/dockutil
        dockutil
        git
        lastpass-cli
        libiconv
        neofetch
        openldap
        mame
        ntfs-3g
        openshift-cli
        # Pandoc - a universal document converter (https://pandoc.org)
        pandoc-citeproc
        php
        podman
        powershell
        tmux
        tree
        webp
        zsh
        zsh-syntax-highlighting
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
    # app_store_install
    extensions_install
    add_dock_items

    # open Neofetch
    neofetch
}


function myip {
    echo $(ifconfig | grep -v 127.0.0.1 | grep -v ::1 | grep -i "broadcast" | grep "inet")
}

# install Homebrew and some formulas, then run neofetch
brew_install
