# SeaFile

## Docs

https://manual.seafile.com/docker/deploy_seafile_with_docker/

## Database

Some mysql hints/notes:

- Changing DB root password...

```sql
-- localhost only
ALTER USER 'root'@'localhost' IDENTIFIED BY 'DB_ROOT_PW';
flush privileges;

-- all hosts
ALTER USER 'root'@'%' IDENTIFIED BY 'DB_ROOT_PW';
flush privileges;

-- login
mysql -uroot -pDB_ROOT_PW
```
