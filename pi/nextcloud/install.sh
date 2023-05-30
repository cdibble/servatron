#!/bin/bash

# install_host_deps () {
#   # this is for local storage mounting via the NC app "External Storage Support"
#   apt-get install smbclient
# }

docker_up () {
  sed -i  's/POSTGRES_PASSWORD=nextcloud/'"POSTGRES_PASSWORD=$NEXTCLOUD_POSTGRES_PASSWORD"'/' ./docker-compose.yml
  sudo docker-compose up -d
}

setup_cron () {
  # use system cron (root user) to run docker exec command (as www-data user) for nextcloud background jobs.
  sudo su -
  cronline="*/5 * * * * docker exec -u www-data nextcloud_nextcloud_1  php ./cron.php" 
  (crontab -u $(whoami) -l; echo "$cronline" ) | crontab -u $(whoami) -
  exit
}

setup_external_storage () {
  sudo chown -R www-data:www-data /home/conman/nc
  sudo chmod -R 0750 /home/conman/nc
}