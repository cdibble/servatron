update_os:
	./setup.sh update_os

setup_github:
	./setup.sh setup_github && \
	echo "Add the above key to your Github Account!!"

install_docker:
	./docker/install.sh install

install_nginx:
	./nginx/install.sh install

configure_nginx:
	./nginx/install.sh rm_defaults
	./nginx/install.sh configure_nginx

install_certbot:
	./certbot/install.sh install

configure_certbot:
	./certbot/install.sh configure_tuerto_certs

start_seafile:
	./seafile/docker-compose.yml up

configure_seafile:
	./seafile/install.sh rm_defaults
	./seafile/install.sh configure_seafile


