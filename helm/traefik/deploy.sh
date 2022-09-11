# !/bin/bash
# Traefik Helm Chart Deployment
install () {
  multipass exec k3s-control-plane -- sh -c "
  helm repo add traefik https://helm.traefik.io/traefik && \
  helm repo update && \
  KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm upgrade --install traefik traefik/traefik \
    --set dashboard.enabled=true \
    --set rbac.enabled=true \
    -n kube-system \
    --create-namespace
  "
}

traefik_pf () {
  CONTROL_PLANE_IP=$(multipass info k3s-control-plane | grep IPv4 | grep -e '\s[0-9\.]*' -o | xargs)
  sudo ssh \
      -i /var/root/Library/Application\ Support/multipassd/ssh-keys/id_rsa \
      -L 9000:localhost:8080 \
      -o StrictHostKeyChecking=no \
      ubuntu@$CONTROL_PLANE_IP
  # curl $CONTROL_PLANE_IP:9000
}
# sudo ssh \
#     -i /var/root/Library/Application\ Support/multipassd/ssh-keys/id_rsa \
#     -L 8065:localhost:8065 \
#     ubuntu@$multipass_vm_ip


# traefik_pf () {
#   multipass exec k3s-control-plane -- sh -c "
#   kubectl port-forward deploy/traefik 9000 -n kube-system
#   "
# }


if [[ -z $1 ]];
then
  install
elif [ $1 == 'install' ]; then
    install
elif [ $1 == 'traefik_pf' ]; then
  traefik_pf
elif [ $1 == 'connect' ]; then
  connect
else
  echo 'USAGE: ./deploy.sh [install|traefik_pf|connect]'
fi



#  kubectl port-forward \
#   --namespace mattermost \
#   $(kubectl get pods --namespace mattermost -l "app.kubernetes.io/name=mattermost-team-edition,app.kubernetes.io/instance=mattermost" -o jsonpath='{ .items[0].metadata.name }') \
#   8080:8065