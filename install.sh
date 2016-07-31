#!/bin/sh
# `curl -ssl https://raw.githubusercontent.com/p404/Tuki/master/install.sh | sudo bash`
# Tested on Ubuntu 16.04

INSTALL_LOCATION=/usr/local/bin

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

install_requirements() {
  echo "--> Ensuring we have the proper dependencies <--"
  apt-get update -qq > /dev/null
  apt-get -qq -y install apt-transport-https
 
  if ! command_exists chromium-browser ; then
    echo "--> Installing Chromiun <--"
    apt-get -qq -y install chromium-browser 
  fi

  if ! command_exists docker; then
    echo "--> Installing Docker <--"
    wget -nv -O - https://get.docker.com/ | sh  
  fi
}
  

SCRIPT_PATH=https://raw.githubusercontent.com/p404/Tuki/master/tuki.sh
httpcode=$(curl -s -o /dev/null -I -w '%{http_code}' --max-time 10 --retry-delay 2 --retry 3 $SCRIPT_PATH || echo "404" )
if [ $httpcode -eq 200 ]; then
	install_requirements
	echo "--> Installing Tuki <--"
    curl -sSL $SCRIPT_PATH > $INSTALL_LOCATION/tuki
    chmod +x $INSTALL_LOCATION/tuki
    echo "--> Done <--"
else
    echo "Failed to pull tuki off github.com (http err: ${httpcode}), please try again."
    exit 1
fi

exit 0