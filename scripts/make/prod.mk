IAM_BASE_DIR := $(shell git rev-parse --show-toplevel)

## prevents collisions of make target names with possible file names
.PHONY: iam-up iam-down iam-start iam-stop iam-status iam-logs iam-config iam-system-prune iam-volumes-prune\
	iam-images-clean

## disables printing the recipe of a make target before executing it
.SILENT: iam-images-clean

## Pull newest images, create and start docker containers
iam-up:
	@if ! test $(shell docker network ls -q --filter name=app-net);\
		then docker network create app-net;\
	fi
	docker compose\
			-f $(IAM_BASE_DIR)/docker-compose.iam.yaml\
			-f $(IAM_BASE_DIR)/docker-compose.iam.prod.yaml\
			--env-file $(IAM_BASE_DIR)/.env.iam\
		pull
	docker compose\
			-f $(IAM_BASE_DIR)/docker-compose.iam.yaml\
			-f $(IAM_BASE_DIR)/docker-compose.iam.prod.yaml\
			--env-file $(IAM_BASE_DIR)/.env.iam\
		up -d

## Stop and remove docker containers
iam-down:
	docker compose\
			-f $(IAM_BASE_DIR)/docker-compose.iam.yaml\
			-f $(IAM_BASE_DIR)/docker-compose.iam.prod.yaml\
			--env-file $(IAM_BASE_DIR)/.env.iam\
		down

## Start docker containers
# Param (optional): SERVICE - Start the specified service only, e.g. `make iam-start SERVICE=keycloak`
iam-start:
	docker compose\
			-f $(IAM_BASE_DIR)/docker-compose.iam.yaml\
			-f $(IAM_BASE_DIR)/docker-compose.iam.prod.yaml\
			--env-file $(IAM_BASE_DIR)/.env.iam\
		start $(SERVICE)

## Stop docker containers
iam-stop:
	docker compose\
			-f $(IAM_BASE_DIR)/docker-compose.iam.yaml\
			-f $(IAM_BASE_DIR)/docker-compose.iam.prod.yaml\
			--env-file $(IAM_BASE_DIR)/.env.iam\
		stop $(SERVICE)

## Show status of containers
# Param (optional): SERVICE - Show status of the specified service only, e.g. `make iam-status SERVICE=keycloak`
iam-status:
	docker compose\
			-f $(IAM_BASE_DIR)/docker-compose.iam.yaml\
			-f $(IAM_BASE_DIR)/docker-compose.iam.prod.yaml\
			--env-file $(IAM_BASE_DIR)/.env.iam\
		ps -a $(SERVICE)

## Show service logs
# Param (optional): SERVICE - Show log of the specified service only, e.g. `make iam-logs SERVICE=keycloak`
iam-logs:
	docker compose\
			-f $(IAM_BASE_DIR)/docker-compose.iam.yaml\
			-f $(IAM_BASE_DIR)/docker-compose.iam.prod.yaml\
			--env-file $(IAM_BASE_DIR)/.env.iam\
		logs -f $(SERVICE)

## Show services configuration
# Param (optional): SERVICE - Show config of the specified service only, e.g. `make iam-config SERVICE=keycloak`
iam-config:
	docker compose\
			-f $(IAM_BASE_DIR)/docker-compose.iam.yaml\
			-f $(IAM_BASE_DIR)/docker-compose.iam.prod.yaml\
			--env-file $(IAM_BASE_DIR)/.env.iam\
		config $(SERVICE)

## Remove unused dangling images, containers, networks, etc. Data volumes will stay untouched!
iam-system-prune:
	docker system prune

## Remove all anonymous local volumes not used by at least one container.
iam-volumes-prune:
	docker volume prune

## Remove all unused (not just dangling) images!
iam-images-clean:
	if test "$(shell docker images -f "reference=identity-and-access-management-*")" -q;\
		then docker rmi $(shell docker images -f "reference=identity-and-access-management-*" -q);\
	fi
