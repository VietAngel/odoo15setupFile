#!/bin/bash

DB_HOST=$1
DB_PORT=$2
DB_NAME=$3
DB_USER=$4
PG_USER=$5
PG_PASSWORD=$6
DB_FILENAME=$7
FILESTORE_NAME=$8
INSTANCE_DIR=$9

SERVICE_NAME=${*: -1} || 'odoo15'

LOG_DATE=$(date +"%Y_%m_%d_%H_%M_%S")
LOG_FILE="restore_$LOG_DATE.log"

echo "Start restore DB: $(date +'%Y-%m-%d %H:%M:%S')" >> $LOG_FILE
# create database
PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -h $DB_HOST -p $DB_PORT -d postgres -c "DROP DATABASE $DB_NAME;"
PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -h $DB_HOST -p $DB_PORT -d postgres -c "CREATE DATABASE $DB_NAME WITH OWNER $DB_USER;"
PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -h $DB_HOST -p $DB_PORT  -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
#
## restore db
PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -1 -f $DB_FILENAME

echo "Finished restore DB $(date +'%Y-%m-%d %H:%M:%S')" >> $LOG_FILE

chmod +x masking_sensitive_data.sh
bash ./masking_sensitive_data.sh $DB_HOST $DB_PORT $DB_NAME $PG_USER $PGPASSWORD


echo "Finished masking_sensitive_data $(date +'%Y-%m-%d %H:%M:%S')" >> $LOG_FILE
## restore filestore
echo "Start restore filestore $(date +'%Y-%m-%d %H:%M:%S')" >> $LOG_FILE
DATA_DIR=$INSTANCE_DIR/.local
# copy file store folder
# create folder for Data dir (file store)
mkdir -p $DATA_DIR/share/Odoo/filestore/$DB_NAME
tar -xf $FILESTORE_NAME --strip-components=1 -C $DATA_DIR/share/Odoo/filestore/$DB_NAME
sudo chown -R odoo:odoo $INSTANCE_DIR

sudo systemctl restart $SERVICE_NAME

echo "Finished restart service $(date +'%Y-%m-%d %H:%M:%S')" >> $LOG_FILE


#sudo bash restore_database.sh "localhost" 5432  "maruetsu_hq" "maruetsu_hq" "postgres" "postgres" "/home/ubuntu/mbo15_prd_bak/mbo_production_20230808_110120.sql" "mbo_production_20230808_110120.zip" "/opt/odoo/mbo15" "odoo-mbo15.service"