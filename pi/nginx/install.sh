#!/bin/bash

install () {
    sudo apt remove apache2
    sudo apt install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
}

rm_defaults () {
    rm /etc/nginx/sites-enabled/default
    rm /etc/nginx/sites-available/default
}

setup_nginx_servers () {
    # create config for seafile nginx
    sudo cp ./nginx_confs/* /etc/nginx/sites-available
    for file in ./nginx_confs/*; do
        sudo cp ./nginx_confs/$file /etc/nginx/sites-available/$file
        sudo ln -s /etc/nginx/sites-available/$file /etc/nginx/sites-enabled/$file
    sudo service nginx restart
}