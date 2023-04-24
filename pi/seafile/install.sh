#!/bin/bash

docker_up () {
  sed -i 's/$SEAFILE_ADMIN_EMAIL/'"$SEAFILE_ADMIN_EMAIL"'/' ./docker-compose.yml
  sed -i 's/$SEAFILE_ADMIN_PASSWORD/'"$SEAFILE_ADMIN_PASSWORD"'/' ./docker-compose.yml
  sed -i  's/=db_dev/'"=$SEAFILE_DB_PASSWORD"'/' ./docker-compose.yml
  sudo docker-compose up -d
}