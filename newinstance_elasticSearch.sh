#!/bin/bash
# SEMI-AUTOMATED SCRIPT
# some parts could run entirely
# some parts must be edited (ex <IP>)
# some parts must be run in separated (ex vim edit ...)
# tested on ubuntu 16.04

###############################################################################
# INSTALLING ELASTICSEARCH
## adding repositories
sudo add-apt-repository ppa:webupd8team/java -y  # TODO autoaccept this 
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
# echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list

## updating
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt autoremove -y

# for version 2:
# https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.4.4/elasticsearch-2.4.4.deb
# dpkg -i elasticsearch*

## installing packages
# TODO: autoaccept java
sudo apt-get install apt-transport-https oracle-java8-installer libssl-dev elasticsearch -y

# run to see if your system uses SysV or systemd
ps -p 1
# this script is made for systemd

mkdir /mnt/hdd2/elasticsearch
sudo chmod a+w /mnt/hdd2/elasticsearch
# vai dar erro nessa porra nao sei pq

# vim /etc/elasticsearch/elasticsearch.yml
cluster.name: <NOME>
node.name: ${HOSTNAME}
path.data: /mnt/hdd2/elasticsearch
bootstrap.memory_lock: true
network.host: 0.0.0.0
discovery.zen.ping.unicast.hosts: [<IP2>,<IP3>]
discovery.zen.minimum_master_nodes: (total number of master-eligible nodes / 2 + 1)
script.inline: true
script.stored: true
script.file: true
script.indexed: true
http.cors.enabled: true
http.cors.allow-origin: "*"
http.cors.allow-headers: "X-Requested-With, Content-Type, Content-Length, Authorization"
http.cors.allow-credentials: true

## vim /etc/security/limits.conf
elasticsearch soft memlock unlimited
elasticsearch hard memlock unlimited

mkdir /etc/systemd/system/elasticsearch.service.d
## vim /etc/systemd/system/elasticsearch.service.d/elasticsearch.conf
[Service]
LimitMEMLOCK=infinity

# vim /etc/default/elasticsearch
ES_JAVA_OPTS="-Xms8g -Xmx8g"

# /etc/rc.local
sudo iptables -I INPUT 1 -i lo -j ACCEPT  # loopback
sudo ip6tables -I INPUT 1 -i lo -j ACCEPT  # loopback
sudo iptables -I INPUT 2 -p tcp --dport 9200 -j DROP
sudo ip6tables -I INPUT 3 -p tcp --dport 9200 -j DROP

## CONFIGURINT ES TO START AT STARTUP
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
