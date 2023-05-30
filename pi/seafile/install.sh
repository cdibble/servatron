#!/bin/bash

docker_up () {
  sed -i 's/$SEAFILE_ADMIN_EMAIL/'"$SEAFILE_ADMIN_EMAIL"'/' ./docker-compose.yml
  sed -i 's/$SEAFILE_ADMIN_PASSWORD/'"$SEAFILE_ADMIN_PASSWORD"'/' ./docker-compose.yml
  sed -i  's/=db_dev/'"=$SEAFILE_DB_PASSWORD"'/' ./docker-compose.yml
  sudo docker-compose up -d
}

mount_seafuse_filesystem () {
   docker exec -ti seafile bash -c 'cd /opt/seafile/seafile-server-latest/ &&  ./seaf-fuse.sh start /seafile-fuse'
}

create_container_user () {
  # supposedly you can run as non-root but I have not yet gotten this to work.
  # thes would be for adding non-root user to the container...
  # groupadd --gid 8000 conman
  # useradd --home-dir /home/conman --create-home --uid 8000 --gid 8000 --shell /bin/sh --skel /dev/null conman
}

