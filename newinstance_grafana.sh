
# sudo vim /etc/apt/sources.list
deb https://packagecloud.io/grafana/stable/debian/ jessie main

curl https://packagecloud.io/gpg.key | sudo apt-key add -

sudo apt-get update -y
sudo apt-get install -y apt-transport-https
sudo apt-get install grafana -y
