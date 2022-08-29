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
Run the `setup.sh` script if you need to install `multipass` using `brew`. This will also install `gum` for some CLI sparkle. From there...

The `deploy_gum.sh` script provides a decent promt-based shell script (thanks to [gum](https://github.com/charmbracelet/gum)) to guide you through the set-up (you don't have to do this often). You can fly through with defaults and you'll get 1 control plane and 1 worker each with 1 cpu, 2G mem, and 10G disk. Or you can enter in the details as you go and control the number of workers and the resources for each node individually.

Top-level options in the Gum Workflow looks like this:

```bash
./deploy_gum.sh:
    --install_k3s
    --install_helm
    --uninstall_all
    --exit
```
You have to `install_k3s` before you can `install_helm` into the cluster.

`uninstall_all` wipes out the `multipass` VMs and therefore any `k3s`, `helm` or whatever else was deployed.

-----------

The `deploy.sh` script can help deploy `k3s` as well if you want a one-command way to do it, and you can hard-code the resource for the workers and control-plane in the script as needed.
    - `./deploy.sh install N` will create N workers in a k3s cluster