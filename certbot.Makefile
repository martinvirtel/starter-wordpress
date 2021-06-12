SHELL := /bin/bash

.SHELLFLAGS := -ecu
.ONESHELL:

.DEFAULT_GOAL := help

.PHONY: renew
renew: 
	export CERTBOTDIR=$$(pwd)/certbot
	echo $$CERTBOTDIR
	docker run --rm \
		--mount type=bind,src="$$CERTBOTDIR",dst=/tmp \
		certbot/dns-cloudflare:arm64v8-v1.16.0 \
		certonly \
		--config-dir=/tmp/config \
        --work-dir=/tmp/work \
        --logs-dir=/tmp/logs \
		--agree-tos \
		-m martin.virtel@gmail.com \
		--eff-email \
		-n \
		--dns-cloudflare \
		--dns-cloudflare-credentials /tmp/cloudflare.ini \
		-d "*.versicherungsmonitor.de"


# help prints out lines with double # 
.PHONY: help
help: ## Show help
	@cat $(MAKEFILE_LIST) | grep '\#\#'


