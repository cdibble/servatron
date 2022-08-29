# Self-hosted stuff

## k8s locally
1. kind
1. k3s
1. minikube
1. microk8s
1. docker-for-mac k8s

I have implemented `k3s` using `multipass` to manage local VMs as nodes.

## To Do
- [ ] Implement sealed secrets for various deployment secrets
- [ ] Look at storage classes in cluster and figure out how to persist backends or dump backups to the local host

## Notes
## K3S

1. Dynamic storage class

[Local Volume Provisionaer](https://github.com/rancher/local-path-provisioner)

```
curl -LO https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
sudo kubectl apply -f local-path-storage.yaml
sudo kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Jenkins
jenkins.yaml:
```
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

sudo kubectl create ns jenkins
sudo kubectl apply -f jenkins.yaml