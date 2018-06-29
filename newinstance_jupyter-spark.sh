#!/bin/bash
set -e

# adding timestamp to bash history
echo -e '
export HISTTIMEFORMAT="%Y-%m-%dT%T " ' >> ~/.bashrc
source ~/.bashrc

## adding repositories
sudo add-apt-repository ppa:webupd8team/java -y  # java 8 repo
sudo add-apt-repository "deb http://cran.cnr.berkeley.edu/bin/linux/ubuntu xenial/" -y  # R repo
sudo apt-add-repository ppa:git-core/ppa -y  # git
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -  # microsoft sql server
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list > /dev/null  # microsoft sql server
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9  # R key

## updating
sudo apt-get update -y
sudo apt-get upgrade -y

## oracle-java auto accept
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

## installing packages
sudo ACCEPT_EULA=Y apt-get install git htop build-essential oracle-java8-installer libssl-dev zlib1g-dev libsqlite3-dev r-base libfreetype6-dev libxft-dev unixodbc-dev supervisor lzop msodbcsql mssql-tools unixodbc -y

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
export WORKON_HOME=~/.venvs
source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
source ~/.bashrc

## PREPARING VIRTUALENV
source `which virtualenvwrapper.sh`
sudo chown ubuntu /home/ubuntu/.venvs/
mkvirtualenv -p python3.5 jupyter || 0
workon jupyter
pip install amqpy arrow beautifulsoup4 boto3 elasticsearch nltk pandas pymongo requests scikit-learn scipy Unidecode urllib3 user-agents jupyter matplotlib numpy pymssql sqlalchemy pyodbc
python -m nltk.downloader stopwords # nltk package stopwords
python -m nltk.downloader rslp # nltk package stemmer
jupyter notebook --generate-config
deactivate
sudo cp -r ./nltk_data/ /usr/local/share/nltk_data/  # making nltk data public
mkdir jupyter-server

# Spark installation
wget http://d3kbcqa49mib13.cloudfront.net/spark-2.1.1-bin-hadoop2.7.tgz  # get last stable version
tar -zxvf spark-2*
rm spark*tgz
# moving spark dir
sudo cp -r spark-2*/. /spark
sudo chmod a+rw -R /spark
rm -rf spark-2*/
# elasticsearch connector installation
wget http://download.elastic.co/hadoop/elasticsearch-hadoop-5.1.2.zip
unzip elasticsearch-hadoop*
rm elasticsearch*zip
# jars usados
cp elasticsearch-hadoop-5.1.2/dist/elasticsearch-yarn-5.1.2.jar /spark/jars/
cp elasticsearch-hadoop-5.1.2/dist/elasticsearch-spark-20_2.11-5.1.2.jar /spark/jars/
rm -rf elasticsearch-hadoop*

/spark/sbin/start-master.sh -h <IP>
/spark/sbin/start-slave.sh spark://<IP>:7077  # trocar id do master

/spark/sbin/start-slave.sh spark://<MASTERS ID>:7077

# OPEN JUPYTER
# environment variables
export PYSPARK_PYTHON=/home/ubuntu/.venvs/jupyter/bin/python
export PYSPARK_DRIVER_PYTHON=/home/ubuntu/.venvs/jupyter/bin/jupyter
export PYSPARK_DRIVER_PYTHON_OPTS="notebook --NotebookApp.open_browser=False --NotebookApp.ip='*' --NotebookApp.port=8889"
/spark/bin/pyspark --master spark://<MASTERS ID>:7077 --conf "spark.executor.memory=4g" --conf "spark.driver.memory=4g"

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
username = <USERNAME>
password = <PASSWORD>

[program:jupyterNotebook]
command=/home/ubuntu/.venvs/jupyter/bin/jupyter notebook --config=/home/ubuntu/.jupyter/jupyter_notebook_config.py --allow-root
autostart=true
autorestart=unexpected
startsecs=1
startretries=5
directory=/home/ubuntu/jupyter-server/
redirect_stderr=true
stdout_logfile=/home/ubuntu/jupyter-server/log-jupyter.log" >> /etc/supervisor/supervisord.conf

sudo service supervisor restart


# wget http://central.maven.org/maven2/com/amazonaws/aws-java-sdk-core/1.11.158/aws-java-sdk-core-1.11.158.jar
wget http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.10.6/aws-java-sdk-1.10.6.jar
wget http://central.maven.org/maven2/com/amazonaws/aws-java-sdk-core/1.10.6/aws-java-sdk-core-1.10.6.jar

wget https://sdk-for-java.amazonwebservices.com/latest/aws-java-sdk.zip
rm aws-java-sdk.zip
cd aws-java-sdk*
rm lib/*javadoc.jar
rm lib/*sources.jar
cp lib/aws-java-sdk* /spark/jars/
cd ..
rm -rf aws-java-sdk*


wget http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar
cp hadoop-aws* /spark/jars/
rm hadoop-aws*


http://central.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/1.10.6/aws-java-sdk-s3-1.10.6.jar


# OPEN JUPYTER
# environment variables
export PYSPARK_DRIVER_PYTHON=/root/.venvs/jupspark/bin/jupyter
export PYSPARK_DRIVER_PYTHON_OPTS="notebook --NotebookApp.open_browser=False --NotebookApp.ip='*' --NotebookApp.port=8888"
/spark/bin/pyspark --master spark://<IP>:7077 --conf "spark.executor.memory=5g" --conf "spark.driver.memory=5g"

# IF YOU NEED TO SAVE INTO A FILE
## jupyter configs
c.NotebookApp.allow_origin = '*'
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.password = u'sha1:a2355d21fc8a:a20bea2fb9ee37f198967792596d162d3d80f065'  # lanterna

# SUBMIT PYTHON SCRIPT
/spark/bin/spark-submit --master spark://169.54.174.205:7077 --conf "spark.executor.memory=30g" --conf "spark.driver.memory=30g" teste1.py >> log.log 2>&1 &

export PYSPARK_DRIVER_PYTHON=/root/.venvs/jupyter/bin/jupyter
export PYSPARK_DRIVER_PYTHON_OPTS="notebook --config=/root/.jupyter/jupyter_notebook_config-spark.py"

export PYSPARK_PYTHON=/home/tsk/.virtualenvs/jupyter/bin/python
export PYSPARK_DRIVER_PYTHON=/home/tsk/.virtualenvs/jupyter/bin/jupyter
export PYSPARK_DRIVER_PYTHON_OPTS="notebook --NotebookApp.open_browser=False --NotebookApp.ip='*' --NotebookApp.port=8889"

/spark/sbin/start-master.sh
/spark/sbin/start-slave.sh spark://<ID>:7077

/spark/bin/pyspark --master spark://<ID>:7077 --conf "spark.executor.memory=2g" --conf "spark.driver.memory=2g"
