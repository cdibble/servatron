# !/bin/bash
multipass exec k3s-control-plane -- sh -c "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
multipass exec k3s-control-plane -- sh -c "chmod 700 get_helm.sh"
multipass exec k3s-control-plane -- sh -c "./get_helm.sh"
exit 0
