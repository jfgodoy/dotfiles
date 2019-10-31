#!/bin/bash
echo 'dotfiles - Jorge Godoy <godoy.jf@gmail.com>'

# log file
log=~/.dotfiles/log

# Clear log
rm -f $log

# Logging stuff.
function e_header()   { echo -e "\n\033[1m$@\033[0m" | tee -a $log; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@" | tee -a $log; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@" | tee -a $log; }
function e_arrow()    { echo -e " \033[1;33m➜\033[0m  $@" | tee -a $log; }


# Installing

# If Git is not installed, install it
if [[ ! "$(type -P git)" ]]; then
  e_header "Installing Git"
  sudo apt-get -qq install git-core
fi

# If Git isn't installed by now, something exploded. We gots to quit!
if [[ ! "$(type -P git)" ]]; then
  e_error "Git should be installed. It isn't. Aborting."
  exit 1
fi

# Initialize.
if [[ ! -d ~/.dotfiles ]]; then
  # ~/.dotfiles doesn't exist? Clone it!
  e_header "Downloading dotfiles"
  git clone --recursive https://github.com/jfgodoy/dotfiles.git ~/.dotfiles
  cd ~/.dotfiles
else
  # Make sure we have the latest files.
  e_header "Updating dotfiles"
  cd ~/.dotfiles
  if (($(git status -s | wc -l) == 0)); then
    git pull
    e_success "project fetched from github"
  else
    e_error "can't fetch, there are uncommitted files"
  fi
  git submodule update --init --recursive --quiet
fi

# Tweak file globbing.
shopt -s dotglob   # expands a dotfiles too
shopt -s nullglob  # not matched glob expands to null

# Create data directory, if it doesn't already exist.
mkdir -p "$HOME/.dotfiles/data"

# link all files inside links
for file in $HOME/.dotfiles/links/*; do
  ln -sf $file ~/${file#$HOME/.dotfiles/links/}
  e_success "symbolic linked $file"
done


# add load.sh to ~/.bashrc
if ! grep -q .dotfiles ~/.bashrc; then
  echo -e "\n#load dotfiles\nsource ~/.dotfiles/load.sh" >> ~/.bashrc
fi
e_success "dotfiles installed in ~/.bashrc"

# All done!
e_header "All done!"