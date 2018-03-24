

SHELL := /bin/bash

STACKNAME := wordpress

WPCONTAINER=$(shell docker inspect $$(docker stack ps $(STACKNAME) --filter "name=$(STACKNAME)_wordpress"  --filter "desired-state=Running" --format {{.ID}}) --format {{.Status.ContainerStatus.ContainerID}})


WORDPRESS_DB_PASSWORD := aceasfsd

CLI := core version
cli:
	echo CLI=$(CLI) ;\
	docker run -it --rm --volumes-from $(WPCONTAINER) --network container:$(WPCONTAINER) wordpress:cli-php7.1 $(CLI)

enter:
	docker exec -it $(WPCONTAINER) /bin/bash 

deploy:
	docker stack deploy --compose-file wordpress.yml $(STACKNAME) 
