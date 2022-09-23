#!/bin/bash
USAGE="""
looks for env vars:
MAIN_CPU
MAIN_MEM
MAIN_DISK
"""
if [[ -z $MAIN_CPU ]]; then
    MAIN_CPU="1"
    echo "using control pane default $MAIN_CPU CPU"
fi
if [[ -z $MAIN_MEM ]]; then
    MAIN_MEM="2"
    echo "using control pane default $MAIN_MEM MEM"
fi
if [[ -z $MAIN_DISK ]]; then
    MAIN_DISK="10"
    echo "using control pane default $MAIN_DISK DISK"
fi
if [[ -z $TRAEFIK_COMMAND ]]; then
    TRAEFIK_COMMAND="--disable-traefik"
    echo "disabling k3s traefik install"
fi
# multipass launch --name k3s-control-plane --cpus 4 --disk 50G --mem 8G focal
multipass launch --name k3s-control-plane --cpus ${MAIN_CPU} --disk ${MAIN_DISK}G --mem ${MAIN_MEM}G focal && \
echo 'updating ubuntu' && \
multipass exec k3s-control-plane -- sh -c "sudo apt -y update && sudo apt -y upgrade" && \
# Install k3s
echo 'installing k3s' && \
multipass exec k3s-control-plane -- sh -c "INSTALL_K3S_EXEC='server $TRAEFIK_COMMAND --disable-servicelb' curl -sfL https://get.k3s.io | sh - " #&& \
exit 0
