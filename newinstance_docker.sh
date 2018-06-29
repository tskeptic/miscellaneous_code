#!/bin/bash
set -e # stop on errors
# setting language and time-zone
sudo echo "
LANGUAGE=en_US
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8" >> /etc/environment
sudo timedatectl set-timezone UTC
# initial update
sudo apt-get update -y
# auto answer iptables installation questions
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
# installing apps and requisites
    # apt-transport-https -> https method apt - docker req
    # build-essential -> used when building debian packages - dpkg make etc
    # ca-certificates -> docker req
    # htop -> upgraded interactive top
    # iptables-persistent -> save iptables configs to be reboot persistence
    # linux-image-extra-$(uname -r) -> aufs storage driver - docker req
sudo apt-get install git build-essential htop iptables-persistent apt-transport-https ca-certificates linux-image-extra-$(uname -r) -y
# adding docker GPG key
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
# cleaning docker source
sudo rm -f /etc/apt/sources.list.d/docker.list
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee -a /etc/apt/sources.list.d/docker.list  # FOR 14.04 ONLY
# updating again
sudo apt-get update -y
# purging old dockers
sudo apt-get purge lxc-docker -y
# installing docker
sudo apt-get install docker-engine -y
# docker will start with OS if ubuntu version <= 14.10, otherwise
# sudo systemctl enable docker

# configuring firewall ???
# sudo invoke-rc.d iptables-persistent save
