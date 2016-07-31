#!/bin/bash
# Tor + Privoxy + Chromium-browser
# Pablo Opazo

NORMAL="\\033[0;39m"
RED="\\033[1;31m"
BLUE="\\033[1;34m"
GREEN="\\033[1;32m"

help() {
  echo -e -n "$GREEN"
  echo "-----------------------------------------------------------------------"
  echo "                  ** Tuki - available commands **                      "
  echo "-----------------------------------------------------------------------"
  echo -e -n "$BLUE"
  echo "   > build - Buid docker containers"
  echo "   > start - Start private web-browsing"
  echo "   > stop  - Stop containers and close chromiun"
  echo "   > check - Check if the proxy is working"
  echo -e -n "$GREEN"
  echo "-----------------------------------------------------------------------"
}

if [[ -z $1 ]]; then
  help
fi

if [[ $UID != 0 ]]; then
    echo -e -n "$RED"
    echo "--> Please run this script with sudo: <--"
    echo "--> e.g sudo $0 $* <--"
    exit 1
fi

build() {
  docker run -d --restart always -v /etc/localtime:/etc/localtime:ro -p 9050:9050 --name torproxy jess/tor-proxy
  docker run -d --restart always -v /etc/localtime:/etc/localtime:ro --link torproxy:torproxy -p 8118:8118 --name privoxy jess/privoxy
}

start() {
  echo -e -n "$GREEN"
  echo "--> Starting Tuki <--"
  if ! docker inspect torproxy &> /dev/null; then
    echo "--> Building torproxy image <--"
    docker run -d --restart always -v /etc/localtime:/etc/localtime:ro -p 9050:9050 --name torproxy jess/tor-proxy
  fi

  if ! docker inspect privoxy &> /dev/null; then
    echo "--> Building privoxy image <--"
    docker run -d --restart always -v /etc/localtime:/etc/localtime:ro --link torproxy:torproxy -p 8118:8118 --name privoxy jess/privoxy
  fi

  docker start torproxy privoxy > /dev/null 2>&1
  /usr/bin/pkill --oldest --signal TERM -f chromium-browser > /dev/null 2>&1
  chromium-browser --incognito --proxy-server="127.0.0.1:8118" --temp-profile > /dev/null 2>&1 &
  echo "--> Tuki has started <--"
  exit 0
}

stop() {
  docker stop torproxy privoxy > /dev/null 2>&1
  /usr/bin/pkill --oldest --signal TERM -f chromium-browser
  echo -e -n "$GREEN" 
  echo "--> Tuki has been stopped <--"
}

check() {
  EXTERNAL_IP="$(curl -s -L http://ifconfig.co )"
  TOR_IP="$(curl -s -x http://localhost:8118 -L http://ifconfig.co)"

  if [[ $TOR_IP ]] && [[ $EXTERNAL_IP != $TOR_IP ]]; then
  	echo -e -n "$GREEN"
  	echo "--> The TOR proxy is working! <--"
  	echo "--> Your TOR IP is $TOR_IP <--"
  else
  	echo -e -n "$RED"
  	echo "--> The TOR proxy is not working! <--"
  fi
}

$*