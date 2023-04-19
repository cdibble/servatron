#!/bin/bash

install () {
    # install docker
    curl -sSL https://get.docker.com | sh
    # install docker-compose
    curl -SL https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    # add conman user to docker group so we dont need to use root
    sudo usermod -aG docker conman

}