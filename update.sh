#!/bin/sh
sudo apt-get update
echo "Install any found updates"
sudo apt-get full-upgrade -y
echo "Check for new Snap packages"
sudo snap refresh
echo "Clean up old apt packages"
sudo apt-get clean
echo "Autoremove any old apt packages"
sudo apt-get autoremove -y
echo "Clean up any old snaps"
sudo apt show -a $(apt list --upgradable 2>&1 | grep / | cut -d/ -f1) 2>&1 | grep Phased | sort -n | uniq -c
#Removes old revisions of snaps
#CLOSE ALL SNAPS BEFORE RUNNING THIS
set -eu
LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done
echo "Pending development"
sudo apt show -a $(apt list --upgradable 2>&1 | grep / | cut -d/ -f1) 2>&1 | grep Phased | sort -n | uniq -c