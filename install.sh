#!/bin/bash

# Gridseed single line installer aimed for Raspbian on Raspberry Pi 
# install.sh
# DavidMaitland.me & josh.farrant.me 2014

# This script will do the following:
# 1. Install the requirements for building dtbartle version of cgminer
# 2. Get a copy of cgminer
# 3. Configure, make and make install
# 4. Setup config.json for mining pool
# 5. Add on boot script for automatically running miner
# 6. Add script for ease of starting miner

installdir="miner"
# currentuser="pi"

home=$(echo ~)

logfile="$home/gspmi-install.log"

info='\n \e[46m - \e[49m'
ok='\n \e[42m + \e[49m'
error='\n \e[41m ! \e[49m'

# Make sure user is pi
# if [ $USER != $currentuser ]; then
#   echo -e "$error Not running as $currentuser! :("
#   exit 1
# fi

# Intro for user
echo -e "$info This script will download and compile the miner and configure the miner to start on boot."
echo -e "$info This may take a long time to run ~10-15 minutes. Do not quit or turn off your device while this is installing!\n"

read -p "Are you sure you want to install? (y/n) " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

# Install requirements
echo -e "$info Updating and installing packages"

sudo apt-get update -y >> $logfile 2>&1
sudo apt-get install git screen libcurl4-openssl-dev pkg-config libtool libudev-dev libncurses5-dev -y >> $logfile 2>&1

echo -e "$ok Packages updated and installed"

# Remove any old attempts
rm -rf ~/$installdir >> $logfile 2>&1

# Create directory for files
mkdir ~/$installdir && cd ~/$installdir

# Grab file
echo -e "$info Downloading configure files and scripts"

curl -o config.json -l https://raw.githubusercontent.com/davidmaitland/Gridseed-PiMiner/master/config.json >> $logfile 2>&1

echo -e "$ok Files downloaded"

# Clone repo
echo -e "$info Cloning dtbartle's version of cgminer"

git clone https://github.com/dtbartle/cgminer-gc3355.git >> $logfile 2>&1

echo -e "$ok Cloned repo"

cd ./cgminer-gc3355

echo -e "$info Configuring cgminer. This may take a while. Time for a beer?"

./configure --enable-scrypt --enable-gridseed >> $logfile 2>&1

echo -e "$ok Configured cgminer"

echo -e "$info Compiling cgminer. This will take even longer."

make >> $logfile 2>&1

echo -e "$ok Complied cgminer! Put that beer down!"

echo -e "$info Installing cgminer"

sudo make install >> $logfile 2>&1

echo -e "$ok Installed cgminer"

echo "$info making cgminer run on boot"

sudo mv miner-boot.sh /etc/init.d/

sudo chmod 755 /etc/init.d/miner-boot.sh

sudo update-rc.d miner-boot.sh defaults

echo "$ok cgminer will now run on boot!"