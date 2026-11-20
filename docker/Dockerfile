# 9.0.4: FROM debian:trixie-slim
FROM varnish:9.0.4

# Since 7.x the official image ends with "USER varnish"; we need root to
# install packages and to run the startup script and nginx.
# varnishd drops its own privileges to the varnish/vcache users.
USER root

RUN mkdir /build /app
WORKDIR /build

# nginx version to install from nginx.org; the build fails if it isn't available.
# The full Debian package version is ${NGINX_VERSION}-${NGINX_PKG_RELEASE},
# e.g. 1.30.7-1~trixie. Override with --build-arg NGINX_VERSION=...
# To list the versions available for Debian trixie (stable branch):
#   curl -s https://nginx.org/packages/debian/pool/nginx/n/nginx/ \
#     | grep -oE 'nginx_[0-9][^"<]*~trixie_amd64\.deb' \
#     | sort -uV | sed -E 's/^nginx_(.*)_amd64\.deb$/\1/'
ARG NGINX_VERSION=1.30.7
ARG NGINX_PKG_RELEASE=1~trixie

# nginx is installed from the official nginx.org "stable" repository
# (Debian's own package lags behind). The apt source and pin files are staged
# in /build and only activated once the signing key has been installed.
COPY docker/nginx-sources.list docker/nginx-apt-preferences /build/

# procps: for "free"
# The nginx.org package ships a port-80 server in conf.d/default.conf;
# it is removed because our server is in sites-enabled/default.
RUN apt-get update && \
  apt-get install -y wget unzip jq procps gnupg && \
  wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf ./aws && \
  rm awscliv2.zip && \
  wget -qO- https://nginx.org/keys/nginx_signing.key | \
    gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg && \
  mv /build/nginx-sources.list /etc/apt/sources.list.d/nginx.list && \
  mv /build/nginx-apt-preferences /etc/apt/preferences.d/99nginx && \
  apt-get update && \
  apt-get install -y "nginx=${NGINX_VERSION}-${NGINX_PKG_RELEASE}" logrotate && \
  echo "Installed nginx $(dpkg-query -W -f='${Version}' nginx)" && \
  rm -f /etc/nginx/conf.d/default.conf && \
  apt-get remove -y wget unzip gnupg && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

COPY src/varnish/default.vcl /etc/varnish
COPY src/varnish/docker-varnish-entrypoint /usr/local/bin/
COPY src/nginx/nginx.conf /etc/nginx/
COPY src/nginx/site-default /etc/nginx/sites-enabled/default
COPY src/nginx/logrotate-nginx /etc/logrotate.d/nginx
COPY docker/import-config-start.sh /app

WORKDIR /app

CMD ["/app/import-config-start.sh"]
