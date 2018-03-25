
SHELL := /bin/bash

include config.makefile



# WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=vmonitor_wordpress" --filter "desired-state=Ready" --format '{{.ID}}' )

# WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.ID}}')

WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=vmonitor_wordpress" --filter "desired-state=Running" --format '{{.ID}}' )
WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}')

DIRS := ./mysql  ./html


$(DIRS):
	mkdir -p $@ && chmod 0777 $@

enter:
	docker exec -it $(WP_CONTAINER) /bin/bash 

LOG := -f
log:
	echo LOG=$(LOG) ;\
	docker logs $(LOG) $(WP_CONTAINER)

deploy: $(DIRS)
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
	echo CLI=$(CLI) ;\
	docker run -it --rm --volumes-from $(WP_CONTAINER) --network container:$(WP_CONTAINER) wordpress:cli-php7.1 $(CLI)


test:
	echo $(WP_CONTAINER)

