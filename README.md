# mac-settings

bash_profile, visual studio code user settings, terminal customizations, and
more for macOS

## Usage

In a macOS terminal:

```bash
# Instructions inspired by https://stackoverflow.com/a/36084134/1620794
cd ~
# may have to install command-line tools
git init
# Agree to the Xcode/iOS license if you haven't already
xcode-select --install
sudo xcodebuild -license accept
# Links the current directory to this repo
git remote add origin https://github.com/tap52384/mac-settings.git
# Checks out the "dev" branch and sets the upstream to "origin/dev"
git checkout origin/dev -t
```

## Purpose

This code has several purposes:

-   To quickly install applications via terminal
    -   [Homebrew](https://brew.sh/)
    -   [Mac App Store command line interface](https://github.com/mas-cli/mas)
    -   [Node Version Manager](https://github.com/creationix/nvm)
-   Install extensions
    -   Atom
    -   Visual Studio Code
-   Monitor and capture configurations for apps
    -   Atom
    -   Visual Studio Code

## Links

[Homebrew](https://brew.sh/)
[LSCOLORS Generator](https://geoff.greer.fm/lscolors/)
