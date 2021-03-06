
SHELL := /bin/bash

include config.makefile



# WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=vmonitor_wordpress" --filter "desired-state=Ready" --format '{{.ID}}' )

# WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.ID}}')

WP_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_wordpress" --filter "desired-state=Running" --format '{{.ID}}' 2>/dev/null || echo '')
WP_CONTAINER := $(shell docker inspect $(WP_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}' 2>/dev/null || echo '')


# MYSQL_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_mysql" --filter "desired-state=Running" --format '{{.ID}}' 2>/dev/null || echo '')
# MYSQL_CONTAINER := $(shell docker inspect $(MYSQL_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}' 2>/dev/null || echo '')


MYSQL_SERVICE := $(shell docker stack ps $(STACK_NAME) --filter "name=$(STACK_NAME)_mysql" --filter "desired-state=Running" --format '{{.ID}}' 2>/dev/null || echo '')
MYSQL_CONTAINER := $(shell docker inspect $(MYSQL_SERVICE) --format '{{.Status.ContainerStatus.ContainerID}}' 2>/dev/null || echo '')


DIRS:= ./mysql  ./html ./log ./sql ./duplicity-cache ./certs

dirs:
	@{ \
	if [ ! -d html ] ; then \
		mkdir html ;\
		sudo chown 33:$${USER} html ;\
		sudo chmod g+wx html ;\
	fi ;\
	if [ ! -d certs ] ; then \
		mkdir certs ;\
		sudo chown 33:$${USER} certs ;\
		sudo chmod g+wx certs ;\
	fi ;\
	if [ ! -d log ] ; then \
		mkdir log ;\
		sudo chown 33:$${USER} log ;\
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
	{ \
	if [ "$(MYSQL_NETWORK)" == "" ] ; then \
		WORDPRESS_PORT=$(WORDPRESS_PORT) \
		MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD) \
		docker stack deploy --compose-file wordpress.yml $(STACK_NAME) ;\
	else \
		WORDPRESS_PORT=$(WORDPRESS_PORT) \
		MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD) \
		MYSQL_NETWORK=$(MYSQL_NETWORK) \
		WORDPRESS_DB_NAME=${STACK_NAME} \
		docker stack deploy --compose-file wordpress-with-external-db.yml $(STACK_NAME) ;\
	fi ;\
	}

deploy-self-signed-ssl:
	WORDPRESS_PORT=$(WORDPRESS_PORT) \
	MYSQL_ROOT_PASSWORD=$(MYSQL_ROOT_PASSWORD) \
	WORDPRESS_CNAME=$(WORDPRESS_CNAME) \
	docker stack deploy --compose-file wordpress-with-self-signed-ssl.yml $(STACK_NAME) ;\
	$(MAKE) set-cname-ssl



ST = ps
stack:  
	@echo ST=$(ST) - docker stack $(ST) $(STACK_NAME) ;\
	docker stack $(ST) $(STACK_NAME)


swarm-init:
	docker swarm init --advertise-addr 127.0.0.1


SSL_CERT = certs/$(WORDPRESS_CNAME).cert.pem
SSL_KEY  = certs/$(WORDPRESS_CNAME).key.pem

self-signed-certificates: $(SSL_CERT) $(SSL_KEY)

$(SSL_CERT) $(SSL_KEY):
	 openssl req -x509 -newkey rsa:4096 -nodes -subj '/CN=$(WORDPRESS_CNAME)' \
		     -keyout $(SSL_KEY) -out $(SSL_CERT) -days 3650


#	SSLCertificateFile	/etc/ssl/certs/ssl-cert-snakeoil.pem
#	SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key


CLI := core version
# User 33 = www-data https://github.com/docker-library/wordpress/issues/256
cli:
	@echo "wp CLI=$(CLI)" >&2 ;\
	docker run -u 33 --rm --volumes-from $(WP_CONTAINER) --network container:$(WP_CONTAINER) wordpress:cli-php7.1 $(CLI)


cli-settings:
	docker run -u 33 --rm --volumes-from $(WP_CONTAINER) --network container:$(WP_CONTAINER) wordpress:cli-php7.1 option set --format=json openid_connect_generic_settings '{"login_type":"button","client_id":"SHOPDPA","client_secret":"BA76F498D8F62C5589874A6C8AB89","scope":"profile email openid address phone offline_access","endpoint_login":"https:\/\/sso.dpa-id.de\/cas\/oidc\/authorize","endpoint_userinfo":"https:\/\/sso.dpa-id.de\/cas\/oidc\/profile","endpoint_token":"https:\/\/sso.dpa-id.de\/cas\/oidc\/accessToken","endpoint_end_session":"https:\/\/sso.dpa-id.de\/cas\/logout","identity_key":"preferred_username","no_sslverify":"0","http_request_timeout":"5","enforce_privacy":"0","alternate_redirect_uri":"0","nickname_key":"preferred_username","email_format":"{email}","displayname_format":"{given_name} {family_name}","identify_with_username":"0","state_time_limit":"","link_existing_users":"1","redirect_user_back":"1","redirect_on_logout":"0","enable_logging":"1","log_limit":"1000"}'

cli-term:
	@echo "wp CLI=$(CLI)" >&2 ;\
	docker run -u 33 -it --rm --volumes-from $(WP_CONTAINER) --network container:$(WP_CONTAINER) wordpress:cli-php7.1 $(CLI)

backup-db:
	docker run -u 82 --rm --volumes-from $(WP_CONTAINER) \
		--volume $$(pwd)/sql:/tmp/sql \
		--network container:$(WP_CONTAINER) wordpress:cli-php7.1 db export /tmp/sql/dump.sql

