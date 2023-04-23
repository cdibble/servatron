#!/bin/bash

install () {
    sudo apt-get install certbot
    sudo apt-get install python3-certbot-nginx
    # Get LetsEncrypt certificates. Note: requires forwarding port 80 so challenges work.
    sudo certbot --nginx -d tuerto.net -d www.tuerto.net -d seafile.tuerto.net -d nextcloud.tuerto.net -d www.seafile.tuerto.net -d www.nextcloud.tuerto.net
    sudo certbot renew
}