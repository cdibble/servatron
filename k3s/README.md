# k3s and multipass

## Multipass
MacOS compatible VM runtime that uses the system hypervisor (though you can [switch to VirtualBox](https://multipass.run/docs/set-up-the-driver#heading--macos-use-virtualbox)).

It's easy to spin up a linux node with whatever image, resource limits, etc.
```bash
multipass launch --name my-ubuntu-node --cpus 2 --disk 100G --mem 4G focal
```

## K3S
[Lightweight Kubernetes](https://k3s.io) for edge/iot applications that seems to me to be a cool potential self-hosting solution.

## Installation
Run the `setup.sh` script if you need to install `multipass` using `brew`. From there...

The `deploy_gum.sh` script provides a somewhat decent promt-based shell script to guide you through the set-up, which is reasonable b/c you don't have to do this often.

The `deploy.sh` script can help deploy `k3s` as well if you want a one-command way to do it, and you can hard-code the resource for the workers and control-plane in the script as needed.
    - `./deploy.sh install N` will create N workers in a k3s cluster