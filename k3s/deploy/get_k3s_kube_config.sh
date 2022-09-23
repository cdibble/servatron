# !/bin/bash
echo 'getting kube config' && \
multipass exec k3s-control-plane -- sh -c "sudo chown ubuntu:ubuntu /etc/rancher/k3s/k3s.yaml" && \
multipass exec k3s-control-plane -- sh -c "sudo chmod 744 /etc/rancher/k3s/k3s.yaml" && \
# Copy Kube Config to local
multipass copy-files k3s-control-plane:/etc/rancher/k3s/k3s.yaml .
