# Executables (local)
DOCKER_COMP = docker compose
DOCKER      = docker
TERRAFORM   = terraform

# Docker containers
PHP_CONT = $(DOCKER_COMP) exec order_api
IMAGE    = europe-west1-docker.pkg.dev/digital-arbor-401319/order/order-api:latest

# Terraform configuration
TF_DIR	   = infra/terraform
TFVAR_FILE = sandbox.tfvars

# Executables
PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
SYMFONY  = $(PHP) bin/console

# User ID
UID = $(id -u)
GID = $(id -g)

# Misc
.DEFAULT_GOAL = help
.PHONY        : help build up start down logs sh composer vendor sf cc

## —— 🎵 🐳 The Symfony Docker Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMP) build --pull --no-cache

up: ## Start the docker hub in detached mode (no logs)
	@$(DOCKER_COMP) up --detach

start: build up ## Build and start the containers

down: ## Stop the docker hub
	@$(DOCKER_COMP) down --remove-orphans

logs: ## Show live logs
	@$(DOCKER_COMP) logs --tail=0 --follow

sh: ## Connect to the PHP FPM container
	@$(PHP_CONT) sh

release: ## Build and deploy release docker image
	$(DOCKER) build ./api --target api_prod --tag $(IMAGE)
	@$(DOCKER) push $(IMAGE)

## —— Composer 🧙 ——————————————————————————————————————————————————————————————
composer: ## Run composer, pass the parameter "c=" to run a given command, example: make composer c='req symfony/orm-pack'
	@$(eval c ?=)
	@$(COMPOSER) $(c)

vendor: ## Install vendors according to the current composer.lock file
vendor: c=install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction
vendor: composer

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands or pass the parameter "c=" to run a given command, example: make sf c=about
	@$(eval c ?=)
	@$(SYMFONY) $(c)

cc: c=c:c ## Clear the cache
cc: sf

## —— k6 Load Testing  ———————————————————————————————————————————————————————————————
stress: ## Start a stress test
	@$(DOCKER) run --env-file ./tests/.env --rm --interactive --volume ./tests/:/home/k6/ grafana/k6 run stress_test.js

## —— Terraform 📝 ———————————————————————————————————————————————————————————————
plan: ## Check terraform configuration before apply
	@cd $(TF_DIR); \
  	$(TERRAFORM) fmt; \
	$(TERRAFORM) validate; \
	$(TERRAFORM) plan --var-file=$(TFVAR_FILE)

apply: plan ## Apply terraform change to cloud
	@cd $(TF_DIR); \
	$(TERRAFORM) apply --var-file=$(TFVAR_FILE)
