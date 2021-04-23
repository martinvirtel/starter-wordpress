
SHELL := /bin/bash

include config.makefile


WITH_CONFIG := set -o allexport && source <(cat .credentials .env)

# WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=vmonitor_wordpress" --filter "desired-state=Ready" --format '{{.ID}}' )

# WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.ID}}')

WP_CONTAINER := $(shell docker inspect wordpress_wordpress_1 --format '{{.ID}}' || echo '')
DB_CONTAINER := $(shell docker inspect wordpress_mysql_1 --format '{{.ID}}' || echo '')


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
	$(WITH_CONFIG)
	docker-compose --file wordpress.yml up



cli: CLI = core version
cli:
	@echo wp CLI=$(CLI) ;\
	docker run --rm --volumes-from $(WP_CONTAINER) -v$(shell pwd)/restore:/tmp/restore --network container:$(WP_CONTAINER) wordpress:cli-php$(PHP_VERSION) $(CLI)


enter-cli:
	echo ECLI=$(ECLI) ;\
	docker run -it --rm --volumes-from $(WP_CONTAINER) -v$(shell pwd)/restore:/tmp/restore --network container:$(WP_CONTAINER) --entrypoint=/bin/sh wordpress:cli-php$(PHP_VERSION) 


read-db-from-backup:
	@$(WITH_CONFIG); \
	printf "$$(date --iso-8601=seconds)---- read db from restore/mysql-db.gz \n" ;\
	zcat restore/mysql-db.gz | docker exec -i $(DB_CONTAINER) \
		sh -c 'exec mysql -u"'$$MYSQL_USER'" -p"'$$MYSQL_PASSWORD'" "'$$MYSQL_DB_NAME'"' ;\
	printf "$$(date --iso-8601=seconds)---- read db $$(ls -lh restore/mysql-db.gz) \n" 

install-local:
	$(MAKE) cli CLI="core install --url=http://127.0.0.1:$(WORDPRESS_PORT) --admin_user=admin --admin_password=admin --admin_email=test@random.domain --title=test --skip-email"

.PHONY: test
test:
	echo WP in $(WP_CONTAINER)
	echo DB in $(DB_CONTAINER)

# duply-restore:
#	sudo duply versicherungsmonitor restore /home/ubuntu/wordpress/restore --force ;\
#	sudo chown -R www-data restore/ ;\
#	sudo chmod og+r restore/mysql-db.gz 


get-docroot-from-aws: SOURCE=s3://backup.versicherungsmonitor/fc.versicherungsmonitor.de/docroot/
get-docroot-from-aws:
	@export AWS_PROFILE=versicherungsmonitor && \
	export AWS_DEFAULT_REGION=eu-central-1 && \
	printf "$$(date --iso-8601=seconds)---- Sync ./html from $(SOURCE)\n" ; \
	cd ./html/ ; \
	sudo -E aws s3 sync $(SOURCE) ./ 2>&1 ;\
	sudo chown -R www-data *; \
 	cd - ;\
	printf "$$(date --iso-8601=seconds)---- $$(du --summarize --human-readable html)\n"
	
# sudo -E aws s3 cp --recursive s3://backup.versicherungsmonitor/freistil.versicherungsmonitor.de/docroot/ ./ ;\
#
#	sudo -E rclone copy --progress --checkers 1 \
#                   --log-file /tmp/rclone.log \
#                   --log-level INFO 
#	aws-s3:backup.versicherungsmonitor/freistil.versicherungsmonitor.de/docroot/ . ;\

get-db-from-aws:
	@export AWS_PROFILE=versicherungsmonitor && \
	export AWS_DEFAULT_REGION=eu-central-1 && \
	export S3_PREFIX=s3://backup.versicherungsmonitor/fc.versicherungsmonitor.de/db/ && \
	export NOWPATH=$$(date +%Y/%m) && \
	export DBFILE=$$S3_PREFIX$$NOWPATH/$$(aws s3 ls $$S3_PREFIX$$NOWPATH/ | sort | tail -1 | awk '{ print $$4 }') &&\
	printf "$$(date --iso-8601=seconds)---- getting DB from $$DBFILE\n" ; \
	sudo -E aws s3 cp $$DBFILE restore/mysql-db.gz ;\
	printf "$$(date --iso-8601=seconds)---- $$(ls -lh restore/mysql-db.gz)\n"

check-certificate:
	openssl x509 -text -in  /etc/letsencrypt/live/aws.versicherungsmonitor.de/cert.pem


old-renew-certificate:
	 sudo docker run --rm --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot --server https://acme-v02.api.letsencrypt.org/directory certonly

refresh-certificate:
	sudo docker run --rm -p 80:80 -it --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot  certonly --standalone -d aws.versicherungsmonitor.de

refresh-certificate-all:
	sudo docker run --rm -p 80:80 -it --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot  certonly --standalone -d aws.versicherungsmonitor.de -d versicherungsmonitor.de -d www.versicherungsmonitor.de

renew-certificate:
	sudo docker run --rm -p 80:80 -it --name certbot -v "/etc/letsencrypt:/etc/letsencrypt" -v "/var/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot  renew --standalone --non-interactive --agree-tos -m martin.virtel@gmail.com

SITEURL=https://aws.versicherungsmonitor.de
set-url:
	make cli CLI="option set siteurl $(SITEURL)"
	make cli CLI="option set home $(SITEURL)"

