
SHELL := /bin/bash

include config.makefile



# WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=vmonitor_wordpress" --filter "desired-state=Ready" --format '{{.ID}}' )

# WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.ID}}')

WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_wordpress" --filter "desired-state=Running" --format '{{.ID}}' 2>/dev/null || echo '')
WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}' 2>/dev/null || echo '')

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


install-local:
	$(MAKE) cli CLI='core install --url=http://127.0.0.1:$(WORDPRESS_PORT) --admin_user=admin --admin_password=admin --admin_email=test@random.domain --title=test --skip-email'

test:
	echo $(WP_CONTAINER)

