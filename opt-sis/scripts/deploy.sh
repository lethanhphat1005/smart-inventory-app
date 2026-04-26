#!/bin/bash
set -euxo pipefail

STACK_NAME='sis'
STACK_FILE='/opt/sis/stacks/docker-stack.yml'

IMAGE_NAME='peterhoward/storix-backend'
IMAGE_TAG="${1:-latest}"
BACKEND_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"
DOCKER_HUB_ENV='/opt/sis/env/docker-hub.env'

if [ ! -f "${DOCKER_HUB_ENV}" ]; then
  echo 'Missing file /opt/sis/env/docker-hub.env'
  exit 1
fi

# shellcheck disable=SC1090
source "${DOCKER_HUB_ENV}"

if [ -z "${DOCKER_HUB_USERNAME:-}" ] || [ -z "${DOCKER_HUB_TOKEN:-}" ]; then
  echo 'Missing DOCKER_HUB_USERNAME or DOCKER_HUB_TOKEN'
  exit 1
fi

echo "${DOCKER_HUB_TOKEN}" | docker login --username "${DOCKER_HUB_USERNAME}" --password-stdin

docker pull "${BACKEND_IMAGE}"

docker stack deploy \
  --with-registry-auth \
  -c "${STACK_FILE}" \
  "${STACK_NAME}"

docker service ls
