# TimescaleDB

[PostgreSQL with TimescaleDB](https://github.com/timescale/helm-charts/tree/main/charts/timescaledb-single).

## Requirements
The community images are all amd64 architecture, so they won't work on Pi. I haven't opted to build an arm64 image for timescale yet b/c it seems like overkill.

## Installation
Install or Upgrade on the control plane node
```bash
./deploy.sh install
```

Connect to interactive psql dession

```bash
./deploy.sh connect
```

## Helm
This is installed via a helm chart. See `values.yaml` for all of the possible settings.

Note this is not actually pulling any settings from `values.yaml`, rather they're set with `--set` flags in `.deploy.sh` at the moment. That might change as I decide what configurations I might like to apply, but probably this will remain as a reference and will eventually be replaced to a link to the up-to-date documentation with the latest values file.

### Post-installation
```
    # superuser password
    PGPASSWORD_POSTGRES=$(kubectl get secret --namespace timescaledb "timescaledb-credentials" -o jsonpath="{.data.PATRONI_SUPERUSER_PASSWORD}" | base64 --decode)

    # admin password
    PGPASSWORD_ADMIN=$(kubectl get secret --namespace timescaledb "timescaledb-credentials" -o jsonpath="{.data.PATRONI_admin_PASSWORD}" | base64 --decode)

To connect to your database, choose one of these options:

1. Run a postgres pod and connect using the psql cli:
    # login as superuser
    kubectl run -i --tty --rm psql --image=postgres \
      --env "PGPASSWORD=$PGPASSWORD_POSTGRES" \
      --command -- psql -U postgres \
      -h timescaledb.timescaledb.svc.cluster.local postgres

    # login as admin
    kubectl run -i --tty --rm psql --image=postgres \
      --env "PGPASSWORD=$PGPASSWORD_ADMIN" \
      --command -- psql -U admin \
      -h timescaledb.timescaledb.svc.cluster.local postgres

2. Directly execute a psql session on the master node

   MASTERPOD="$(kubectl get pod -o name --namespace timescaledb -l release=timescaledb,role=master)"
   kubectl exec -i --tty --namespace timescaledb ${MASTERPOD} -- psql -U postgres
```