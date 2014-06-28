sudo add-apt-repository -y "deb http://repository.spotify.com stable non-free";
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 94558F59 >> $log;
sudo apt-get update >> $log;
sudo apt-get -y install spotify-client >> $log;
