# !/bin/bash
# Mattermost Helm Chart Deployment
install () {
  multipass exec k3s-control-plane -- sh -c "
  helm repo add mattermost https://helm.mattermost.com && \
  helm repo update && \
  KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm upgrade --install mattermost mattermost/mattermost-team-edition \
    --set mysql.mysqlUser=connor \
    --set mysql.mysqlPassword=samplePass123123 \
    --set service.type=LoadBalancer \
    # --set persistence.data.enabled=true \
    # --set persistence.data.size=50G \
    # --set persistence.data.storageClass=local-path \
    -n mattermost \
    --create-namespace && \
  KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl get svc -n mattermost
  "
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


if [[ -z $1 ]];
then
  install
elif [ $1 == 'install' ]; then
    install
elif [ $1 == 'get_ip' ]; then
  get_ip
elif [ $1 == 'open_mattermost' ]; then
  open_mattermost
else
  echo 'USAGE: ./deploy.sh [install|get_ip|open_mattermost]'
fi



#  kubectl port-forward \
#   --namespace mattermost \
#   $(kubectl get pods --namespace mattermost -l "app.kubernetes.io/name=mattermost-team-edition,app.kubernetes.io/instance=mattermost" -o jsonpath='{ .items[0].metadata.name }') \
#   8080:8065