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

mkdir -p $INSTANCE_DIR
mkdir -p $DATA_DIR
mkdir -p $ADDON_DIR
mkdir -p $INSTANCE_DIR/config
mkdir -p $INSTANCE_DIR/logs


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

#sudo bash odoo_create_service.sh "mbo15" 9999 10000 "localhost" 5432 "odoo" "odoo" "usmh@odoo15hr2023" "localhost"
