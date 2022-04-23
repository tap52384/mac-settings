# mac-settings

bash_profile, visual studio code user settings, terminal customizations, and
more for macOS

## Usage

In a macOS/WSL2 terminal:

```bash
# Open the App Store and sign in. Login cannot be scripted:
open /System/Applications/App\ Store.app/
# Instructions inspired by https://stackoverflow.com/a/36084134/1620794
cd ~
# Make a directory for your code
mkdir -p ~/code
# may have to install command-line tools
git init
# Agree to the Xcode/iOS license if you haven't already (macOS only)
xcode-select --install
sudo xcodebuild -license accept
# Links the current directory to this repo
git remote add origin https://github.com/tap52384/mac-settings.git
# Fetch all branches for this repository
git fetch --all
# Checks out the "dev" branch and sets the upstream to "origin/dev"
git checkout origin/dev -t
```

### TODO

- Add new functions from zsh files in this repo to `.bash_profile`
  - Add a section for installing applications via winget if the command is
    available

- [StackOverflow - How to move all files including hidden files into parent directory via](https://stackoverflow.com/a/20192079/1620794)
  - Has instructions for how to both move all files and copy all files

## Purpose

This code has several purposes:

- To quickly install applications via terminal
  - [Homebrew](https://brew.sh/)
  - [Mac App Store command line interface](https://github.com/mas-cli/mas)
  - [Node Version Manager](https://github.com/creationix/nvm)
- Install extensions
  - [Visual Studio Code](https://code.visualstudio.com/)
- Add Bash functions for OpenShift (use [oc](https://docs.openshift.com/container-platform/4.7/cli_reference/openshift_cli/developer-cli-commands.html) to
tail logs and SSH into a pod)

## Links

- [Homebrew](https://brew.sh/)
- [LSCOLORS Generator](https://geoff.greer.fm/lscolors/)
