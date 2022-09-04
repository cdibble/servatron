# !/bin/bash
# Mattermost Helm Chart Deployment
install () {
  multipass exec k3s-control-plane -- sh -c "
  helm repo add timescale 'https://charts.timescale.com' && \
  helm repo update && \
  KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm upgrade --install timescaledb timescale/timescaledb-single \
    --set persistentVolumes.data.size=50Gi \
    --set persistentVolumes.data.mountPath=/var/lib/postgresql \
    -n timescaledb \
    --create-namespace
  "
}

get_pg_pw () {
  PGPOSTGRESPASSWORD=$(multipass exec k3s-control-plane -- sh -c "
  kubectl get secret --namespace timescaledb timescaledb-credentials -o jsonpath="{.data.PATRONI_SUPERUSER_PASSWORD}" | base64 --decode
  ")
  echo $PGPOSTGRESPASSWORD
}

connect () {
  # TIMESCALE_IP=$(multipass exec k3s-control-plane -- sh -c "
  # kubectl get service/timescaledb -n timescaledb
  # "
  # )
  multipass exec k3s-control-plane -- sh -c "
    kubectl exec -ti timescaledb-0 -n timescaledb -- PGPASSWORD=$(get_pg_pw) psql -U postgres \
      -h timescaledb.timescaledb.svc.cluster.local postgres
  "
}


if [[ -z $1 ]];
then
  install
elif [ $1 == 'install' ]; then
    install
elif [ $1 == 'get_pg_pw' ]; then
  get_pg_pw
elif [ $1 == 'connect' ]; then
  connect
else
  echo 'USAGE: ./deploy.sh [install|get_pg_pw|connect]'
fi



#  kubectl port-forward \
#   --namespace mattermost \
#   $(kubectl get pods --namespace mattermost -l "app.kubernetes.io/name=mattermost-team-edition,app.kubernetes.io/instance=mattermost" -o jsonpath='{ .items[0].metadata.name }') \
#   8080:8065