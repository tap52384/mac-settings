#!/usr/bin/env bash

# include settings from .zlogin
# macOS loads settings from .zlogin on terminal login
# Ubuntu on WSL2 uses .bash_profile
# This allows compatibility with both systems
if [ -f "$HOME/.zlogin" ]; then
  . "$HOME/.zlogin"
fi

if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
