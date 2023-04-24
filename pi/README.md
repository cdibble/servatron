# Pi Setup

Deploys open-source applications as micoservices using docker.

Using `nginx` as a reverse-proxy, I forward traffic to the local server where it handles TLS (backed by `certbot` managed LetsEncrypt certificates) and routing to whatever applications are up on local ports.

## Installation

Note, these `make` recipes are a work in progress- I'll rebuild with a full pull when I can some day get a second Pi.

1. Flash Raspberry Pi with 64-bit Raspberry Pi OS-Lite
   1. this will run headless, so configure SSH using a secure password or keys, configure wifi (I use an isolated SSID hosting only my Pi).
1. SSH to Pi and update OS
1. Set up Github SSH keys and clone `servatron`, move to `servatron/pi`
1. install `docker`: `make install_docker`
1. install `nginx`: `make install_nginx`
   1. configure `nginx`: `make configue_nginx`
1. install `certbot`: `make install_certbot`
1. start/enable `seadrive`: `make start_seadrive`
   1. ENV vars:
      1. a
1. start/enable `nextcloud`: `make start_nextcloud`
