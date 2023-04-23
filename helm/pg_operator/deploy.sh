install () {
  # add repo for postgres-operator
  KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator
  # install the postgres-operator
  kubectl create ns postgres-operator
  helm install postgres-operator postgres-operator-charts/postgres-operator \
    --namespace postgres-operator
  # # add repo for postgres-operator-ui
  # helm repo add postgres-operator-ui-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator-ui
  # # install the postgres-operator-ui
  # helm install postgres-operator-ui postgres-operator-ui-charts/postgres-operator-ui
}


deploy_manifest () {
  if [[ -z $1 ]]; then
    kubectl create -f manifests/custom-complete-postgres-manifest.yaml
  else
    kubectl create -f $1
  fi
}