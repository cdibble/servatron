#!/bin/bash
USAGE="""
looks for env vars:
N_WORKERS: int
CPUS: array
MEMS: array
DISKS: array
"""
TOKEN=$(multipass exec k3s-control-plane sudo cat /var/lib/rancher/k3s/server/node-token)
IP=$(multipass info k3s-control-plane | grep IPv4 | awk '{print $2}')
if [[ -z $K_WORKER_NAME ]]; then
    K_WORKER_NAME="1"
    echo "using K_WORKER_NAME default $K_WORKER_NAME"
fi
if [[ -z $K_WORKER_CPU ]]; then
    K_WORKER_CPU="1"
    echo "using K_WORKER_CPU default $K_WORKER_CPU"
fi
if [[ -z $K_WORKER_MEM ]]; then
    K_WORKER_MEM="2"
    echo "using K_WORKER_MEM default $K_WORKER_MEM"
fi
if [[ -z $K_WORKER_DISK ]]; then
    K_WORKER_DISK="10"
    echo "using K_WORKER_DISK default $K_WORKER_DISK"
fi
multipass launch --name k3s-worker-$K_WORKER_NAME --cpus $K_WORKER_CPU --disk ${K_WORKER_DISK}G --mem ${K_WORKER_MEM}G focal
multipass exec k3s-worker-$f -- sh -c "sudo apt -y update && sudo apt -y upgrade"
multipass exec k3s-worker-$f -- bash -c "curl -sfL https://get.k3s.io | K3S_URL=\"https://$IP:6443\" K3S_TOKEN=\"$TOKEN\" sh -"
