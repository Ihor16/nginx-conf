#!/bin/bash

# Description: renews SSL certificate for digital ocean
# Usage: renew-ssl.sh

docker container run --rm -it \
    -v /.secrets/certbot/digitalocean.ini:/.secrets/certbot/digitalocean.ini:ro \
    -v ./letsencrypt/:/etc/letsencrypt/ \
    certbot/dns-digitalocean:v2.5.0 certonly \
    renew

