# !/bin/bash
# TimescaleDB Helm Chart Deployment
install () {
  POD_DB_PATH=/var/lib/rancher/k3s/storage/timescaledb
  helm repo add timescale 'https://charts.timescale.com' && \
  helm repo update && \
  KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm upgrade --install timescaledb timescale/timescaledb-single \
    --set persistentVolumes.data.size=5Gi \
    --set persistentVolumes.data.storageClass=local-path \
    --set persistentVolumes.data.mountPath=$POD_DB_PATH \
    -n timescaledb \
    --create-namespace
}

get_pg_pw () {
  PGPOSTGRESPASSWORD=$(kubectl get secret --namespace timescaledb timescaledb-credentials -o jsonpath="{.data.PATRONI_SUPERUSER_PASSWORD}" | base64 --decode)
  echo $PGPOSTGRESPASSWORD
}


get_pg_host () {
  # HOST_IP=$(multipass exec k3s-control-plane -- sh -c "
  # kubectl get service/timescaledb -n timescaledb -o yaml | grep ingress -A 1 | awk '{print $4}'
  # ")
  HOST_IP=$(kubectl get service/timescaledb -n timescaledb -o yaml | grep 'ingress:' -A 1 | grep '\s[0-9\.]*' -o | xargs)
  echo $HOST_IP
}

connect () {
  HOST_IP=$(get_pg_host)
  PGPASS=$(get_pg_pw)
  PGPASSWORD=$PGPASS psql -U postgres -h $HOST_IP postgres
}

connect_pod_tunnel () {
  kubectl exec -ti timescaledb-0 -n timescaledb -- /usr/lib/postgresql/14/bin/psql
}


install_psql () {
  if [[ -z $1 ]];then
    psql_version=14
    echo 'installing psql-14 (default)'
  else
    psql_version=$1
    echo "installing psql-$1"
  fi
  echo $psql_version
  echo $psql_version > psql_version.txt

  sudo sh -c ''echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list''
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
  sudo apt-get update
  sudo apt-get install -y postgresql-$(cat psql_version.txt)
}

# cat << EOF > command.txt
# sudo sh -c \'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list\'
# EOF

# multipass exec k3s-control-plane -- sh -c "cat << EOF > command.txt
# sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
# EOF
# "
# # sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
#   # command=sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
#   # multipass exec k3s-control-plane -- sh -c "sudo mkdir -p /etc/apt/sources.list.d/pgdg.list"
#   echo 'ok'
#   DISTRO=$(multipass exec k3s-control-plane -- sh -c "lsb_release -cs")
#   COMM="deb http://apt.postgresql.org/pub/repos/apt $DISTRO-pgdg main"
#   command="sudo sh -c \"echo $COMM\" > /etc/apt/sources.list.d/pgdg.list"
#   multipass exec k3s-control-plane -- sh -c "cat << EOF > command.txt
#     $command
#     "
#   multipass exec k3s-control-plane -- sh -c "$(cat command.txt)"
#   command='
#   sudo sh -c ''echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main"  >> /etc/apt/sources.list.d/pgdg.list''
#   '
#   # command='echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
#   echo "$command"
#   # multipass exec k3s-control-plane -- sh -c $command
#   multipass exec k3s-control-plane -- sh -c "
#   wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
#   "
#   multipass exec k3s-control-plane -- sh -c "sudo apt-get update"
#   multipass exec k3s-control-plane -- sh -c "sudo apt-get install -y postgresql-14"
# }


if [[ -z $1 ]];
then
  echo 'USAGE: ./deploy.sh [install|install_psql|connect|get_pg_pw|get_pg_host]'
elif [ $1 == 'install' ]; then
  install
elif [ $1 == 'install_psql' ]; then
  install_psql
elif [ $1 == 'connect' ]; then
  connect
elif [ $1 == 'get_pg_pw' ]; then
  get_pg_pw
elif [ $1 == 'get_pg_host' ]; then
  get_pg_host
else
  echo 'USAGE: ./deploy.sh [install|install_psql|connect|get_pg_pw|get_pg_host]'
fi



#  kubectl port-forward \
#   --namespace mattermost \
#   $(kubectl get pods --namespace mattermost -l "app.kubernetes.io/name=mattermost-team-edition,app.kubernetes.io/instance=mattermost" -o jsonpath='{ .items[0].metadata.name }') \
#   8080:8065