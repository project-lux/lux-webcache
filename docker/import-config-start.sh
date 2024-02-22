#!/bin/bash
# Container runtime configuration script
# Gets secrets config file from S3 and uses Deco to substitute parameter values, then executes the supplied arguments as a command
# This script expects S3URL env variable with the full S3 path to the encrypted config file

if [ "${USE_LOCAL_CONFIG_JSON}" != "yes" ]; then
  if [ -n "$S3URL" ]; then
    echo "Getting config file from S3 (${S3URL}) ..."
    aws --version
    if [[ $? -ne 0 ]]; then
      echo "ERROR: aws-cli not found!"
      exit 1
    fi
    aws --region us-east-1 s3 cp ${S3URL}/config.encrypted ./config.encrypted
    aws --region us-east-1 kms decrypt --ciphertext-blob fileb://config.encrypted --output text --query Plaintext | base64 -d > config.json
  else
    echo "ERROR: S3URL variable not set!"
    exit 1
  fi
else
  echo "Using local config.json"
fi

# The $ before the single quoted string makes it work in bash
# to escape the single quotes around (.value).
# Values needs to be quoted because passwords may contain special
# characters.
cat config.json| jq -r $'.[] | "export \(.key)=\'\(.value)\'"' > ./env

if [ "${USE_LOCAL_CONFIG_JSON}" != "yes" ]; then
  rm -f config.json config.encrypted
fi

cat ./env

. ./env

export NAMESERVER=`cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}' | tr '\n' ' '`

sed -i 's@_BACKEND_HOST_@'"$BACKEND_HOST"'@' /etc/nginx/sites-enabled/default
sed -i 's@_CMS_HOST_@'"$CMS_HOST"'@' /etc/nginx/sites-enabled/default
sed -i 's@_NAMESERVER_@'"$NAMESERVER"'@' /etc/nginx/sites-enabled/default

echo "free:"
free
echo "df:"
df -h
echo "/app:"
ls -lrt /app

echo "BACKEND_HOST: ${BACKEND_HOST}"
echo "CMS_HOST: ${CMS_HOST}"
echo "NO_CACHING: ${NO_CACHING}"
echo "BERESP_TTL: ${BERESP_TTL}"
echo "BERESP_GRACE: ${BERESP_GRACE}"
echo "BERESP_KEEP: ${BERESP_KEEP}"
echo "VARNISH_SIZE: ${VARNISH_SIZE}"
echo "nameserver: ${NAMESERVER}"
nginx -v

echo "Running NginX..."
nginx &

echo "Running Varnish..."
/usr/local/bin/docker-varnish-entrypoint $*
echo "Varnish stopped with ${?}"
