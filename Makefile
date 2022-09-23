kube_cp:
	k3s/deploy/install_k3s_control_plane.sh

kube_worker: kube_cp
	k3s/deploy/install_k3s_workers.sh

helm: kube_cp
	k3s/deploy/install_helm.sh

killall:
	k3s/deploy/uninstall_vms.sh

nginx: kube_cp
	helm/nginx/deploy.sh

metallb: ngnix
	helm/metallb/deploy.sh install
	helm/metallb/deploy.sh apply_l2_config

timescaledb: metallb
	helm/timescaledb/deploy.sh install
	helm/timescaledb/deploy.sh install_psql
	helm/timescaledb/deploy.sh connect

mattermost: timescaledb
	helm/mattermost/deploy.sh install
	helm/mattermost/deploy.sh get_ip
	helm/mattermost/deploy.sh open_mattermost
