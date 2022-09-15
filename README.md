# Servatron: self-hosted
I don't always run servers in closets, but when I do, it's using this infrastructure.

Implements `k3s` using `multipass` to manage local VMs as nodes.

Helm charts for playing around with FOSS projects are in here as well.

## Options for k8s locally
There are many. Here are a few I looked at.

1. kind
1. k3s
1. minikube
1. microk8s
1. docker-for-mac k8s
1. rancher desktop

## Other self-hosting projects
Some notable efforts I've seen to facilitate self-hosting on old computers or VMs or cloud.

1. [YunoHost](https://yunohost.org/#/)
1. [Tipi](https://github.com/meienberger/runtipi)
1. [k3s home cluster blog post](https://www.fullstaq.com/knowledge-hub/blogs/setting-up-your-own-k3s-home-cluster)

## To Do
- [ ] Implement sealed secrets for various deployment secrets
- [ ] Look at storage classes in cluster and figure out how to persist backends or dump backups to the local host
- [ ] Implement a Postgres DB for the mattermost backend that works on any architecture.
    - [ ] Deploy `timescaledb` as helm chart
    - [ ] Connect `mattermost` to this `timescaledb` deployment to use as a backend DB.
        - [ ] Need a func for extracting connection info

# K3S
`k3s` is deployed onto `multipass` VMs by the `./k3s/deploy*` scripts. Those scripts will handle creating a control-plane and N worker nodes. You can also install helm that way.

From there, it seems to be plain old kubernetes. You can expose `Services` to the host via `LoadBalancer` types and to the internet with `Ingress` configs. Access to the cluster directly requires a shell on one of the nodes (e.g. `multipass shell k3s-control-plane`).

See [k3s/README.md](./k3s/README.md) for more info.

## k3s configs
I'm learning along the way with `k3s`... this is sort of a staging area for components and configurations I'm finding as I dig around.

1. SQL Backend
  1. Comes with MySQL out of the box, but this doesn't support ARM64 archs.
  1. Allows pointing to an external db solution.
1. Dynamic storage class

  [Local Volume Provisionaer](https://github.com/rancher/local-path-provisioner)

  ```
  curl -LO https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
  sudo kubectl apply -f local-path-storage.yaml
  sudo kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
  ```

# Helm Charts
## Mattermost
See [./helm/mattermost/README.md](./helm/mattermost/README.md)

## Jenkins
I haven't yet built an install script around this, but it's easy enough. Here's how you can play with Jenkins in a dev environment if you like.

jenkins.yaml:

```bash
apiVersion: k3s.cattle.io/v1
kind: HelmChart
metadata:
  name: jenkins
  namespace: jenkins
spec:
  chart: stable/jenkins
  targetNamespace: jenkins
  valuesContent: |-
    Master:
      AdminUser: {{ .adminUser }}
      AdminPassword: {{ .adminPassword }}
    rbac:
      install: true
```

install: 

```bash
  sudo kubectl create ns jenkins
  sudo kubectl apply -f jenkins.yaml
```