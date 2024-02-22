# LUX Web Cache

This application caches web responses from the middle tier. It is not a necessary component of the LUX system -- the frontend can access the middle tier directly if thus set up -- but helps with mitigating performance bottlenecks of the backend database.

It consists of a [Varnish Cache](https://varnish-cache.org/) instance and an [nginx](https://github.com/nginx/nginx) web server running in a docker container. Unconventionally, the nginx server stands between the Varnish cache and the middle tier in order to deal with the limitation of open source Varnish not being able to have multiple IP addresses as the origin (or target, depending on the perspective).

## Bulilding and Running a Docker Container

- See [build-docker-image.sh](./docker/build-docker-image.sh) for an example of building a Docker image.
  - [src/](./src) directory contains configuration files for Varnish and nginx that gets copied into the docker image

- See [run-docker-container.sh](./docker/run-docker-container.sh) for an example of running a container. 

## Required Environment Variables for Running

See [config.json.template](./dockers/config.json.template) for the list of environment variables that must be set before running the container. For local development, you should copy config.json.template to .config.json, fill in the values, and feed that file to the container following the run-docker-container.sh example. 

- BACKEND_HOST - middle tier server that nginx should forward requests except for `/cms/*` to - e.g. https://lux-middle.example.org 
- CMS_HOST - CMS server that nginx should forward requests for `/cms/*` to -  e.g. https://lux-cms.example.org 
- NO_CACHING - if "true", Varnish won't cache any responses regardless of other settings.
- BERESP_TTL - Varnish "[time to live](https://docs.varnish-software.com/tutorials/object-lifetime/)" (beresp.ttl) - e.g. "100ms", "10s", "30m", "1h", "2w", "1y"
- BERESP_GRACE - Varnish "grace period" (beresp.grace)
- BERESP_KEEP - Varnish "keep duration" (beresp.keep)
- VARNISH_SIZE - memory allocated for Varnish cache - e.g. "384M", "25G"
