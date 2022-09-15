# !/bin/bash
# Mattermost Helm Chart Deployment
install () {
  echo "installing"
  # multipass mount $LOCAL_DB_PATH k3s-control-plane:$POD_DB_PATH
  multipass exec k3s-control-plane -- sh -c '
  helm repo add mattermost https://helm.mattermost.com && \
  helm repo update && \
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml && \
  USERNAME=postgres && \
  PGPASSWORD=$(kubectl get secret --namespace timescaledb timescaledb-credentials -o jsonpath="{.data.PATRONI_SUPERUSER_PASSWORD}" | base64 --decode) && \
  DB_NAME=mattermost_prod && \
  # HOST=$(kubectl get service/timescaledb -n timescaledb -o yaml | grep "ingress:" -A 1 | grep "\s[0-9\.]*" -o | xargs) && \
  HOST=$(kubectl get service/timescaledb -n timescaledb -o yaml | grep "clusterIPs:" -A 1 | grep "\s[0-9\.]*" -o | xargs) && \
  CONN_STR="$USERNAME:$PGPASSWORD@$HOST:5432/$DB_NAME?sslmode=require&connect_timeout=10" && \
  # echo $CONN_STR && \
  helm upgrade --install mattermost mattermost/mattermost-team-edition \
    --set mysql.enabled=false \
    --set externalDB.enabled=true \
    --set externalDB.externalDriverType=postgres \
    --set externalDB.externalConnectionString=$CONN_STR \
    --set service.type=LoadBalancer \
    --set ingress.enabled=true \
    --set ingress.hosts="{mattermost.tuerto.net}" \
    --set ingress.path="/" \
    --set ingress.annotations."kubernetes\.io\/ingress\.class"=traefik \
    --set ingress.annotations."traefik\.ingress\.kubernetes\.io\/router\.entrypoints"=web \
    --set ingress.annotations."cert-manager\.io\/cluster-issuer"=selfsigned-cluster-issuer \
    -n mattermost \
    --create-namespace && \
  KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl get svc -n mattermost
  '
}


get_ip () {
  MATTERMOST_IP=$(multipass exec k3s-control-plane -- sh -c "
  kubectl get services --namespace mattermost mattermost-team-edition --output jsonpath='{.status.loadBalancer.ingress[0].ip}'" \
  )
  export MATTERMOST_IP
}


open_mattermost () {
  get_ip
  # echo $MATTERMOST_IP
  open -a /Applications/Safari.app "http://$MATTERMOST_IP:8065"
}


apply_cert () {
  # multipass exec k3s-control-plane -- sh -c "
  # sudo mkdir -p /mnt/certificate.yaml
  # "
  # multipass copy-files certificate.yaml k3s-control-plane:/mnt/metallb_cert.yaml
  multipass transfer ./certificate.yaml k3s-control-plane:.
  multipass exec k3s-control-plane -- sh -c "
  kubectl apply -f ./certificate.yaml
  "
}

if [[ -z $1 ]];
then
  install
elif [ $1 == 'install' ]; then
    install
elif [ $1 == 'get_ip' ]; then
  get_ip
elif [ $1 == 'open_mattermost' ]; then
  open_mattermost
elif [ $1 == 'apply_cert' ]; then
  apply_cert
else
  echo 'USAGE: ./deploy.sh [install|get_ip|open_mattermost|apply_cert]'
fi



#  kubectl port-forward \
#   --namespace mattermost \
#   $(kubectl get pods --namespace mattermost -l "app.kubernetes.io/name=mattermost-team-edition,app.kubernetes.io/instance=mattermost" -o jsonpath='{ .items[0].metadata.name }') \
#   8080:8065