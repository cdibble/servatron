# !/bin/bash
# Cert Manager Helm Chart Deployment
install () {
  multipass exec k3s-control-plane -- sh -c "
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml
  "
}


apply_cluster_issuer () {
  multipass transfer ./cluster_issuer_manifest.yaml k3s-control-plane:.
  multipass exec k3s-control-plane -- sh -c "
  kubectl apply -f ./cluster_issuer_manifest.yaml -n cert-manager
  "
}


if [[ -z $1 ]];
then
  install
elif [ $1 == 'install' ]; then
    install
elif [ $1 == 'apply_cluster_issuer' ]; then
  apply_cluster_issuer
elif [ $1 == 'connect' ]; then
  connect
else
  echo 'USAGE: ./deploy.sh [install|apply_cluster_issuer|connect]'
fi



#  kubectl port-forward \
#   --namespace mattermost \
#   $(kubectl get pods --namespace mattermost -l "app.kubernetes.io/name=mattermost-team-edition,app.kubernetes.io/instance=mattermost" -o jsonpath='{ .items[0].metadata.name }') \
#   8080:8065