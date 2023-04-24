#!/bin/bash

install () {
    sudo apt-get install -y certbot
    sudo apt-get install -y python3-certbot-nginx
}

configure_tuerto_certs () {
    # Get LetsEncrypt certificates. Note: requires forwarding port 80 so challenges work.
    sudo certbot --nginx \
        -d tuerto.net \
        -d www.tuerto.net \
        -d seafile.tuerto.net \
        -d nc.tuerto.net \
        -d www.seafile.tuerto.net -d www.nc.tuerto.net
}

renew_certs () {
    sudo certbot renew
}