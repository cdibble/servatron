#!/bin/bash
# gum input --cursor.foreground "#FF0" --prompt.foreground "#0FF" --prompt "°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸" \
#     --placeholder "What's up?" --width 80 #--value "Not much, hby?"
# --cursor.foreground "#FF0" --prompt.foreground "#0FF" --prompt "°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°" 
TYPE=$(gum choose  --cursor.foreground="#05ffe6" --item.foreground="#8205ff" --selected.foreground="#8205ff" "install_k3s" "install_helm" "uninstall_all" "exit")

if [[ "$TYPE" == "install_k3s" ]]; then
  export MAIN_CPU$i=$(gum input --placeholder "MAIN_CPU$i (hint: integer number of cores)" --prompt "_.~^~._.~^~._.~^~._.~^~<8>--<")
  export MAIN_MEM$i=$(gum input  --placeholder "MAIN_MEM$i (hint: 2G - integer with G for Gigabytes)" --prompt "_.~^~._.~^~._.~^~._.~^~<8>--<")
  export MAIN_DISK$i=$(gum input --placeholder "MAIN_DISK$i (hint: 50G - local storage)" --prompt "_.~^~._.~^~._.~^~._.~^~<8>--<")

  N_WORKERS=$(gum input --placeholder "N_WORKERS" --cursor.foreground "#FF0" --prompt.foreground "#0FF" --prompt "_.~^~._.~^~._.~^~._.~^~<8>--<")
  for i in $(seq 1 $N_WORKERS); do
    export CPU_WORKER_$i=$(gum input --placeholder "CPU_WORKER_$i (hint: integer number of cores)"  --cursor.foreground "#FF0" --prompt.foreground "#0FF" --prompt "_.~^~._.~^~._.~^~._.~^~<8>--<")
    export MEM_WORKER_$i=$(gum input  --placeholder "MEM_WORKER_$i (hint: 2G - integer with G for Gigabytes)"  --cursor.foreground "#FF0" --prompt.foreground "#0FF" --prompt "_.~^~._.~^~._.~^~._.~^~<8>--<")
    export DISK_WORKER_$i=$(gum input --placeholder "DISK_WORKER_$i (hint: 50G - local storage)"  --cursor.foreground "#FF0" --prompt.foreground "#0FF" --prompt "_.~^~._.~^~._.~^~._.~^~<8>--<")
    WORKER_INFO+=("CPU_WORKER_$i")
    WORKER_INFO+=("MEM_WORKER_$i")
    WORKER_INFO+=("DISK_WORKER_$i")
  done
  # WORKERS=$(gum join --horizontal $WORKER_INFO)
  gum confirm "Ready to create control plane and $N_WORKERS workers?" --prompt.foreground "#0FF" && \
    multipass launch --name k3s-control-plane --cpus ${MAIN_CPU} --disk ${MAIN_DISK} --mem ${MAIN_MEM} focal && \
    echo 'updating ubuntu' && \
    multipass exec k3s-control-plane -- sh -c "sudo apt -y update && sudo apt -y upgrade" && \
    # Install k3s
    echo 'installing k3s' && \
    multipass exec k3s-control-plane -- sh -c "curl -sfL https://get.k3s.io | sh -" && \
    # Get the kubernetes token and IP for the main node
    TOKEN=$(multipass exec k3s-control-plane sudo cat /var/lib/rancher/k3s/server/node-token) && \
    IP=$(multipass info k3s-control-plane | grep IPv4 | awk '{print $2}') && \
    for f in $(seq 1 $n_workers); do
        multipass launch --name k3s-worker-$f --cpus 2 --disk 100G --mem 4G focal
        multipass exec k3s-worker-$f -- sh -c "sudo apt -y update && sudo apt -y upgrade"
        multipass exec k3s-worker-$f -- bash -c "curl -sfL https://get.k3s.io | K3S_URL=\"https://$IP:6443\" K3S_TOKEN=\"$TOKEN\" sh -"
    done  && \
    # Change owner and permissions of kube config
    echo 'getting kube config' && \
    multipass exec k3s-control-plane -- sh -c "sudo chown ubuntu:ubuntu /etc/rancher/k3s/k3s.yaml" && \
    multipass exec k3s-control-plane -- sh -c "sudo chmod 744 /etc/rancher/k3s/k3s.yaml" && \
    # Copy Kube Config to local
    multipass copy-files k3s-control-plane:/etc/rancher/k3s/k3s.yaml .
  exit 0
fi

if [[ "$TYPE" == "install_helm" ]]; then
  # Install Helm
  multipass exec k3s-control-plane -- sh -c "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
  multipass exec k3s-control-plane -- sh -c "chmod 700 get_helm.sh"
  multipass exec k3s-control-plane -- sh -c "./get_helm.sh"
  exit 0
fi

if [[ "$TYPE" == "uninstall_all" ]]; then
  gum confirm "DELETE create control plane and workers?" --prompt.foreground "#0FF" && \
    for i in $(multipass list --format csv | grep "^k3s[A-z0-9-]*" -o); do
      echo "killing $i"
      multipass delete -p $i
    done
  exit 0
fi

if [[ "$TYPE" == "exit" ]]; then
  exit 0
fi
