# !/bin/bash
# Mattermost Helm Chart Deployment
install () {
  multipass exec k3s-control-plane -- sh -c "
  helm repo add metallb https://metallb.github.io/metallb && \
  helm repo update && \
  KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm upgrade --install metallb metallb/metallb \
    -n metallb-system \
    --create-namespace
  "
}

apply_l2_config () {
  multipass exec k3s-control-plane -- sh -c "
  sudo mkdir -p /mnt/metallb_l2_config.yaml
  "
  # multipass copy-files metallb_l2_config.yaml k3s-control-plane:/mnt/metallb_l2_config.yaml
  multipass transfer ./metallb_l2_config.yaml k3s-control-plane:.
  multipass exec k3s-control-plane -- sh -c "
  kubectl apply -f ./metallb_l2_config.yaml
  "
}

connect () {
  # TIMESCALE_IP=$(multipass exec k3s-control-plane -- sh -c "
  # kubectl get service/timescaledb -n timescaledb
  # "
  # )
  multipass exec k3s-control-plane -- sh -c "
    kubectl exec -ti timescaledb-0 -n timescaledb -- PGPASSWORD=$(apply_l2_config) psql -U postgres \
      -h timescaledb.timescaledb.svc.cluster.local postgres
  "
}


if [[ -z $1 ]];
then
  install
elif [ $1 == 'install' ]; then
    install
elif [ $1 == 'apply_l2_config' ]; then
  apply_l2_config
elif [ $1 == 'connect' ]; then
  connect
else
  echo 'USAGE: ./deploy.sh [install|apply_l2_config|connect]'
fi



#  kubectl port-forward \
#   --namespace mattermost \
#   $(kubectl get pods --namespace mattermost -l "app.kubernetes.io/name=mattermost-team-edition,app.kubernetes.io/instance=mattermost" -o jsonpath='{ .items[0].metadata.name }') \
#   8080:8065