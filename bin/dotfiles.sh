echo 'dotfiles - Jorge Godoy <godoy.jf@gmail.com>'

# Logging stuff.
function e_header()   { echo -e "\n\033[1m$@\033[0m"; }
function e_success()  { echo -e " \033[1;32m✔\033[0m  $@"; }
function e_error()    { echo -e " \033[1;31m✖\033[0m  $@"; }
function e_arrow()    { echo -e " \033[1;33m➜\033[0m  $@"; }


# run init files.
function init_do() {
  source "$2"
}

# Link files.
function link_header() { e_header "Linking files into home directory"; }
function link_test() {
  [[ "$1" -ef "$2" ]] && echo "same file"
}
function link_do() {
  e_success "Linking ~/$1."
  ln -sf ${2#$HOME/} ~/
}

# Copy files.
function copy_header() { e_header "Copying files into home directory"; }
function copy_test() {
  if [[ -e "$2" && ! "$(cmp "$1" "$2" 2> /dev/null)" ]]; then
    echo "same file"
  elif [[ "$1" -ot "$2" ]]; then
    echo "destination file newer"
  fi
}
function copy_do() {
	e_success "Copying ~/$1."
	cp "$2" ~/
}

# Copy, link, init, etc.
function do_stuff() {
  local base dest skip
  local files=(~/.dotfiles/$1/*)
  # No files? abort.
  if (( ${#files[@]} == 0 )); then return; fi
  # Run _header function only if declared.
  [[ $(declare -f "$1_header") ]] && "$1_header"
  # Iterate over files.
  for file in "${files[@]}"; do
    base="$(basename $file)"
    dest="$HOME/$base"
    # Run _test function only if declared.
    if [[ $(declare -f "$1_test") ]]; then
      # If _test function returns a string, skip file and print that message.
      skip="$("$1_test" "$file" "$dest")"
      if [[ "$skip" ]]; then
        e_error "Skipping ~/$base, $skip."
        continue
      fi
      # Destination file already exists in ~/. Back it up!
      if [[ -e "$dest" ]]; then
        e_arrow "Backing up ~/$base."
        # Set backup flag, so a nice message can be shown at the end.
        backup=1
        # Create backup dir if it doesn't already exist.
        [[ -e "$backup_dir" ]] || mkdir -p "$backup_dir"
        # Backup file / link / whatever.
        mv "$dest" "$backup_dir"
      fi
    fi
    # Do stuff.
    "$1_do" "$base" "$file"
  done
}

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
  new_dotfiles_install=1
  # ~/.dotfiles doesn't exist? Clone it!
  e_header "Downloading dotfiles"
  git clone --recursive https://github.com/jfgodoy/dotfiles.git ~/.dotfiles
  cd ~/.dotfiles
else
  # Make sure we have the latest files.
  e_header "Updating dotfiles"
  cd ~/.dotfiles
  git pull
  git submodule update --init --recursive --quiet
fi

# Tweak file globbing.
shopt -s dotglob
shopt -s nullglob

# Create caches directory, if it doesn't already exist.
mkdir -p "$HOME/.dotfiles/caches"

# If backups are needed, this is where they'll go.
backup_dir="$HOME/.dotfiles/backups/$(date "+%Y_%m_%d-%H_%M_%S")/"
backup=

# Execute code for each file in these subdirectories.
do_stuff "init"
do_stuff "copy"
do_stuff "link"

# Alert if backups were made.
if [[ "$backup" ]]; then
  echo -e "\nBackups were moved to ~/${backup_dir#$HOME/}"
fi

# All done!
e_header "All done!"