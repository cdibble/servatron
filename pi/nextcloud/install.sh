#!/bin/bash

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