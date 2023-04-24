#!/bin/bash

install () {
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg
    # Add Docker’s official GPG key:
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    # Use the following command to set up the repository:
    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
    # add conman user to docker group so we dont need to use root
    sudo usermod -aG docker conman
    newgrp docker
    # start docker daemon; may require reboot.
    sudo service docker restart
    # enable start on reboott
    sudo systemctl enable docker.service
}