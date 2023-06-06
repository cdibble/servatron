#!/bin/bash

# install backup/restore dependencies
install () {
	sudo apt-get install rsync
}

# mount bak drive
mount_bak () {
	# make fs
	# sudo mkfs.ext4 /dev/sdb2
	# 
	sudo mkdir -p /mnt/bak
	sudo chmod 0777 /mnt/bak
	# TODO: Look at the device with the /root volume and mount the other device...
		# b/c whether it is sda or sdb depends on boot order and is seemingly not deterministic
	sudo mount -t ext4 /dev/sda2 /mnt/bak -o rw # use -o umask=000
	# auto-mount on boot; dont enable until after first backup just in case this corrupts the boot volume.
	# echo "/dev/sda2 /mnt/bak ntfs-3g async,big_writes,noatime,nodiratime,nofail,uid=1000,gid=1000,umask=007,x-systemd.device-timeout=1 0 0" >> /etc/fstab
}

# backup databases
bak_db () {
	export MYSQLPASSWORD="PASSWORD" # Example
	docker exec -it seafile-mysql /bin/bash -c "mkdir -p ~/backup/databases; \
	mysqldump -h db -uroot -p$MYSQLPASSWORD --opt ccnet_db > ~/backup/databases/ccnet_db.sql.`date +"%Y-%m-%d-%H-%M-%S"`; \
	mysqldump -h db -uroot -p$MYSQLPASSWORD --opt seafile_db > ~/backup/databases/seafile_db.sql.`date +"%Y-%m-%d-%H-%M-%S"`; \
	mysqldump -h db -uroot -p$MYSQLPASSWORD --opt seahub_db > ~/backup/databases/seahub_db.sql.`date +"%Y-%m-%d-%H-%M-%S"`;
	"
	sudo docker cp seafile-mysql:/root/backup/databases/. /mnt/bak/seafile/mysql/
}
bak_data () {
	# -a for archive; -z for compress; -S efficient sparse file handling
	sudo rsync -azS /opt/seafile-data/seafile /mnt/bak/seafile/data/
}

setup_cron_bak () {
  # use system cron (root user) to run docker exec command (as www-data user) for nextcloud background jobs.
  sudo su -
  cronline="0 0 * * * sudo rsync -azS /opt/seafile-data/seafile /mnt/bak/seafile/data/" 
  (crontab -u $(whoami) -l; echo "$cronline" ) | crontab -u $(whoami) -
  exit
}

# restore databases
restore_db () {
	mysql -u[username] -p[password] ccnet-db < ccnet-db.sql.2013-10-19-16-00-05
	mysql -u[username] -p[password] seafile-db < seafile-db.sql.2013-10-19-16-00-20
	mysql -u[username] -p[password] seahub-db < seahub-db.sql.2013-10-19-16-01-05
}

# restore data files
