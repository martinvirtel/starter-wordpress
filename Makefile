
SHELL := /bin/bash

include config.makefile



WPCONTAINER=$(shell docker inspect $$(docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_wordpress"  --filter "desired-state=Running" --format {{.ID}}) --format {{.Status.ContainerStatus.ContainerID}})

CLI := core version
cli:
	echo CLI=$(CLI) ;\
	docker run -it --rm --volumes-from $(WPCONTAINER) --network container:$(WPCONTAINER) wordpress:cli-php7.1 $(CLI)

enter:
	docker exec -it $(WPCONTAINER) /bin/bash 

deploy:
	docker stack deploy --compose-file wordpress.yml $(STACK_NAME) 


swarm-init:
	docker swarm init --advertise-addr 127.0.0.1
