#!/bin/bash
# NextCloud Installation
# https://raspberrytips.com/install-nextcloud-raspberry-pi/

install_sys () {
    # need apache webserver 
    sudo apt install apache2 mariadb-server libapache2-mod-php 
    sudo apt install php-gd php-json php-mysql php-curl php-mbstring php-intl php-imagick php-xml php-zip
}

install_nextcloud () {
    # install nextcloud in apache dir
    cd /var/www/html
    wget https://download.nextcloud.com/server/releases/latest.zip
    sudo unzip latest.zip
    sudo chmod 750 nextcloud -R
    sudo chown www-data:www-data nextcloud -R
}



setup_nextloud_db () {
	USERNAME=nextcloud && \
    NEXTCLOUD_PGPASSWORD=uYzfR3ASut4w6akasYgaWgQ && \
    DB_NAME=nextcloud && \
	sudo -u postgres bash -c "psql -U postgres -c \"CREATE ROLE $USERNAME PASSWORD '$NEXTCLOUD_PGPASSWORD' CREATEDB LOGIN;\" "  && \
	sudo -u postgres bash -c "psql -U postgres -c 'CREATE DATABASE $DB_NAME OWNER $USERNAME;'"  && \
	sudo -u postgres bash -c "psql -U postgres -c 'GRANT CONNECT ON DATABASE $DB_NAME TO $USERNAME; GRANT USAGE ON SCHEMA public TO $USERNAME; GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO $USERNAME;'"  && \
}

restart () {
    sudo service apache2 restart
}
