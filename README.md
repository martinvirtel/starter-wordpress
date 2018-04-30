
# Run Wordpress with Docker Stack


This repo contains a `Makefile`, a `wordpress.yml` docker-compose file and some helpers to run a copy of Wordpress inside a docker swarm, 
including the helpful `wp-cli`.

## What you need

A docker installation in swarm mode. Try `make swarm init` to create a mini-swarm with one node on your computer.


## Starting with a fresh wordpress

Please copy `config.makefile-example` to `config.makefile` and edit it until it suits your needs. 

The values for STACK_NAME and WORDPRESS_PORT need to be unique for your docker swarm. WORDPRESS_CNAME should be the DNS name or IP where your wordpress will be available.

```

STACK_NAME := vmonitor

WORDPRESS_PORT	    := 8090

WORDPRESS_CNAME := newsite.mydomain.com

```

Then run `make deploy`.


## Makefile options


  - `make cli CLI="help"` get help on what you can do with wp-cli.

  - `make stack st=rm` stop the wordpress instance

  - `make enter` start a bash shell inside the wordpress container
  
  - `make enable-site.conf` will generate and symlink a custom configuration file into `/etc/nginx/sites-available` on the Docker host. The template used is `site.conf.template`.




