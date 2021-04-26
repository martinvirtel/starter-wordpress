
SHELL := /bin/bash


WITH_CONFIG := set -o allexport && source <(cat .credentials .env)

WP_CONTAINER := $(shell docker inspect wordpress_wordpress_1 --format '{{.ID}}' 2>/dev/null || echo '')
DB_CONTAINER := $(shell docker inspect wordpress_mysql_1 --format '{{.ID}}' 2>/dev/null  || echo '')


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


db-up:
	@$(WITH_CONFIG) ;\
	docker-compose --file mysql.yml up -d

db-down:
	@$(WITH_CONFIG) ;\
	docker-compose --file mysql.yml down

site-up: 
	@$(WITH_CONFIG) ;\
	docker-compose --file wordpress.yml up -d

site-down: 
	@$(WITH_CONFIG) ;\
	docker-compose --file wordpress.yml down


cli: CLI = core version
cli:
	@echo wp CLI=$(CLI) ;\
	$(WITH_CONFIG) ;\
	docker run --rm --volumes-from $(WP_CONTAINER) \
	       -v$(shell pwd)/restore:/tmp/restore \
	       --network container:$(WP_CONTAINER) \
	       --env DB_USER=$$MYSQL_USER \
	       --env DB_PASSWORD=$$MYSQL_PASSWORD \
	       --env DB_NAME=$$MYSQL_DB_NAME \
	       --env DB_HOST=mysql \
	       wordpress:cli-php$(PHP_VERSION) wp $(CLI)


enter-cli:
	echo ECLI=$(ECLI) ;\
	docker run -it --rm --volumes-from $(WP_CONTAINER) -v$(shell pwd)/restore:/tmp/restore --network container:$(WP_CONTAINER) --entrypoint=/bin/sh wordpress:cli-php$(PHP_VERSION) 


read-db-from-backup:
	@$(WITH_CONFIG); \
	printf "$$(date --iso-8601=seconds)---- START read db from restore/mysql-db.gz \n" ;\
	zcat restore/mysql-db.gz | \
	docker exec -i $(DB_CONTAINER) \
		/bin/bash -c 'mysql --defaults-extra-file=<(printf "[client]\npassword='$$MYSQL_PASSWORD'\nuser='$$MYSQL_USER'\n") "'$$MYSQL_DB_NAME'"' ;\
	printf "$$(date --iso-8601=seconds)---- END read db from restore/mysql-db.gz \n" ;\
	printf "$$(date --iso-8601=seconds)---- REPORT read db echo $$(echo "select count(*) as posts, 'posts, newest' as p, max(post_date) as latest from wp_posts" | make  querymysql | tail -1)" 

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
	printf "$$(date --iso-8601=seconds)---- START sync ./html from $(SOURCE)\n" ; \
	cd ./html/ ; \
	sudo -E aws s3 sync --only-show-errors $(SOURCE) ./ ;\
	sudo chown -R www-data *; \
 	cd - ;\
	printf "$$(date --iso-8601=seconds)---- END sync ./html from $(SOURCE)\n" ; \
	printf "$$(date --iso-8601=seconds)---- REPORT sync ./html $$(du --summarize --human-readable html)\n"
	
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
	printf "$$(date --iso-8601=seconds)---- START getting DB from $$DBFILE\n" ; \
	sudo -E aws s3 cp --only-show-errors $$DBFILE restore/mysql-db.gz ;\
	printf "$$(date --iso-8601=seconds)---- END getting DB from $$DBFILE\n" ; \
	printf "$$(date --iso-8601=seconds)---- REPORT getting DB $$(ls -lh restore/mysql-db.gz)\n"


correct-docroot:
	sudo cp config/wp-config-aws.php html/wp-config.php && \
	docker exec $(WP_CONTAINER) /bin/bash ../config/after_extract.sh


.PHONY: querymysql
querymysql:
	@$(WITH_CONFIG); \
	docker exec -i $(DB_CONTAINER) \
		/bin/bash -c 'mysql --defaults-extra-file=<(printf "[client]\npassword='$$MYSQL_PASSWORD'\nuser='$$MYSQL_USER'\n") "'$$MYSQL_DB_NAME'"' 




SITEURL=https://aws.versicherungsmonitor.de
set-url:
	@$(WITH_CONFIG); \
	printf "Setting siteurl to $(SITEURL)\n" >&2 ;\
	echo 'update wp_options set option_value="$(SITEURL)" where option_name in ("home", "siteurl")' | \
	docker exec -i $(DB_CONTAINER) \
		/bin/bash -c 'mysql --defaults-extra-file=<(printf "[client]\npassword='$$MYSQL_PASSWORD'\nuser='$$MYSQL_USER'\n") "'$$MYSQL_DB_NAME'"' ;\

