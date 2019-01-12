neofetch

#
#   mkcd command
#   This is an improvised version of the mkcd command at http://superuser.com/questions/152794/is-there-a-shortcut-to-mkdir-foo-and-immediately-cd-into-it
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

function mycommands {
	echo 'apacheconf  - edit the configuration file for Apache'
	echo 'apachelog   - shows the error log for local apache instance'
	echo 'edithosts   - opens the virtual hosts config file for editing'
	echo 'filestokeep - lists files and folders to keep before reinstalling macOS' 
	echo 'gitsync     - merges a branch with current one, pushes the changes without leaving the current branch'
        echo 'mkcd        - creates and changes to a new folder simultaneously'
        echo 'oc-rsh      - opens an SSH session into the pod of an application (if max pods = 1)'
	echo 'phpconf     - edit the configuration file for the current version of PHP'
	echo 'vsprojects  - changes to Visual Studio 2015 Projects folder on Windows 10'
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

# Add Python 3.6 via Homebrew
export PATH="/usr/local/bin/python3:$PATH"

alias ls='ls -G'

# Homebrew Personal Access Token @ GitHub
# https://stackoverflow.com/a/20130816/1620794
export HOMEBREW_GITHUB_API_TOKEN=""
