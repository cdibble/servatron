#!/bin/bash

multipass_install () {
    # Run Multipass VM
    # multipass find
    echo "launching vm for k3s control plane plus $n_workers workers"
    multipass launch --name k3s-control-plane --cpus 2 --disk 50G --mem 4G focal
    # Update Ubuntu
    echo 'updating ubuntu'
    multipass exec k3s-control-plane -- sh -c "sudo apt -y update && sudo apt -y upgrade"
    # Install k3s
    echo 'installing k3s'
    multipass exec k3s-control-plane -- sh -c "curl -sfL https://get.k3s.io | sh -"
    # Get the kubernetes token and IP for the main node
    TOKEN=$(multipass exec k3s-control-plane sudo cat /var/lib/rancher/k3s/server/node-token)
    IP=$(multipass info k3s-control-plane | grep IPv4 | awk '{print $2}')
    for f in $(seq 1 $n_workers); do
        multipass launch --name k3s-worker-$f --cpus 2 --disk 100G --mem 4G focal
        multipass exec k3s-worker-$f -- sh -c "sudo apt -y update && sudo apt -y upgrade"
        multipass exec k3s-worker-$f -- bash -c "curl -sfL https://get.k3s.io | K3S_URL=\"https://$IP:6443\" K3S_TOKEN=\"$TOKEN\" sh -"
    done
    # Change owner and permissions of kube config
    echo 'getting kube config'
    multipass exec k3s-control-plane -- sh -c "sudo chown ubuntu:ubuntu /etc/rancher/k3s/k3s.yaml"
    multipass exec k3s-control-plane -- sh -c "sudo chmod 744 /etc/rancher/k3s/k3s.yaml"
    # Copy Kube Config to local
    multipass copy-files k3s-control-plane:/etc/rancher/k3s/k3s.yaml .
}

install () {
    # Install locally
    # echo "launching vm for k3s control plane plus $n_workers workers"
    # multipass launch --name k3s-control-plane --cpus 2 --disk 50G --mem 4G focal
    # Update Ubuntu
    echo 'updating OS'
    sudo apt -y update && sudo apt -y upgrade
    # Install k3s
    echo 'installing k3s'
    # curl -sfL https://get.k3s.io | sh -
    # TRAEFIK_COMMAND='--disable-traefik'
    INSTALL_K3S_EXEC='server $TRAEFIK_COMMAND --disable-servicelb' curl -sfL https://get.k3s.io | sh -
    # Get the kubernetes token and IP for the main node
    TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
    # IP=$(multipass info k3s-control-plane | grep IPv4 | awk '{print $2}')
    # launch worker nodes
    # for f in $(seq 1 $n_workers); do
    #     multipass launch --name k3s-worker-$f --cpus 2 --disk 100G --mem 4G focal
    #     multipass exec k3s-worker-$f -- sh -c "sudo apt -y update && sudo apt -y upgrade"
    #     multipass exec k3s-worker-$f -- bash -c "curl -sfL https://get.k3s.io | K3S_URL=\"https://$IP:6443\" K3S_TOKEN=\"$TOKEN\" sh -"
    # done
    # Change owner and permissions of kube config
    # echo 'getting kube config'
    sudo chown "$LOGNAME:$LOGNAME" /etc/rancher/k3s/k3s.yaml
    sudo chmod 744 /etc/rancher/k3s/k3s.yaml
    sudo echo -n "cgroup_memory=1 cgroup_enable=memory" >> /boot/cmdline.txt
    # Copy Kube Config to local
    # multipass copy-files k3s-control-plane:/etc/rancher/k3s/k3s.yaml .
}

multipass_shell () {
    # shell on that vm
    multipass shell k3setr-control-plane
}

install_helm () {
    # Install Helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
}

uninstall_k3s () {
  /usr/local/bin/k3s-uninstall.sh
}

# Multipass Port Forwarding to Host
# See: https://github.com/canonical/multipass/issues/309
# multipass_vm_ip=192.168.64.4
# sudo ssh \
#     -i /var/root/Library/Application\ Support/multipassd/ssh-keys/id_rsa \
#     -L 8065:localhost:8065 \
#     ubuntu@$multipass_vm_ip

USAGE='USAGE: ./deploy.sh [install|shell|install_helm] \nTo use multipass VMs, use export MULTIPASS=True'
if [[ -z $1 ]];
then
  echo $USAGE
elif [ $1 == 'multipass_install' ]; then
    if [[ -z $2 ]];
    then
        export n_workers=1
    else
        export n_workers=$2
    fi
  multipass_install
elif [ $1 == 'install' ]; then
  install
elif [ $1 == 'shell' ]; then
  shell
elif [ $1 == 'install_helm' ]; then
  install_helm
else
  echo $USAGE
fi
