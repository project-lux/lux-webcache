#!/bin/sh

# Run from the root directory, e.g.
# $ ./docker/build-docker-image.sh

IMAGE_NAME=${IMAGE_NAME:-lux-web-cache}

export DOCKER_BUILDKIT=1

docker buildx build -t $IMAGE_NAME -f docker/Dockerfile .
