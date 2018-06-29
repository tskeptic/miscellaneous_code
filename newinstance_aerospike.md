

# Aerospike

## Installation

Some of this initial page is based on the content at: http://www.aerospike.com/docs/operations/install/linux/ubuntu

I will cover a little about configuring an Aerospike node (or cluster) and start using right away.

I tested this on a fresh ubuntu 16.04 machine in the cloud.
All instructions were made using a ssh connection though terminal.
If you are going to make a cluster run this in all machines at the same time.

First download the installer:
```bash
wget -O aerospike.tgz 'http://aerospike.com/download/server/latest/artifact/ubuntu12'
```

Untar the package and delete the compressed file:
```bash
tar -xvf aerospike.tgz
rm aerospike.tgz
```

Enter the files directory and install the Aerospike service
```bash
cd aerospike-server-community-*-ubuntu12*
sudo ./asinstall # will install the .rpm packages
cd ..
```

Since it is installed in the system you no longer need the installation files anymore:
```bash
rm -rf aerospike-server-community-*-ubuntu12*
```

Now Aerospike is installed and ready to go!
EZPZ
But first let do some basic configuration

The Management Console (AMC) is very useful to monitor the cluster, so let's install it:
```bash
wget -O aerospike-amc*.deb http://www.aerospike.com/download/amc/3.6.6/artifact/ubuntu12
sudo dpkg -i aerospike-amc*
rm aerospike-amc*
```

## CONFIGURATION

This section is based in the content at http://www.aerospike.com/docs/operations/configure

I am using the mesh heartbeats system, Is it reliable but require maintaining the code as the nodes number grow.
For some clouds or environments the other method (multicast) can work and automatize the scaling.
We will edit the file /etc/aerospike/aerospike.conf
I only highlighted the parts where I edited.
If you are going to use in cluster, just insert one line for each node in the "mesh-seed-address-port" lines for each node, that's it
In the chunk bellow please edit the desired parts like IPs, namespace's name, RAM and disk sizes, etc.

```
network {
        ...
        heartbeat {
                mode mesh
                port 3002 # Heartbeat port for this node.
                # List one or more other nodes, one ip-address & port per line:
                # they should auto discover all from here, but I always put all of them
                mesh-seed-address-port <IP1> 3002
                mesh-seed-address-port <IP2> 3002
                # beware this values to match your timeout settings
                interval 150
                timeout 10
        }

namespace <NAME> {
        replication-factor 2  # number of copies of data - max is the number of nodes
        memory-size 2G  # ram reserved to aerospike service
        default-ttl 0 # 30 days, use 0 to never expire/evict.
#       storage-engine memory
        # To use file storage backing, comment out the line above and use the
        # following lines instead.
        storage-engine device {
                file /opt/aerospike/data/<NAME>.dat
                filesize 10G  # size in disk reserved to data
                data-in-memory false # Store data in memory in addition to file.
        }
}
```

## SECURITY

First I tried using iptables but I realized the security is complex because authentication is only available on the "paid" version.


[//]: # (TODO: find a plugin for security-authentication to protect the database with username+password)


## STARTING THE SERVICE

To start the service:
```bash
sudo service aerospike start
```

To start the management console
```bash
service amc start
```
