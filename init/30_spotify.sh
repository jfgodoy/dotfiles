# source: https://www.spotify.com/cl/download/linux/
# 1. Add the Spotify repository signing key to be able to verify downloaded packages
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886 >> $log

# 2. Add the Spotify repository
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list >> $log

# 3. Update list of available packages
sudo apt-get update >> $log

# 4. Install Spotify
sudo apt-get -y install spotify-client >> $log
