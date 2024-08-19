# 6.0.10: FROM debian:bullseye-slim
FROM varnish:6.0.13

RUN mkdir /build /app
WORKDIR /build

# procps: for "free"
RUN apt-get update && \
  apt-get install -y wget unzip jq procps gnupg && \
  wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -O "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf ./aws && \
  rm awscliv2.zip

COPY docker/nginx-sources.list /etc/apt/sources.list

RUN wget https://nginx.org/keys/nginx_signing.key && \
  apt-key add ./nginx_signing.key && \
  apt-get update && \
  apt-get install -y nginx && \
  apt-get remove -y wget unzip gnupg && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

# ENV PKG_CONFIG_PATH /usr/lib/x86_64-linux-gnu/pkgconfig

COPY src/varnish/default.vcl /etc/varnish
COPY src/varnish/docker-varnish-entrypoint /usr/local/bin/
COPY src/nginx/nginx.conf /etc/nginx/
COPY src/nginx/site-default /etc/nginx/sites-enabled/default
COPY docker/import-config-start.sh /app

WORKDIR /app

CMD ["/app/import-config-start.sh"]
