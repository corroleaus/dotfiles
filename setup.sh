#!/bin/bash

set -e
set -x
# basic stuff
cd $(dirname $0)
SCRIPTDIR=$(pwd)


if [ "$#" -ne 1 ]; then
    echo "Must be exactly one parameter - Username"
    exit 1
fi

USERNAME=$1

# throw out the cloud shit.
# dpkg-reconfigure cloud-init
# sudo apt-get purge cloud-init
# sudo mv /etc/cloud/ ~/; sudo mv /var/lib/cloud/ ~/cloud-lib
sudo apt remove open-iscsi

echo "#deb cdrom:[Ubuntu 18.04 LTS _Bionic Beaver_ - Release amd64 (20180426)]/ bionic main restricted

# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
# newer versions of the distribution.
deb http://us.archive.ubuntu.com/ubuntu/ bionic main restricted
# deb-src http://us.archive.ubuntu.com/ubuntu/ bionic main restricted

## Major bug fix updates produced after the final release of the
## distribution.
deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted
# deb-src http://us.archive.ubuntu.com/ubuntu/ bionic-updates main restricted

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team. Also, please note that software in universe WILL NOT receive any
## review or updates from the Ubuntu security team.
deb http://us.archive.ubuntu.com/ubuntu/ bionic universe
# deb-src http://us.archive.ubuntu.com/ubuntu/ bionic universe
deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates universe
# deb-src http://us.archive.ubuntu.com/ubuntu/ bionic-updates universe

## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
## team, and may not be under a free licence. Please satisfy yourself as to
## your rights to use the software. Also, please note that software in
## multiverse WILL NOT receive any review or updates from the Ubuntu
## security team.
deb http://us.archive.ubuntu.com/ubuntu/ bionic multiverse
# deb-src http://us.archive.ubuntu.com/ubuntu/ bionic multiverse
deb http://us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse
# deb-src http://us.archive.ubuntu.com/ubuntu/ bionic-updates multiverse

## N.B. software from this repository may not have been tested as
## extensively as that contained in the main release, although it includes
## newer versions of some applications which may provide useful features.
## Also, please note that software in backports WILL NOT receive any review
## or updates from the Ubuntu security team.
deb http://us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src http://us.archive.ubuntu.com/ubuntu/ bionic-backports main restricted universe multiverse

## Uncomment the following two lines to add software from Canonical's
## 'partner' repository.
## This software is not part of Ubuntu, but is offered by Canonical and the
## respective vendors as a service to Ubuntu users.
# deb http://archive.canonical.com/ubuntu bionic partner
# deb-src http://archive.canonical.com/ubuntu bionic partner

deb http://security.ubuntu.com/ubuntu bionic-security main restricted
# deb-src http://security.ubuntu.com/ubuntu bionic-security main restricted
deb http://security.ubuntu.com/ubuntu bionic-security universe
# deb-src http://security.ubuntu.com/ubuntu bionic-security universe
deb http://security.ubuntu.com/ubuntu bionic-security multiverse
# deb-src http://security.ubuntu.com/ubuntu bionic-security multiverse" > /etc/apt/sources.list


# basic stuff
sudo apt-get update && apt-get -y dist-upgrade
sudo apt-get -y install \
slick-greeter \
ubuntu-drivers-common \
xorg \
xserver-xorg \
nautilus \
mesa-utils \
mesa-utils-extra \
gnome-terminal \
wget \
unzip \
wpasupplicant \
ranger \
compton \
nitrogen \
rofi \
neofetch \
terminator \
tig

echo "neofetch" >> /home/${USERNAME}/.profile



# nvidia gpu driver
echo -ne '\n' | sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
sudo ubuntu-drivers autoinstall
# docker
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install docker-ce
sudo usermod $USERNAME -aG docker
# ssh if not enabled enable it.
sudo systemctl enable ssh

# vscode
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get -y install apt-transport-https
sudo apt-get update
sudo apt-get -y install code
# chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt-get update
sudo apt-get -y install google-chrome-stable
# i3-gaps
sudo apt install -y \
libxcb1-dev \
libxcb-keysyms1-dev \
libpango1.0-dev \
libxcb-util0-dev \
libxcb-icccm4-dev \
libyajl-dev \
libstartup-notification0-dev \
libxcb-randr0-dev \
libev-dev \
libxcb-cursor-dev \
libxcb-xinerama0-dev \
libxcb-xkb-dev \
libxkbcommon-dev \
libxkbcommon-x11-dev \
autoconf \
libxcb-xrm0 \
libxcb-xrm-dev \
automake 

cd /tmp

# clone the repository
git clone https://www.github.com/Airblader/i3 i3-gaps
cd i3-gaps

# compile & install
autoreconf --force --install
rm -rf build/
mkdir -p build && cd build/

# Disabling sanitizers is important for release versions!
# The prefix and sysconfdir are, obviously, dependent on the distribution.
../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
make
sudo make install
rm -r /tmp/i3-gaps
# i3-blocks-gaps
cd /tmp
git clone https://github.com/Airblader/i3blocks-gaps i3blocks
cd i3blocks
make clean debug
make install
sudo rm -r /tmp/*

# polybar
sudo apt-get install \
cmake \
cmake-data \
libcairo2-dev \
libxcb1-dev \
libxcb-ewmh-dev \
libxcb-icccm4-dev \
libxcb-image0-dev \
libxcb-randr0-dev \
libxcb-util0-dev \
libxcb-xkb-dev \
pkg-config \
python-xcbgen \
xcb-proto \
libxcb-xrm-dev \
libasound2-dev \
libmpdclient-dev \
libiw-dev \
libcurl4-openssl-dev \
libpulse-dev 

cd /tmp
git clone https://github.com/jaagr/polybar.git
cd polybar && sudo ./build.sh
sudo rm -r /tmp/*

# gotop
cd /tmp
git clone --depth 1 https://github.com/cjbassi/gotop /tmp/gotop
cd /tmp/gotop/scripts/ && bash download.sh
sudo mv gotop /usr/local/bin/
sudo rm -r /tmp/*

cd $SCRIPTDIR

cp -r $(pwd)/i3 $HOME/.config/
cp -r $(pwd)/polybar $HOME/.config/
cp -r $(pwd)/terminator $HOME/.config/

# reboot
sudo reboot -h now
