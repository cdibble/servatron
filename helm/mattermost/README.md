# Mattermost

This is a FOSS alternative to Slack et al.

I'm just playing with it.


## Requirements
Helm chart deeply [assumes](https://forum.mattermost.com/t/raspberry-pi-4-mattermost-inside-docker/8112) AMD64 arch. There are instructions for running it natively on Pi [here](https://github.com/justinegeffen/mattermost_raspberrypi_recipe/blob/master/README.md).

## Installation
Install or Upgrade on the control plane node
```bash
./deploy.sh install
```

Export the External IP address of the Mattermost `Service.LoadBalancer`
```bash
./deploy.sh get_ip
```

Open Mattermost (takes a few minutes to spin up on first initall)
```bash
./deploy.sh open_mattermost
```

## Helm
This is installed via a helm chart. See `values.yaml` for all of the possible settings.

Note this is not actually pulling any settings from `values.yaml`, rather they're set with `--set` flags in `.deploy.sh` at the moment. That might change as I decide what configurations I might like to apply, but probably this will remain as a reference and will eventually be replaced to a link to the up-to-date documentation with the latest values file.