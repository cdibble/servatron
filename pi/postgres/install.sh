#!/bin/bash

install () {
    sudo apt update
    sudo apt full-upgrade
    sudo apt install postgresql
}

create_user () {
    USERNAME=$2
    PGPASSWORD=$PGPASSWORD
    DB_NAME=$USERNAME
    sudo -u postgres bash -c "psql -U postgres -c \"CREATE ROLE $USERNAME PASSWORD '$PGPASSWORD' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;\" "
    sudo -u postgres bash -c "psql -U postgres -c 'CREATE DATABASE $DB_NAME OWNER $USERNAME;'"
    sudo -u postgres bash -c "psql -U postgres -c 'GRANT CONNECT ON DATABASE $DB_NAME TO $USERNAME; GRANT USAGE ON SCHEMA public TO $USERNAME; GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO $USERNAME;'"
}