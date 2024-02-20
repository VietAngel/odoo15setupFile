#!/bin/bash

# USMH system:
# nodejs v10.19.0
# npm@6.14.4 /usr/share/npm
# Odoo 15.0 & enterprise lastest
# Postgresql 15.0
# Ubuntu os 20.04
#Distributor ID:	Ubuntu
#Description:	Ubuntu 20.04.6 LTS
#Release:	20.04
#Codename:	focal
# PYTHON 3.8.10
PYTHON_ENV="/usr/bin/python3"

ODOO_ROOT_DIR=/opt/odoo
ODOO_CORE_DIR=/opt/odoo/core/odoo15
ODOO_CORE_EE_DIR=/opt/odoo/core/enterprise
# create project folders
# this variable will be a folder name
DESTINATION=$1
ODOO_PORT=$2
CHAT_PORT=$3

# data base information
SERVICE_NAME=odoo-$DESTINATION
# Create database user odoo
DB_HOST=$4
DB_PORT=$5
DB_USER=$6
# FOR Odoo
PGPASSWORD=$7
ADMIN_PASSWORD=$8

INSTANCE_DIR=$ODOO_ROOT_DIR/$DESTINATION
ADDON_DIR=$INSTANCE_DIR/source/custom/addons
DATA_DIR=$INSTANCE_DIR/.local
mkdir -p $ODOO_ROOT_DIR
mkdir -p $ODOO_CORE_DIR
mkdir -p $ODOO_CORE_EE_DIR/addons
mkdir -p $INSTANCE_DIR
mkdir -p $DATA_DIR
mkdir -p $ADDON_DIR
mkdir -p $INSTANCE_DIR/config
mkdir -p $INSTANCE_DIR/logs


sudo useradd -m -d $ODOO_ROOT_DIR -U -r -s /bin/bash odoo

# Install postgresql if needed
sudo apt upgrade -y
# Add postgresql repository and key
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

#sudo chmod +x postgresql_install.sh
#bash ./postgresql_install.sh

#sudo su - postgres -c "psql -c \"CREATE DATABASE '$DB_NAME' WITH OWNER odoo;\""
#sudo su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO odoo;\""


# install dependencies
sudo apt-get install git python3 python3-pip build-essential wget python3-dev python3-venv python3-wheel \
libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev gdebi -y

#sudo apt install python3-pip python3-dev python3-venv python3-wheel python3-apt python3-debian python3-six \
#  libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev \
#  libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev libfreetype6-dev \
#  liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev libpq-dev -y

sudo apt-get install libpq-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libffi-dev -y

# those libraries support for pycairo when install lxml
sudo apt-get install sox ffmpeg libcairo2 libcairo2-dev -y

# text font to fix some wrong docufont
# sudo apt-get install texlive-full -y for full font if needed
sudo apt-get install texlive-lang-japanese -y

# sudo apt-get install --upgrade libssl-dev

# install nodejs & npm
sudo apt-get install nodejs npm -y
sudo npm install -g rtlcss

# install wkhtmltopdf
sudo chmod +x ./whhtmltopdf_install.sh
bash ./whhtmltopdf_install.sh

# Copy python libraries
#mv /usr/local/lib/python3.8/dist-packages /usr/local/lib/python3.8/dist-packages.bak/
#tar -xf dist-packages-with-out-pyc.tar.gz -C /usr/local/lib/python3.8/

# clone Odoo 15
sudo apt-get install git -y
sudo git clone --depth 1 --branch 15.0 https://www.github.com/odoo/odoo "$ODOO_CORE_DIR/."
pip3 install wheel
pip3 install -r $ODOO_CORE_DIR/requirements.txt

#Setting permissions on home folder
sudo chown -R odoo:odoo $ODOO_ROOT_DIR

#Create server config file
# clone your custom source
CUSTOM_ADDONS="" # change  this value to your source code example $ADDON_DIR/usmh_mhr
ADDON_PATH="$ODOO_CORE_DIR/addons,$ODOO_CORE_DIR/odoo/addons,$ODOO_CORE_EE_DIR/addons,$CUSTOM_ADDONS"

CONFIG_FILE_PATH=$INSTANCE_DIR/config/odoo-$DESTINATION.conf
LOG_FILE_PATH=$INSTANCE_DIR/logs/odoo-$DESTINATION
SERVICE_FILE_PATH=/etc/systemd/system/odoo-$DESTINATION.service
SERVICE_NAME=odoo-$DESTINATION

#  create odoo server config file
cp odoo-server.conf $CONFIG_FILE_PATH
# update odoo config file

sed -i "s/^addons_path = .*/addons_path = $(echo "$ADDON_PATH" | sed 's/\//\\\//g')/" "$CONFIG_FILE_PATH"
sed -i "s/^data_dir = .*/data_dir = $(echo "$DATA_DIR" | sed 's/\//\\\//g')/" "$CONFIG_FILE_PATH"

sed -i "s/^admin_passwd = .*/admin_passwd = $ADMIN_PASSWORD/" $CONFIG_FILE_PATH
sed -i "s/^db_host = .*/db_host = $DB_HOST/" $CONFIG_FILE_PATH
sed -i "s/^db_port = .*/db_port = $DB_PORT/" $CONFIG_FILE_PATH
sed -i "s/^db_user = .*/db_user = $DB_USER/" $CONFIG_FILE_PATH
sed -i "s/^db_password = .*/db_password = $PGPASSWORD/" $CONFIG_FILE_PATH
sed -i "s/^http_port = .*/http_port = $ODOO_PORT/" $CONFIG_FILE_PATH
sed -i "s/^longpolling_port = .*/longpolling_port = $CHAT_PORT/" $CONFIG_FILE_PATH


# Odoo service  /etc/systemd/system/odoo-server.service
# create odoo service file
cp odoo-server.service $SERVICE_FILE_PATH
ExecStart="$PYTHON_ENV $ODOO_CORE_DIR/odoo-bin -c $CONFIG_FILE_PATH --logfile=$LOG_FILE_PATH-%H.log --xmlrpc-port=$ODOO_PORT --longpolling-port=$CHAT_PORT"
sed -i "s/^ExecStart=.*/ExecStart = $(echo "$ExecStart" | sed 's/\//\\\//g')/" "$SERVICE_FILE_PATH"

sudo chown -R odoo:odoo $INSTANCE_DIR

sudo systemctl daemon-reload
sudo systemctl enable --now $SERVICE_NAME
sudo systemctl start --now $SERVICE_NAME

#pip install PyPDF2==1.26.0 passlib==1.7.1 Babel==2.6.0
#python3 -m pip install --upgrade pip
#python3 -m pip install -r requirements.txt
#python3 -m pip install holidays


## install nginx core
sudo apt-get install nginx-core -y
# config nginx for mbo
DOMAIN=${*: -1} || "localhost"
NGINX_FILE=/etc/nginx/sites-available/$SERVICE_NAME.conf
sudo cp odoo-nginx.conf $NGINX_FILE
sed -i 's/8069/'$ODOO_PORT'/g' $NGINX_FILE
sed -i 's/8072/'$CHAT_PORT'/g' $NGINX_FILE
sed -i 's/localhost/'$DOMAIN'/g' $NGINX_FILE
sed -i 's/backend/'$DESTINATION'/g' $NGINX_FILE
sudo ln -s $NGINX_FILE /etc/nginx/sites-enabled/

sudo nginx -t
sudo nginx -s reload
echo 'Finished install '$SERVICE_NAME
echo 'Started Odoo @ http://'$DOMAIN' | Odoo port: '$ODOO_PORT' | Live chat port: '$CHAT_PORT

