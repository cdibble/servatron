# TimescaleDB

[PostgreSQL with TimescaleDB](https://github.com/timescale/helm-charts/tree/main/charts/timescaledb-single).


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