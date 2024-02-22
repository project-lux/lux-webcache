#!/bin/sh

# For local development.
# Replace configuration and reload Varnish cache server.

CONTAINER=${CONTAINER:-lux-varnish}
VCL=${VCL:-default.vcl}

docker cp default.vcl ${CONTAINER}/etc/varnish/default.vcl
docker exec ${CONTAINER} varnishreload
