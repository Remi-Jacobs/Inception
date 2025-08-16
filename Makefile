name = inception
CERT = secrets/ojacobs.42.fr.crt
KEY = secrets/ojacobs.42.fr.key
ENVFILE = $(CURDIR)/secrets/.env
DOCKER_COMPOSE_YML = $(CURDIR)/srcs/docker-compose.yml

fix_perms:
	@if [ -f $(CERT) ]; then chmod 644 $(CERT); fi
	@if [ -f $(KEY) ]; then chmod 600 $(KEY); fi

all:
	@printf "Launch configuration ${name}...\n"
	@bash ./srcs/requirements/wordpress/tools/make_dir.sh
	@$(MAKE) fix_perms
	@docker compose -f $(DOCKER_COMPOSE_YML) --env-file $(ENVFILE) up -d

build:
	@printf "Building configuration ${name}...\n"
	@bash ./srcs/requirements/wordpress/tools/make_dir.sh
	@$(MAKE) fix_perms
	@docker compose -f $(DOCKER_COMPOSE_YML) --env-file $(ENVFILE) up -d --build

down:
	@printf "Stopping configuration ${name}...\n"
	@docker compose -f $(DOCKER_COMPOSE_YML) --env-file $(ENVFILE) down

re: down
	@printf "Rebuild configuration ${name}...\n"
	@bash ./srcs/requirements/wordpress/tools/make_dir.sh
	@$(MAKE) fix_perms
	@docker compose -f $(DOCKER_COMPOSE_YML) --env-file $(ENVFILE) up -d --build

clean: down
	@printf "Cleaning configuration ${name}...\n"
	@docker system prune -a
	@sudo rm -rf ~/data/wordpress/*
	@sudo rm -rf ~/data/mariadb/*

fclean:
	@printf "Total clean of all configurations docker\n"
	@docker stop $$(docker ps -qa)
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force
	@sudo rm -rf ~/data/wordpress/*
	@sudo rm -rf ~/data/mariadb/*

.PHONY: all build down re clean fclean fix_perms
