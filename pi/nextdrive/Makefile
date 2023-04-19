install_sys_reqs:
	./install.sh install_sys

install_nextcloud: install_sys_reqs
	./install.sh install_nextcloud

nextcloud_postgres:
	docker run -d \
	-v nextcloud:/var/www/html \
	-v db:/var/lib/postgresql/data \
	-p 8080:80 nextcloud
