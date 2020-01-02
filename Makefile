
SHELL := /bin/bash

include config.makefile



# WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=vmonitor_wordpress" --filter "desired-state=Ready" --format '{{.ID}}' )

# WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.ID}}')

WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_wordpress" --filter "desired-state=Running" --format '{{.ID}}' 2>/dev/null || echo '')
WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}' 2>/dev/null || echo '')


MYSQL_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_mysql" --filter "desired-state=Running" --format '{{.ID}}' 2>/dev/null || echo '')
MYSQL_CONTAINER := $(shell docker inspect $(MYSQL_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}' 2>/dev/null || echo '')

DIRS := ./mysql  ./html


dirs:
	@{ \
	if [ ! -d html ] ; then \
		mkdir html ;\
		sudo chown 33:$(USER) html ;\
		sudo chmod g+wx html ;\
	fi ;\
	if [ ! -d mysql ] ; then \
		mkdir mysql ;\
		sudo chown 999:$(USER) mysql ;\
		sudo chmod g+wx mysql ;\
	fi ;\
	}

enter:
	docker exec -it $(WP_CONTAINER) /bin/bash 

enter-mysql:
	docker exec -it $(MYSQL_CONTAINER) /bin/bash

LOG := -f
log:
	echo LOG=$(LOG) ;\
	docker logs $(LOG) $(WP_CONTAINER)

deploy: dirs 
	WORDPRESS_PORT=$(WORDPRESS_PORT) \
	MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD) \
	docker stack deploy --compose-file wordpress.yml $(STACK_NAME) 

ST = ps
stack:  
	@echo ST=$(ST) - docker stack $(ST) $(STACK_NAME) ;\
	docker stack $(ST) $(STACK_NAME)

site-up: 
	$(MAKE) deploy

site-down:
	$(MAKE) stack ST=remove

swarm-init:
	docker swarm init --advertise-addr 127.0.0.1


CLI := core version
cli:
	@echo wp CLI=$(CLI) ;\
	docker run --rm --volumes-from $(WP_CONTAINER) -v$(shell pwd)/restore:/tmp/restore --network container:$(WP_CONTAINER) wordpress:cli-php7.1 $(CLI)


enter-cli:
	echo ECLI=$(ECLI) ;\
	docker run -it --rm --volumes-from $(WP_CONTAINER) -v$(shell pwd)/restore:/tmp/restore --network container:$(WP_CONTAINER) --entrypoint=/bin/sh wordpress:cli-php7.1 

read-db-from-backup:
	docker run --rm --volumes-from $(WP_CONTAINER) -v$(shell pwd)/restore:/tmp/restore --network container:$(WP_CONTAINER) --entrypoint=/bin/sh wordpress:cli-php7.1 -c "zcat /tmp/restore/mysql-db.gz | wp db query"

install-local:
	$(MAKE) cli CLI="core install --url=http://127.0.0.1:$(WORDPRESS_PORT) --admin_user=admin --admin_password=admin --admin_email=test@random.domain --title=test --skip-email"

test:
	echo $(WP_CONTAINER)

# duply-restore:
#	sudo duply versicherungsmonitor restore /home/ubuntu/wordpress/restore --force ;\
#	sudo chown -R www-data restore/ ;\
#	sudo chmod og+r restore/mysql-db.gz 


get-docroot-from-aws:
	export AWS_PROFILE=versicherungsmonitor && \
	export AWS_DEFAULT_REGION=eu-central-1 && \
	echo ---- Getting docroot from AWS ; \
	cd ./html/ ; \
	sudo -E aws s3 sync s3://backup.versicherungsmonitor/freistil.versicherungsmonitor.de/docroot/ ./ 2>&1 ;\
	sudo chown -R www-data *
	
# sudo -E aws s3 cp --recursive s3://backup.versicherungsmonitor/freistil.versicherungsmonitor.de/docroot/ ./ ;\
#
#	sudo -E rclone copy --progress --checkers 1 \
#                   --log-file /tmp/rclone.log \
#                   --log-level INFO 
#	aws-s3:backup.versicherungsmonitor/freistil.versicherungsmonitor.de/docroot/ . ;\

get-db-from-aws:
	export AWS_PROFILE=versicherungsmonitor && \
	export AWS_DEFAULT_REGION=eu-central-1 && \
	export NOWPATH=$$(date +%Y/%m) && \
	sudo -E aws s3 cp s3://backup.versicherungsmonitor/freistil.versicherungsmonitor.de/db/$$NOWPATH/$$(aws s3 ls s3://backup.versicherungsmonitor/freistil.versicherungsmonitor.de/db/$$NOWPATH/ | \
	sort | tail -1 | awk '{ print $$4 }') restore/mysql-db.gz

check-certificate:
	openssl x509 -text -in  /etc/letsencrypt/live/aws.versicherungsmonitor.de/cert.pem


renew-certificate:
	 sudo docker run --rm --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot --server https://acme-v02.api.letsencrypt.org/directory certonly

refresh-certificate:
	sudo docker run --rm -p 80:80 -it --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot  certonly --standalone -d aws.versicherungsmonitor.de

refresh-certificate-all:
	sudo docker run --rm -p 80:80 -it --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot  certonly --standalone -d aws.versicherungsmonitor.de -d versicherungsmonitor.de -d www.versicherungsmonitor.de

renew-certificate:
	sudo docker run --rm -p 80:80 -it --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot  renew --standalone

SITEURL=https://aws.versicherungsmonitor.de
set-url:
	make cli CLI="option set siteurl $(SITEURL)"
	make cli CLI="option set home $(SITEURL)"

