
# Run Wordpress with Docker Stack


This repo contains a `Makefile`,  `wordpress.yml` and `wordpress-without-db.yml` docker-compose files and some helpers to run a 
copy of Wordpress inside a docker swarm, including the helpful `wp-cli`.

## What you need

A docker installation in swarm mode. Try `make swarm init` to create a mini-swarm with one node on your computer.


## Starting with a fresh wordpress

Please clone this repo, then copy `config.makefile-example` to `config.makefile` and edit it until it suits your needs. 

The values for STACK_NAME and WORDPRESS_PORT need to be unique for your docker swarm. WORDPRESS_CNAME should be the DNS name or IP where your wordpress will be available.

```

STACK_NAME := vmonitor

WORDPRESS_PORT	    := 8090

WORDPRESS_CNAME := newsite.mydomain.com

```

Then run `make deploy install-local`. Your wordpress will be available at `http://localhost:8090/` if `8090` is the port
number you configured in `config.makefile`. The user name is `admin`. The password is set to a random string that is visible
in the terminal. You can create additional users via wp-cli like so:

```
 make cli CLI="user create martin martin.virtel@gmail.com --role=administrator"
```

## Using custom PHP exensions

Please see the subdirectory `wordpress-apache-zip/` for an example of how to do build a docker image with custom PHP extension.

Then, use this image instead insinde the `wordpress.yml` file.


## Adding a second wordpress

If you have a docker stack already running insinde the swarm, you may add a wordpress that shares the mysql database with the first stack. 

In this case, uncomment the line 

```
# Define if you want to attach to an existing network
# MYSQL_NETWORK := vmonitor_wordpress
```

inside `config.makefile`. You can find out the network name used by the first wordpress stack by running `docker network ls | grep _wordpress`. 

Also, the `MYSQL_ROOT_PASSWORD` inside the `config.makefile` has to be copied from the original stack that will provide the mysql service.

*SECURITY NOTICE* The shared mysql root password  means that the wordpress services are not completely isolated. 
A malicious user with administrator access to one wordpress website has enough rights to read and delete content 
on all the other wordpress services running on the same mysql service.


# Credentials are used for s3 backup

AWS_ACCESS_KEY_ID := AKIA------ 
AWS_SECRET_ACCESS_KEY := ------------

AWS_BACKUP_BUCKET := s3://s3.eu-central-1.amazonaws.com/backup-virtel/$(STACK_NAME)

```

STACK_NAME := vmonitor

WORDPRESS_PORT	    := 8090

WORDPRESS_CNAME := newsite.mydomain.com

```

Then run `make deploy install-local`. Your wordpress will be available at `http://localhost:8090/` if `8090` is the port
number you configured in `config.makefile`. The user name is `admin`. The password is set to a random string that is visible
in the terminal. You can create additional users via wp-cli like so:

```
 make cli CLI="user create martin martin.virtel@gmail.com --role=administrator"
```


## Makefile options


  - `make cli CLI="help"` get help on what you can do with wp-cli.

  - `make stack st=rm` stop the wordpress instance

  - `make enter` start a bash shell inside the wordpress container
  
  - `make enable-site.conf` will generate and symlink a custom configuration file into `/etc/nginx/sites-available` on the Docker host. The template used is `site.conf.template`.



## How-To: extract a Duplicator-Pro Package

   
  1. PHP
     cd html; sudo -u www-data unzip (zip-archive-name)

  2. DB
     make cli CLI="db drop"
     make cli CLI="db create"
     make cli CLI='db import /var/www/'$(find html/dup-installer -name '*sql')
     make set-cname
     # Memcachey remove
     sudo rm html/wp-content/object-cache.php html/wp-content/object-cache-memcache.php html/wp-content/object-cache-memcached.php
     # dup-installer remove
     sudo rm -rf html/dup-installer html/installer.php html/installer-backup.php html/installer-bootlog.txt html/dpro-importinstaller.php html/dup-wp-config-arc__*.txt 
     make cli CLI='plugin deactivate wp-ses'

