## Self-hosted stuff

## k8s
1. kind
1. k3s
1. minikube
1. docker-for-mac k8s

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