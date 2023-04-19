#!/bin/bash

update_os () {
    sudo apt update
    sudo apt full-upgrade -y
    sudo apt install git-all -y
}

setup_github () {
    ssh-keygen -t ed25519 -C "cddibble@gmail.com"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    cat ~/.ssh/id_ed25519.pub
}

add_k3s_user () {
    sudo groupadd k3s
    sudo useradd -u 666 -g k3s -m k3s -p $K3S_USER_PASSWORD
}

add_bashrc () {
    echo 'alias kc="kubectl"' >> ~/.bash_aliases
}