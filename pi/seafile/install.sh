#!/bin/bash

docker_up () {
  sed 's/$SEAFILE_ADMIN_EMAIL/{$SEAFILE_ADMIN_EMAIL}/' ./docker-compose/yml
}