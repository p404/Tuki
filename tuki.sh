#!/bin/bash
# Tor + Privoxy + Chromiun
# TODO
# Better build - rebuilding the images, better check against tor api

#docker pull jess/tor-proxy
#docker pull jess/privoxy

NORMAL="\\033[0;39m"
RED="\\033[1;31m"
BLUE="\\033[1;34m"
GREEN="\\033[1;32m"


help() {
  echo -e -n "$GREEN"
  echo "-----------------------------------------------------------------------"
  echo "                     ** Available commands **                          "
  echo "-----------------------------------------------------------------------"
  echo -e -n "$BLUE"
  echo "   > build - Install docker images"
  echo "   > start - Start private web-browsing"
  echo "   > stop  - Stop docker containers and close chromiun web browser"
  echo "   > check - Check if the proxy is working "
  echo -e -n "$GREEN"
  echo "-----------------------------------------------------------------------"
}

build() {
  docker run -d --restart always -v /etc/localtime:/etc/localtime:ro -p 9050:9050 --name torproxy jess/tor-proxy
  docker run -d --restart always -v /etc/localtime:/etc/localtime:ro --link torproxy:torproxy -p 8118:8118 --name privoxy jess/privoxy
}

start() {
  sudo /usr/bin/pkill --oldest --signal TERM -f chromium-browser > /dev/null 2>&1
  sudo docker start torproxy privoxy > /dev/null 2>&1
  chromium-browser --incognito --proxy-server="127.0.0.1:8118" --temp-profile > /dev/null 2>&1 &
}

stop() {
  sudo docker stop torproxy privoxy > /dev/null 2>&1
  sudo /usr/bin/pkill --oldest --signal TERM -f chromium-browser > /dev/null 2>&1
}

check() {
  EXTERNAL_IP="$(curl -s -L http://ifconfig.co )"
  TOR_IP="$(curl -s -x http://localhost:8118 -L http://ifconfig.co)"

  if [[ $TOR_IP != $EXTERNAL_IP ]]; then
  	echo -e -n "$GREEN"
  	echo "The TOR proxy is working!"
  	echo "Your IP is $TOR_IP"
  else
  	echo -e -n "$RED"
  	echo "The TOR proxy is not working!"
  fi
}

$*





