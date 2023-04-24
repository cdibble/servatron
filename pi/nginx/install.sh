#!/bin/bash

install () {
    sudo apt remove -y apache2
    sudo apt install nginx -y
    sudo systemctl start nginx
    sudo systemctl enable nginx
}

rm_defaults () {
    sudo rm /etc/nginx/sites-enabled/default
    sudo rm /etc/nginx/sites-available/default
}

configure_nginx () {
    # create config for seafile nginx
    for file in ./nginx_confs/*; do
        filename=$(basename $file)
        echo $filename
        sudo cp ${file}  /etc/nginx/sites-available/${filename};
        sudo ln -s /etc/nginx/sites-available/$filename /etc/nginx/sites-enabled/$filename
    done
    # add index file
    sudo cp ./index.html /var/www/html/index.html
    sudo service nginx restart
}