#!/bin/bash
set -e

## adding repositories
sudo add-apt-repository ppa:webupd8team/java
# cassandra debian repos
echo "deb http://www.apache.org/dist/cassandra/debian 310x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
# keys
curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add -
# gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
# gpg --export --armor F758CE318D77295D | sudo apt-key add -
# gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00
# gpg --export --armor 2B5C1B00 | sudo apt-key add -
# gpg --keyserver pgp.mit.edu --recv-keys 0353B12C
# gpg --export --armor 0353B12C | sudo apt-key add -

## updating
sudo apt-get update -y
sudo apt-get upgrade -y

## installing packages
sudo apt-get install oracle-java8-set-default htop libssl-dev ntp -y

#####
# PREPARING THE MACHINE
# http://docs.datastax.com/en/landing_page/doc/landing_page/recommendedSettingsLinux.html

## set JAVA_HOME
echo -e '
JAVA_HOME="/usr/lib/jvm/java-8-oracle"
CQLSH_NO_BUNDLED=true' >> /etc/environment

## install Java Native Access (JNA) - apparentemente o cassandra ja instala junto
# Sync clocks on nodes (using NTP ?)
# sudo apt install ntp  - added previously
service ntp restart

## TCP setting
# vim /etc/sysctl.conf
# net.core.rmem_max = 16777216
# net.core.wmem_max = 16777216
# net.core.rmem_default = 16777216
# net.core.wmem_default = 16777216
# net.core.optmem_max = 40960
# net.ipv4.tcp_rmem = 4096 87380 16777216
# net.ipv4.tcp_wmem = 4096 65536 16777216
sudo sysctl -p /etc/sysctl.conf

## Disable swap (sudo swapoff -all)
swapoff -a
# add above line to /etc/rc.local
vim /etc/fstab
# comment lines with swap in columns 2 or 3

## PORTS
# public
22 - SSH
8888 - opscenter (cassandra dashboard in browser)
# inter-nodes
7000 - inter-node cluster comunic
7001 - SSL inter-node cluster comunic
7199 - jmx monitoring port
#client
9042 - client
9160 - client Thrift
#####

sudo apt-get install cassandra -y

# stop service
sudo service cassandra stop
# remove the default dataset
sudo rm -rf /var/lib/cassandra/data/system/*

# vim /etc/cassandra/cassandra.yaml
cluster_name: 'cassandra-cluster-test'
# -seeds: "127.0.0.1"  # internal access
-seeds: "<IP1>,<IP2>"  # config to connect various nodes
# listen_address: "localhost"  # internal access
listen_address: "<machine-external-IP>"  # external access
# rpc_address: "127.0.0.1"  # internal access
rpc_address: <machine-external-IP>  # external access
endpoint_snitch: SimpleSnitch
auto_bootstrap: false
authenticator: PasswordAuthenticator
authorizer: CassandraAuthorizer

sudo service cassandra start

# installing pip
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
rm get-pip.py
# installing driver to use cqlsh
sudo pip install cassandra-driver

# authentication - global
# http://cassandra.apache.org/doc/latest/operating/security.html
# log in - password: cassandra
cqlsh <machine-external-IP> -u cassandra
# increase replication beacuse passwords
ALTER KEYSPACE system_auth WITH replication = {'class': 'NetworkTopologyStrategy', 'datacenter1': 2};  # DA UMA TRETA DO CARALHO
# ALTER KEYSPACE system_auth WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 2};
# create a new superuser
CREATE ROLE cassandra_dba WITH SUPERUSER = true AND LOGIN = true AND PASSWORD = '<SOME PASSWORD>';
exit
cqlsh <machine-external-IP> -u cassandra_dba
# remove access to default dba user
ALTER ROLE cassandra WITH SUPERUSER = false AND LOGIN = false;

CREATE ROLE tsk_tests2 WITH PASSWORD = 'tsk_teste2' AND LOGIN = true;
