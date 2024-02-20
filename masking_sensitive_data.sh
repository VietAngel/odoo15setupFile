#!/bin/bash
DB_HOST=$1
DB_PORT=$2
DB_NAME=$3
DB_USER=$4
ODOOPASSWORD=$5

#PGPASSWORD=$ODOOPASSWORD psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "delete from mail_mail;"
PGPASSWORD=$ODOOPASSWORD psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "delete from ir_mail_server;"
PGPASSWORD=$ODOOPASSWORD psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "update ir_cron set active = false where 1=1;"

#PGPASSWORD=$ODOOPASSWORD psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "update res_users set login = 'user_'||id where login <> 'admin';"
PGPASSWORD=$ODOOPASSWORD psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "update res_users set password = 'usmh';"

#
#PGPASSWORD=$ODOOPASSWORD psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "update res_partner set name = 'user_'||id,phone=id, email = 'user_'||id||'@sample.com';"
#PGPASSWORD=$ODOOPASSWORD psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "update hr_employee set name = 'employee_'||id, work_email = 'employee_'||id||'@sample.com'"
#PGPASSWORD=$ODOOPASSWORD psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "update hr_employee set account_name = 'employee_'||id, account_number = id;"
#PGPASSWORD=$ODOOPASSWORD psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "delete from config_ftp_server;"