#!/bin/bash
export GUM_INPUT_PROMPT="_.~^~._.~^~._.~^~._.~^~<8>--<"
TYPE=$(gum choose  --cursor.foreground="#05ffe6" --item.foreground="#8205ff" --selected.foreground="#8205ff" "install_k3s_control_plane" "install_k3s_workers" "install_helm" "get_kube_config" "uninstall_all" "exit")

if [[ "$TYPE" == "install_k3s_control_plane" ]]; then
  export MAIN_CPU$i=$(gum input --placeholder "MAIN_CPU$i (default: 1 - integer number of cores)")
  export MAIN_MEM$i=$(gum input  --placeholder "MAIN_MEM$i (default: 2 - integer Gigabytes RAM)")
  export MAIN_DISK$i=$(gum input --placeholder "MAIN_DISK$i (default: 10 integer Gigabytes local storage)")
  # export INSTALL_TRAEFIK=$(gum choose --cursor=">Install Traefik?" "yes" "no")
  TRAEFIK_COMMAND="--disable-traefik"
  gum confirm "install traefik as k3s ingress controller?" --prompt.foreground "#0FF" && \
    TRAEFIK_COMMAND=""
  echo $TRAEFIK_COMMAND
  gum confirm "Ready to create control plane" --prompt.foreground "#0FF" && \
    if [[ -z $MAIN_CPU ]]; then
      MAIN_CPU="1"
      echo "using control pane default $MAIN_CPU CPU"
    fi
    if [[ -z $MAIN_MEM ]]; then
      MAIN_MEM="2G"
      echo "using control pane default $MAIN_MEM MEM"
    fi
    if [[ -z $MAIN_DISK ]]; then
      MAIN_DISK="10G"
      echo "using control pane default $MAIN_DISK DISK"
    fi
    # multipass launch --name k3s-control-plane --cpus 4 --disk 50G --mem 8G focal
    multipass launch --name k3s-control-plane --cpus ${MAIN_CPU} --disk ${MAIN_DISK}G --mem ${MAIN_MEM}G focal && \
    echo 'updating ubuntu' && \
    multipass exec k3s-control-plane -- sh -c "sudo apt -y update && sudo apt -y upgrade" && \
    # Install k3s
    echo 'installing k3s' && \
    multipass exec k3s-control-plane -- sh -c "INSTALL_K3S_EXEC='server $TRAEFIK_COMMAND --disable-servicelb' curl -sfL https://get.k3s.io | sh - " #&& \
  exit 0
fi

if [[ "$TYPE" == "get_kube_config" ]]; then
  echo 'getting kube config' && \
  multipass exec k3s-control-plane -- sh -c "sudo chown ubuntu:ubuntu /etc/rancher/k3s/k3s.yaml" && \
  multipass exec k3s-control-plane -- sh -c "sudo chmod 744 /etc/rancher/k3s/k3s.yaml" && \
  # Copy Kube Config to local
  multipass copy-files k3s-control-plane:/etc/rancher/k3s/k3s.yaml .
fi


if [[ "$TYPE" == "install_k3s_workers" ]]; then
  N_WORKERS=$(gum input --placeholder "N_WORKERS" --cursor.foreground "#FF0" --prompt.foreground "#0FF")
  CPUS=()
  MEMS=()
  DISKS=()
  for i in $(seq 1 $N_WORKERS); do
    CPUS[i]=$(gum input --placeholder "CPU_WORKER_$i (default: 1 - integer number of cores)"  --cursor.foreground "#FF0" --prompt.foreground "#0FF")
    MEMS[i]=$(gum input  --placeholder "MEM_WORKER_$i (default: 2 - integer Gigabytes RAM)"  --cursor.foreground "#FF0" --prompt.foreground "#0FF")
    DISKS[i]=$(gum input --placeholder "DISK_WORKER_$i (default: 10 integer Gigabytes local storage)"  --cursor.foreground "#FF0" --prompt.foreground "#0FF")
  done
  # Get the kubernetes token and IP for the main node
  TOKEN=$(multipass exec k3s-control-plane sudo cat /var/lib/rancher/k3s/server/node-token)
  IP=$(multipass info k3s-control-plane | grep IPv4 | awk '{print $2}')
  gum confirm "Ready to create $N_WORKERS workers?" --prompt.foreground "#0FF" && \
  for f in $(seq 1 $N_WORKERS); do
    echo ${CPUS[f]}
    echo ${MEMS[f]}
    echo ${DISKS[f]}
    if [[ -z ${CPUS[f]} ]]; then
      CPUS[f]="1"
      echo "using worker default ${CPUS[f]}"
    fi
    if [[ -z ${MEMS[f]} ]]; then
      MEMS[f]="2G"
      echo "using worker default ${MEMS[f]}"
    fi
    if [[ -z ${DISKS[f]} ]]; then
      DISKS[f]="10G"
      echo "using worker default ${DISKS[f]}"
    fi
    multipass launch --name k3s-worker-$f --cpus ${CPUS[f]} --disk ${DISKS[f]}G --mem ${MEMS[f]}G focal
    multipass exec k3s-worker-$f -- sh -c "sudo apt -y update && sudo apt -y upgrade"
    multipass exec k3s-worker-$f -- bash -c "curl -sfL https://get.k3s.io | K3S_URL=\"https://$IP:6443\" K3S_TOKEN=\"$TOKEN\" sh -"
  done 
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
