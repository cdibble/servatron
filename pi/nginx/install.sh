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
    for file in ./nginx_confs/*; do
        filename=$(basename $file)
        echo $filename
        sudo cp ${file}  /etc/nginx/sites-available/${filename};
        sudo ln -s /etc/nginx/sites-available/$filename /etc/nginx/sites-enabled/$filename
    done
    sudo service nginx restart
}