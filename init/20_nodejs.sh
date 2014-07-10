
version="v0.10.29"
url="http://nodejs.org/dist/$version/node-$version.tar.gz"

# If Git isn't installed by now, something exploded. We gots to quit!
if [[ ! "$(type -P node)" || "$version" != "$(node --version)" ]]; then
  e_header "Installing node $version"
  pushd /tmp
  mkdir node
  curl $url | tar xvzf - --strip-components=1 -C node
  cd node
  ./configure
  make
  sudo make install
  popd
  rm -rf /tmp/node
  e_success "Node $version was installed."
else
  e_success "Node $version is already installed."
fi


npm_globals=(
  bower
  grunt-cli
  jshint
  jscs
  uglify-js
  node-inspector
  david
  mocha
  node-static
  jake
)

# Install npm modules.
if [[ "$(type -P npm)" ]]; then
  e_header "Updating Npm"
  sudo npm update -g npm

  { pushd "$(npm config get prefix)/lib/node_modules"; installed=(*); popd; } > /dev/null
  list="$(to_install "${npm_globals[*]}" "${installed[*]}")"
  if [[ "$list" ]]; then
    e_header "Installing npm modules: $list"
    sudo npm install -g $list
  fi

  # Update npm modules
  e_header "Updating npm modules"
  sudo david update --global

fi