install-local:
	ADMIN_PASSWORD=$$(head /dev/urandom | md5sum | sed 's/  -//') ;\
	$(MAKE) cli CLI="core install --url=http://$(WORDPRESS_CNAME):$(WORDPRESS_PORT) --admin_user=admin --admin_password=$${ADMIN_PASSWORD} --admin_email=test@random.domain --title=$(WORDPRESS_CNAME) --skip-email"

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
	$(MAKE) duplicity DUP="duplicity --s3-use-new-style --s3-european-buckets --full-if-older-than 1M --no-encryption /var/www $(AWS_BACKUP_BUCKET)"
	$(MAKE) duplicity DUP="duplicity --s3-use-new-style --s3-european-buckets remove-older-than 2M --force $(AWS_BACKUP_BUCKET)"


site.conf: site.conf.template Makefile config.makefile
	printf "# DO NOT EDIT BY HAND \n# Generated by $(MAKE) from $$(pwd)/$< on $$(date)\n#\n#\n" >$@ ;\
	WORDPRESS_CNAME=$(WORDPRESS_CNAME) \
	WORDPRESS_PORT=$(WORDPRESS_PORT) \
	CWD=$(shell pwd) \
	envsubst <$< '$$WORDPRESS_CNAME $$CWD $$WORDPRESS_PORT' | \
        sed '1,/^$$/d' >>$@ 

site-ssl.conf: site-ssl.conf.template Makefile config.makefile
	printf "# DO NOT EDIT BY HAND \n# Generated by $(MAKE) from $$(pwd)/$< on $$(date)\n#\n#\n" >$@ ;\
	WORDPRESS_CNAME=$(WORDPRESS_CNAME) \
	WORDPRESS_PORT=$(WORDPRESS_PORT) \
	CERT_DIRECTORY=$(CERT_DIRECTORY) \
	CWD=$(shell pwd) \
	envsubst <$< '$$WORDPRESS_CNAME $$CWD $$WORDPRESS_PORT $$CERT_DIRECTORY' | \
        sed '1,/^$$/d' >>$@ 

site-selfsigned-ssl.conf: site-selfsigned-ssl.conf.template Makefile config.makefile
	printf "# DO NOT EDIT BY HAND \n# Generated by $(MAKE) from $$(pwd)/$< on $$(date)\n#\n#\n" >$@ ;\
	WORDPRESS_CNAME=$(WORDPRESS_CNAME) \
	WORDPRESS_PORT=$(WORDPRESS_PORT) \
	CERT_DIRECTORY=$(CERT_DIRECTORY) \
	CWD=$(shell pwd) \
	envsubst <$< '$$WORDPRESS_CNAME $$CWD $$WORDPRESS_PORT $$CERT_DIRECTORY' | \
        sed '1,/^$$/d' >>$@ 

CONFFILE := /etc/nginx/sites-enabled/$(WORDPRESS_CNAME).conf	
enable-site.conf: site.conf
	@if [ -e $(CONFFILE) ] ; then \
		if [ "$$(readlink $(CONFFILE))" != "$$(pwd)/site.conf" ] ; then  \
			echo $(CONFFILE) exists: $$(ls -l $(CONFFILE)); \
		else \
			echo $(CONFFILE) links to $$(pwd)/site.conf ;\
		fi \
	else \
		echo linking $(CONFFILE) to $$(pwd)/site.conf ;\
		sudo ln -s $$(pwd)/site.conf $(CONFFILE) ;\
	fi  ;\
	echo please restart nginx to make changes take effect


SSLCONFFILE := /etc/nginx/sites-enabled/$(WORDPRESS_CNAME)-ssl.conf	
enable-site-ssl.conf: site-ssl.conf
	@if [ -e $(SSLCONFFILE) ] ; then \
		if [ "$$(readlink $(SSLCONFFILE))" != "$$(pwd)/site-ssl.conf" ] ; then  \
			echo $(SSLCONFFILE) exists: $$(ls -l $(CONFFILE)); \
		else \
			echo $(SSLCONFFILE) links to $$(pwd)/site-ssl.conf ;\
		fi \
	else \
		echo linking $(SSLCONFFILE) to $$(pwd)/site-ssl.conf ;\
		sudo ln -s $$(pwd)/site-ssl.conf $(SSLCONFFILE) ;\
	fi  ;\
	echo please restart nginx to make changes take effect


disable-site-ssl.conf:
	@echo removing $(SSLCONFFILE) ;\
	sudo rm $(SSLCONFFILE) ;\
	echo please restart nginx to make changes take effect


CNAME = "http://$(WORDPRESS_CNAME)"
SSLCNAME = "https://$(WORDPRESS_CNAME)"

set-cname:
ifeq ($(CERT_DIRECTORY),)
	$(MAKE) cli CLI="option set home $(CNAME)"	
	$(MAKE) cli CLI="option set siteurl $(CNAME)"	
else
	$(MAKE) cli CLI="option set home $(SSLCNAME)"	
	$(MAKE) cli CLI="option set siteurl $(SSLCNAME)"	
endif


set-cname-ssl:
	$(MAKE) cli CLI="option set home $(SSLCNAME)"	
	$(MAKE) cli CLI="option set siteurl $(SSLCNAME)"	


config-nginx:
ifeq ($(CERT_DIRECTORY),)
	$(MAKE) enable-site.conf
	$(MAKE) set-cname
else
	$(MAKE)	enable-site-ssl.conf
	$(MAKE) set-cname-ssl
endif

self-signed:
	mkdir -p localcerts ;\
	openssl req -new -x509 -days 365 -nodes -out ./localcerts/$(WORDPRESS_CNAME).crt -keyout ./localcerts/$(WORDPRESS_CNAME).key


test-vars:
	echo WP_SERVICE=$(WP_SERVICE) WP_CONTAINER=$(WP_CONTAINER)
