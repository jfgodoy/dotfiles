
# Update APT.
e_header "Updating APT"
sudo apt-get -y update >> $log
sudo apt-get -y upgrade >> $log

# Install APT packages.
packages=(
  guake
  build-essential
  git
  gitg
  git-cola
  diffuse
  vlc
  ubuntu-restricted-extras
  redis-server
  gnome-shell
  chromium-browser
  texmaker
  keepassx
)

list=()
for package in "${packages[@]}"; do
  if [[ ! "$(dpkg -l "$package" 2>/dev/null | grep "^ii  $package")" ]]; then
    list=("${list[@]}" "$package")
  fi
done

if (( ${#list[@]} > 0 )); then
  e_header "Installing APT packages: ${list[*]}"
  for package in "${list[@]}"; do
    sudo apt-get -y install "$package" >> $log
  done
fi