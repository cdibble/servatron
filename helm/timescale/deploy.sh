# !/bin/bash
# TimescaleDB Helm Chart Deployment
install () {
  LOCAL_DB_PATH=/opt/var/lib/postgresql
  sudo mkdir -p $LOCAL_DB_PATH
  POD_DB_PATH=/mnt/var/lib/postgresql
  echo 'mounting'
  multipass mount $LOCAL_DB_PATH k3s-control-plane:$POD_DB_PATH
  multipass exec k3s-control-plane -- sh -c "
  helm repo add timescale 'https://charts.timescale.com' && \
  helm repo update && \
  KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm upgrade --install timescaledb timescale/timescaledb-single \
    --set persistentVolumes.data.size=50Gi \
    --set persistentVolumes.data.mountPath=$POD_DB_PATH \
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


get_pg_host () {
  # HOST_IP=$(multipass exec k3s-control-plane -- sh -c "
  # kubectl get service/timescaledb -n timescaledb -o yaml | grep ingress -A 1 | awk '{print $4}'
  # ")
  HOST_IP=$(multipass exec k3s-control-plane -- sh -c "kubectl get service/timescaledb -n timescaledb -o yaml | grep 'ingress:' -A 1 | grep '\s[0-9\.]*' -o | xargs")
  echo $HOST_IP
}

connect () {
  HOST_IP=$(get_pg_host)
  PGPASS=$(get_pg_pw)
  multipass exec k3s-control-plane -- sh -c "
    PGPASSWORD=$PGPASS psql -U postgres -h $HOST_IP postgres
  "
}

connect_pod_tunnel () {
  multipass exec k3s-control-plane -- sh -c "
    kubectl exec -ti timescaledb-0 -n timescaledb -- /usr/lib/postgresql/14/bin/psql
  "
}

install_psql () {
  # sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  # command='sudo sh -c '\''echo $("deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main") > /etc/apt/sources.list.d/pgdg.list'\'''
  # multipass exec k3s-control-plane -- sh -c "sudo mkdir -p /etc/apt/sources.list.d/pgdg.list"
  command='sudo sh -c ''echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main"  > /etc/apt/sources.list.d/pgdg.list'''
  echo "$command"
  multipass exec k3s-control-plane -- sh -c "($command)"
  multipass exec k3s-control-plane -- sh -c "
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  "
  multipass exec k3s-control-plane -- sh -c "sudo apt-get update"
  multipass exec k3s-control-plane -- sh -c "sudo apt-get install -y postgresql-14"
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
elif [ $1 == 'install_psql' ]; then
  install_psql
elif [ $1 == 'get_pg_host' ]; then
  get_pg_host
else
  echo 'USAGE: ./deploy.sh [install|get_pg_pw|connect|install_psql|get_pg_host]'
fi



#  kubectl port-forward \
#   --namespace mattermost \
#   $(kubectl get pods --namespace mattermost -l "app.kubernetes.io/name=mattermost-team-edition,app.kubernetes.io/instance=mattermost" -o jsonpath='{ .items[0].metadata.name }') \
#   8080:8065