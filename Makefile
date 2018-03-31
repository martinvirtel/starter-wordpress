
SHELL := /bin/bash

include config.makefile



# WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=vmonitor_wordpress" --filter "desired-state=Ready" --format '{{.ID}}' )

# WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.ID}}')

WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_wordpress" --filter "desired-state=Running" --format '{{.ID}}' 2>/dev/null || echo '')
WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}' 2>/dev/null || echo '')


MYSQL_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_mysql" --filter "desired-state=Running" --format '{{.ID}}' 2>/dev/null || echo '')
MYSQL_CONTAINER := $(shell docker inspect $(MYSQL_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}' 2>/dev/null || echo '')


DIRS:= ./mysql  ./html

dirs:
	@{ \
	if [ ! -d html ] ; then \
		mkdir html ;\
		sudo chown 33:$${USER} html ;\
		sudo chmod g+wx html ;\
	fi ;\
	if [ ! -d mysql ] ; then \
		mkdir mysql ;\
		sudo chown 999:$${USER} mysql ;\
		sudo chmod g+wx mysql ;\
	fi ;\
	if [ ! -d sql ] ; then \
		mkdir sql ;\
		sudo chown 82:$${USER} sql ;\
		sudo chmod g+wx sql ;\
	fi ;\
	if [ ! -d duplicity-cache ] ; then \
		mkdir duplicity-cache ;\
		sudo chown 1896:$${USER} duplicity-cache ;\
		sudo chmod g+wx duplicity-cache ;\
	fi ;\
	}

enter:
	docker exec -it $(WP_CONTAINER) /bin/bash 

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


swarm-init:
	docker swarm init --advertise-addr 127.0.0.1


CLI := core version
cli:
	@echo wp CLI=$(CLI) ;\
	docker run -it --rm --volumes-from $(WP_CONTAINER) --network container:$(WP_CONTAINER) wordpress:cli-php7.1 $(CLI)

backup-db:
	docker run -it --rm --volumes-from $(WP_CONTAINER) \
		--volume $$(pwd)/sql:/tmp/sql \
		--network container:$(WP_CONTAINER) wordpress:cli-php7.1 db export /tmp/sql/dump.sql

install-local:
	$(MAKE) cli CLI='core install --url=http://127.0.0.1:$(WORDPRESS_PORT) --admin_user=admin --admin_password=admin --admin_email=test@random.domain --title=test --skip-email'

test-container:
	@echo wordpress=$(WP_CONTAINER) mysql=$(MYSQL_CONTAINER)


DUP := duplicity --help
duplicity: 
	@echo duplicity DUP=$(DUP);\
	docker run --rm \
		--env AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
		--env AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
                --volume $$(pwd)/duplicity-cache:/home/duplicity/.cache/duplicity \
                --volume $$(pwd)/sql:/var/www/sql \
		--volumes-from $(WP_CONTAINER) \
 		--network container:$(WP_CONTAINER) \
	wernight/duplicity $(DUP)

run-backup: backup-db
	$(MAKE) duplicity DUP="duplicity --s3-use-new-style --s3-european-buckets --full-if-older-than 1M --no-encryption /var/www s3://s3.eu-central-1.amazonaws.com/backup-virtel/opengov.cat"
	$(MAKE) duplicity DUP="duplicity --s3-use-new-style --s3-european-buckets remove-older-than 2M --force s3://s3.eu-central-1.amazonaws.com/backup-virtel/opengov.cat"
	
