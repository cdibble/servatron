kube_cp:
	k3s/deploy/install_k3s_control_plane.sh

kube_worker: kube_cp
	k3s/deploy/install_k3s_workers.sh

k3s:
	k3s/deploy.sh install

helm_mp: kube_cp
	k3s/deploy/install_helm.sh

helm: k3s
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	chmod 700 get_helm.sh
	./get_helm.sh

killall:
	k3s/deploy/uninstall_vms.sh

nginx: kube_cp
	helm/nginx/deploy.sh

metallb_multipass: ngnix
	helm/metallb/deploy_multipass.sh install
	helm/metallb/deploy_multipass.sh apply_l2_config

metallb: k3s, helm
	helm/metallb/deploy.sh install
	helm/metallb/deploy.sh apply_l2_config

timescaledb: metallb
	helm/timescaledb/deploy.sh install
	helm/timescaledb/deploy.sh install_psql
	helm/timescaledb/deploy.sh connect

timescaledb_mp: metallb
	helm/timescaledb/deploy_multipass.sh install
	helm/timescaledb/deploy_multipass.sh install_psql
	helm/timescaledb/deploy_multipass.sh connect

mattermost:
	helm/mattermost/deploy.sh install
	helm/mattermost/deploy.sh get_ip

mattermost_mp: timescaledb_multipass
	helm/mattermost/deploy_multipass.sh install
	helm/mattermost/deploy_multipass.sh get_ip
	helm/mattermost/deploy_multipass.sh open_mattermost
