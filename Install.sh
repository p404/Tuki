#!/bin/sh
# `sudo curl -sSL https://raw.githubusercontent.com/p404/Tuki/master/install.sh | bash`

INSTALL_LOCATION=/usr/local/bin

command_exists() {
    command -v "$@" > /dev/null 2>&1
}
	
if ! command_exists curl; then
    echo "Please install curl"
    exit 1
fi

SCRIPT_PATH=https://raw.githubusercontent.com/p404/Tuki/master/tuki.sh
httpcode=$(curl -s -o /dev/null -I -w '%{http_code}' --max-time 10 --retry-delay 2 --retry 3 $SCRIPT_PATH || echo "404" )
if [ $httpcode -eq 200 ]; then
	echo "Installing Tuki "
    sudo curl -sSL $SCRIPT_PATH > $INSTALL_LOCATION/tuki
    sudo chmod +x $INSTALL_LOCATION/tuki

else
    echo "Failed to pull installer off github.com (http err: ${httpcode}), please try again."
    exit 1
fi

exit 0
