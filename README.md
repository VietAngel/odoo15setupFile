**Cài Odoo 15 trên ubuntu 20.04**
# Clone source
```commandline
git clone https://git.usmh.ignica.com/usmh-all/usmh-bo/portal.git odoo_install
cd odoo_install
```

# Chạy lệnh

```commandline
sudo chmod +x odoo_install.sh && \
sudo bash odoo_install.sh "mbo" 18069 18072 "localhost" 5432 "odoo" "odoo" "usmh@odoo15hr2023" "localhost"
```
**Nếu dùng RDS database thì thay run bash trên file odoo_install_rds_database.sh**

Trong đó:
- mbo là thư mục root của dự án
- 18069 là odoo port 
- 18072 là odoo chat port 
- localhost là postgresql host
- 5432 là postgresql port
- "odoo" "odoo" lần lượt là postgresql user & mật khẩu
- usmh@odoo15 là Master Password
- localhost sau cùng là domain dự định sẽ cài 
```
    Sau khi cài đặt, cấu trúc thư mục: $INSTANCE_DIR = /opt/odoo/mbo
    ADDON_DIR=/opt/odoo/odoo15/addons,/opt/odoo/odoo15/odoo/addons,/opt/odoo/mbo/source/custom/addons
    CONFIG_DIR=/opt/odoo/mbo/config/odoo-mbo.conf
    Service name=odoo-mbo
```

## thêm Odoo 15 enterprise vào addons

after install, 
please clone or unzip source to "/opt/odoo/core/enterprise" folder

## thêm usmh custom code vào thư mục custom/addons

please clone or unzip usmh source to "$INSTANCE_DIR/source/custom/addons" folder 

## Cập nhật odoo-server config file
ví dụ project folder: mbo
folder: /opt/odoo/mbo/config/odoo-mbo.conf

remember run chown -R odoo:odoo $INSTANCE_DIR
## Cài thư python thư viện nếu cần 
and install requirements file of your custom source

## Restart odoo service
```commandline 
service odoo-mbo restart
```
