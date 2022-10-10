# !/bin/bash

deploy_frp_public () {
    curl -fsSL 'https://github.com/fatedier/frp/releases/download/v0.44.0/frp_0.44.0_darwin_amd64.tar.gz' -o 'frp.tar.gz'
    mkdir frp
    tar -xf frp.tar.gz -C frp --strip=1
    # create frps config; note port 7000 is used by AirDrop
cat << EOF > frps.ini
[common]
bind_port = 8000
EOF
    # list active ports
    # lsof -iTCP -sTCP:LISTEN -n -P

    # start frps
    ./frp/frps -c ./frps.ini
}



deploy_frp_cluster () {
    SERVER_IP=$(curl ifconfig.me)
    # downlaod and tar FRP
    multipass exec k3s-control-plane -- sh -c "
        curl -fsSL 'https://github.com/fatedier/frp/releases/download/v0.44.0/frp_0.44.0_linux_amd64.tar.gz' -o 'frp.tar.gz' \
        && mkdir frp \
        && tar -xf frp.tar.gz -C frp --strip=1
        "
    # create frpc config
    multipass exec k3s-control-plane -- sh -c "
cat << EOF > frpc.ini 
[common]
server_addr = 192.168.86.200
server_port = 8000

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000
EOF "
    CONTROL_PLANE_IP=$(multipass info k3s-control-plane | grep IPv4 | grep -e '\s[0-9\.]*' -o | xargs)
    # Set up SSH
    sudo ssh-keygen -f frp_id_rsa -N ''
    chmod 600 frp_id_rsa
    multipass exec k3s-control-plane -- sh -c "
cat << EOF >> ~/.ssh/authorized_keys
$(cat frp_id_rsa.pub)
EOF
"
    multipass exec k3s-control-plane -- sh -c "cat ~/.ssh/id_rsa"
    ssh-keyscan -t rsa $CONTROL_PLANE_IP >> ~/.ssh/known_hosts
    # start frp
    multipass exec k3s-control-plane -- sh -c "
        ./frp/frpc -c ./frpc.ini
        "
}

# test ssh access
# ssh -oPort=6000 ubuntu@192.168.86.200

