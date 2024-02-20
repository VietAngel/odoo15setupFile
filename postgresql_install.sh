#!/bin/bash
sudo apt -y install postgresql-14

sudo su - postgres -c "createuser -s odoo" 2> /dev/null || true
sudo su - postgres -c "psql -c \"ALTER ROLE odoo WITH  PASSWORD '$PGPASSWORD';\""

# allow connect from odoo user
sudo sed -i 's/^#listen_addresses = 'localhost'/listen_addresses = 'localhost'/' /etc/postgresql/14/main/postgresql.conf
sudo sh -c "echo \"host    all             all             127.0.0.1/32            md5\" >> /etc/postgresql/14/main/pg_hba.conf"
sudo sh -c "echo \"host    all             all             ::1/128                 md5\" >> /etc/postgresql/14/main/pg_hba.conf"

sudo service postgresql restart