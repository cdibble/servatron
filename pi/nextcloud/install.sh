#!/bin/bash

docker_up () {
  sed -i  's/POSTGRES_PASSWORD=nextcloud/'"POSTGRES_PASSWORD=$NEXTCLOUD_POSTGRES_PASSWORD"'/' ./docker-compose.yml
  sudo docker-compose up -d
}