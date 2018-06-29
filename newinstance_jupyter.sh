#!/bin/bash

# installing apps and requisites
    # build-essential -> used when building debian packages - dpkg make etc
    # htop -> upgraded interactive top
    # libfreetype6-dev -> freetype font engine - matplotlib req
    # libsqlite3-dev -> sqlite dev files - nltk req
    # libssl-dev -> ssl libraries - python3.5 req
    # zlib1g-dev -> compression library - python + virtualenv req
    # libxft-dev -> freetype font drawing library - matplotlib req
    # supervisor -> starts and manage processes
sudo apt-get install git build-essential htop libfreetype6-dev libssl-dev zlib1g-dev libsqlite3-dev libxft-dev supervisor -y

# python 3 installation
wget https://www.python.org/ftp/python/3.5.2/Python-3.5.2.tar.xz
tar -xf Python-3*.tar.xz
rm Python-3*.tar.xz
cd Python-3*/
sudo ./configure
sudo make
sudo make altinstall
cd ..
sudo rm -rf Python-3*/

#installing pip
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
rm get-pip.py
# installing virtualenv
sudo pip install virtualenvwrapper
echo -e "
export WORKON_HOME=\$HOME/.virtualenvs
export PROJECT_HOME=\$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
source ~/.bashrc # EXECUTAR ESTE NA LINHA DE COMANDO

## PREPARING VIRTUALENV
source `which virtualenvwrapper.sh`
sudo chown ubuntu /home/ubuntu/.virtualenvs/
mkvirtualenv -p python3.5 jupyter || 0
workon jupyter
    # amqpy -> handling queues like rabbitMQ
    # beautifulsoup4 -> html scraping
    # boto3 -> aws interface
    # elasticsearch -> elasticsearch connections
    # jupyter -> notebook handling
    # matplotlib -> plotting library
    # nltk -> natural language processing
    # numpy -> numeric handling library
    # pandas -> datasets manipulation
    # pymongo -> mongoDB handling
    # pymssql -> MS SQL Server handling
    # requests -> rest requests
    # scikit-learn -> machine learning
    # scipy -> scientific python
    # urllib3 -> handles html connections
pip install amqpy beautifulsoup4 boto3 elasticsearch jupyter matplotlib nltk numpy pandas pymongo pymssql requests scikit-learn scipy urllib3
python -m nltk.downloader stopwords # nltk package stopwords
python -m nltk.downloader rslp # nltk package stemmer
jupyter notebook --generate-config
deactivate
sudo cp -r ./nltk_data/ /usr/local/share/nltk_data/  # making nltk data public

# VER CERTINHO
mkdir jupyter-server
# EDITAR /home/ubuntu/.jupyter/jupyter_notebook_config.py
c.NotebookApp.allow_origin = '*'
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
# password is aranha
c.NotebookApp.password = u'sha1:77efb8b71283:12242858e0cff2bc17cc4915e079d4b483c2b537'

# CONFIGURING SUPERVISOR
sudo echo -e "
[inet_http_server]
port = *:9001
username = <SOME USERNAME>
password = <PASSWORD>

[program:jupyterNotebook]
command=/root/.venvs/jupyter/bin/jupyter notebook --config=/root/.jupyter/jupyter_notebook_config.py
autostart=true
autorestart=unexpected
startsecs=1
startretries=5
directory=/home/ubuntu/jupyter-server/
redirect_stderr=true
stdout_logfile=/home/ubuntu/jupyter-server/log-jupyter.log" >> /etc/supervisor/supervisord.conf

sudo service supervisor restart

sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT  # this connection
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT  # ssh
sudo iptables -A INPUT -p tcp --dport 8888 -j ACCEPT  # jupyter notebook
sudo iptables -A INPUT -p tcp --dport 9001 -j ACCEPT  # supervisor monitor
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT  # monitorix
sudo iptables -I INPUT 1 -i lo -j ACCEPT  # loopback
sudo iptables -A INPUT -j DROP  # drop all
sudo ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT  # this connection
sudo ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT  # ssh
sudo ip6tables -A INPUT -p tcp --dport 8888 -j ACCEPT  # jupyter notebook
sudo iptables -A INPUT -p tcp --dport 9001 -j ACCEPT  # supervisor monitor
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT  # monitorix
sudo ip6tables -I INPUT 1 -i lo -j ACCEPT  # loopback
sudo ip6tables -A INPUT -j DROP  # drop all

sudo invoke-rc.d iptables-persistent save
