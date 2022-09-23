#!/bin/bash
export GUM_INPUT_PROMPT="_.~^~._.~^~._.~^~._.~^~<8>--<"
TYPE=$(gum choose  --cursor.foreground="#05ffe6" --item.foreground="#8205ff" --selected.foreground="#8205ff" "install_k3s_control_plane" "install_k3s_workers" "install_helm" "get_kube_config" "uninstall_all" "exit")

if [[ "$TYPE" == "install_k3s_control_plane" ]]; then
  export MAIN_CPU$i=$(gum input --placeholder "MAIN_CPU$i (default: 1 - integer number of cores)")
  export MAIN_MEM$i=$(gum input  --placeholder "MAIN_MEM$i (default: 2 - integer Gigabytes RAM)")
  export MAIN_DISK$i=$(gum input --placeholder "MAIN_DISK$i (default: 10 integer Gigabytes local storage)")
  # export INSTALL_TRAEFIK=$(gum choose --cursor=">Install Traefik?" "yes" "no")
  export TRAEFIK_COMMAND="--disable-traefik"
  gum confirm "install traefik as k3s ingress controller?" --prompt.foreground "#0FF" && \
    export TRAEFIK_COMMAND=""
  echo $TRAEFIK_COMMAND
  gum confirm "Ready to create control plane" --prompt.foreground "#0FF" && \
  ./deploy/install_k3s_control_plane.sh
fi

if [[ "$TYPE" == "get_kube_config" ]]; then
  ./deploy/get_k3s_kube_config.sh
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
    K_WORKER_NAME=$f K_WORKER_CPU=${CPUS[f]} K_WORKER_DISK=${DISKS[f]} K_WORKER_MEM=${MEMS[f]} ./deploy/install_k3s_workers
  done 
fi

if [[ "$TYPE" == "install_helm" ]]; then
  # Install Helm
  ./deploy/install_helm.sh
fi

if [[ "$TYPE" == "uninstall_all" ]]; then
  gum confirm "DELETE create control plane and workers?" --prompt.foreground "#0FF" && \
  ./deploy/uninstall_vms.sh
fi

if [[ "$TYPE" == "exit" ]]; then
  exit 0
fi
