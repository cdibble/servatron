#!/bin/bash

# install backup/restore dependencies
install () {
	sudo apt-get install rsync
}

# backup databases
bak_db () {
	MYSQLPASSWORD='<insert>'
	docker exec -it seafile-mysql /bin/bash -c "mkdir -p ~/backup; \
	mysqldump -h db --user=seafile -p $MYSQLPASSWORD --opt ccnet-db > ~/backup/databases/ccnet-db.sql.`date +"%Y-%m-%d-%H-%M-%S"`; \
	mysqldump -h db --user=seafile -p $MYSQLPASSWORD --opt seafile-db > ~/backup/databases/seafile-db.sql.`date +"%Y-%m-%d-%H-%M-%S"`; \
	mysqldump -h db --user=seafile -p $MYSQLPASSWORD --opt seahub-db > ~/backup/databases/seahub-db.sql.`date +"%Y-%m-%d-%H-%M-%S"`;
	"
		}

# backup data files
bak_dat () {
	rsync -az /data/haiwen /backup/data
}

# restore databases

restore_db () {
	mysql -u[username] -p[password] ccnet-db < ccnet-db.sql.2013-10-19-16-00-05
	mysql -u[username] -p[password] seafile-db < seafile-db.sql.2013-10-19-16-00-20
	mysql -u[username] -p[password] seahub-db < seahub-db.sql.2013-10-19-16-01-05
}

# restore data files

