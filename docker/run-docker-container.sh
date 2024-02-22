#!/bin/bash

IMAGE=${DOCKER_IMAGE:-lux-web-cache}
CONTAINER=${DOCKER_CONTAINER_NAME:-lux-web-cache}

PORT=${PORT:-8080}

HOST_VCL=${HOST_VCL:-default.vcl}
HOST_CONFIG=${HOST_CONFIG:-docker/.config.json}

VOLUMES="\
-v $(pwd)/${HOST_CONFIG}:/app/config.json \
"
ENVS="\
-e VARNISH_SIZE=${VARNISH_SIZE:-1G} \
-e USE_LOCAL_CONFIG_JSON=yes \
"

set -x

echo "Stopping the running $CONTAINER container (if any)"
running=$(docker inspect -f {{.State.Running}} $CONTAINER 2> /dev/null)
if [ "${running}" = 'true' ]; then
  docker stop $CONTAINER
fi

echo "Removing the existing $CONTAINER container (if any)"
inactive_id=$(docker ps -aq -f status=exited -f status=created -f name=${CONTAINER})
if [ "${inactive_id}" != '' ]; then
  docker rm $CONTAINER
fi

function run_i {
  docker run -it --name $CONTAINER \
    -p ${PORT}:8080 -p 8081:8081 \
    ${ENVS} \
    ${VOLUMES} \
    $IMAGE /bin/bash
}

function run {
  docker run -d --name $CONTAINER \
  -p ${PORT}:8080 -p 8081:8081 \
  ${ENVS} \
  ${VOLUMES} \
  $IMAGE
}

if [ "${1}" = "i" ]; then
  run_i
else
  run
fi
