#!/bin/bash
# SEMI-AUTOMATED SCRIPT
# some parts could run entirely
# some parts must be edited (ex <IP>)
# some parts must be run in separated (ex vim edit ...)

# IF YOU ARE GOING TO USE SINGLE NODE SKIP SOME PARAGRAPHS

# SKIP TO 19 IF SINLE NODE
# changing your hostname
echo 'nodename_X' > /etc/hostname
# vim /etc/hosts
# 127.0.0.1       localhost
# 127.0.1.1       <nodename_X>
# <EXTERNAL-IP>   <nodename_X>
# <NODE2-IP>   <nodename_X+1>
# <NODE3-IP>   <nodename_X+2>

127.0.0.1       localhost
127.0.1.1       hkn-rabbitmq4
130.211.205.32  hkn-rabbitmq4

174.37.71.110   hkn-rabbitmq1
158.85.54.11    hkn-rabbitmq2
50.97.205.83    hkn-rabbitmq3

104.198.142.180 hkn-rabbitmq5
130.211.205.32  hkn-rabbitmq4
35.184.151.60   hkn-rabbitmq6

# put hostnames changes to run
sudo shutdown -r now

###############################################################################
# INSTALLING RABBITMQ
# https://www.rabbitmq.com/install-debian.html
# we are going to install a specifig version of rabbit to avoid problems

# installing rabbitmq
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_6/rabbitmq-server_3.6.6-1_all.deb
sudo dpkg -i rabbitmq*  # you are going to get an error (requirements error)
sudo apt-get -f install -y  # this solte the error above TODO: install specific requisites first
# installing the http management service
sudo rabbitmq-plugins enable rabbitmq_management

# SKIP TO 47 IF SINLE NODE
sudo service rabbitmq-server stop
# configuring node service name
echo 'NODENAME=rabbit' > /etc/rabbitmq/rabbitmq-env.conf
# configuring erlang cookie
echo 'RANDOMCOOKIEGENERATE' > /var/lib/rabbitmq/.erlang.cookie  # every machine must be the same, you can use one of the machine's value
sudo chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie
sudo chmod 600 /var/lib/rabbitmq/.erlang.cookie
# restarting the rabbitmq service to get the new configs
sudo service rabbitmq-server start
# run this only in n-1 machines - to connect to one to form a cluster
sudo rabbitmqctl stop_app
sudo rabbitmqctl join_cluster rabbit@<nodename_X>
sudo rabbitmqctl start_app

###############################################################################
# CONFIGURATION
# here we configure some access control
# we are going to create one admin user, one monitoring user and a general user
# you can create various vhosts for different uses

# adding users
rabbitmqctl delete_user guest  # deleting default user
rabbitmqctl add_user <user> <password>  # adding user for working
rabbitmqctl add_user <admin_user> <password>  # adding admin user
rabbitmqctl add_user <monitoring_user> <password>  # adding user for monitoring purposes
# setting users tags
rabbitmqctl set_user_tags <admin_user> administrator  # give administrator tag for user
rabbitmqctl set_user_tags <monitoring_user> monitoring  # give monitoring tag for user
# adding hosts
rabbitmqctl add_vhost /<vhostname>  # add vhosts for different uses
# setting permissions
# {conf} {write} {read}
rabbitmqctl set_permissions -p /<vhostname> <user-admin> ".*" ".*" ".*"
rabbitmqctl set_permissions -p /<vhostname> <monitoring_user> "" "" ".*"
rabbitmqctl set_permissions -p /<vhostname> <user> "" ".*" ".*"

###############################################################################
# SOME SECURITY

#ip4
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT  # this connection
iptables -A INPUT -p tcp --dport 22 -j ACCEPT  # ssh
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT  # monitorix
iptables -A INPUT -p tcp --dport 4369 -j ACCEPT  # rabbitmq epmd
iptables -A INPUT -p tcp --dport 25672 -j ACCEPT  #  rabbitmq Erlang 
iptables -A INPUT -p tcp --dport 5672 -j ACCEPT  #  rabbitmq
iptables -A INPUT -p tcp --dport 5671 -j ACCEPT  #  rabbitmq
iptables -A INPUT -p tcp --dport 15672 -j ACCEPT  # rabbitmq_management_plugin
iptables -I INPUT 1 -i lo -j ACCEPT  # loopback
iptables -A INPUT -j DROP  # drop all
# ipv6
ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT  # this connection
ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT  # ssh
ip6tables -A INPUT -p tcp --dport 8080 -j ACCEPT  # monitorix
ip6tables -A INPUT -p tcp --dport 4369 -j ACCEPT  # rabbitmq epmd
ip6tables -A INPUT -p tcp --dport 25672 -j ACCEPT  #  rabbitmq Erlang 
ip6tables -A INPUT -p tcp --dport 5672 -j ACCEPT  #  rabbitmq
ip6tables -A INPUT -p tcp --dport 5671 -j ACCEPT  #  rabbitmq
ip6tables -A INPUT -p tcp --dport 15672 -j ACCEPT  # rabbitmq_management_plugin
ip6tables -I INPUT 1 -i lo -j ACCEPT  # loopback
ip6tables -A INPUT -j DROP  # drop all

# TODO: add persistent iptables rules
# iptables-persistent seems to not work on ubuntu16
