#!/bin/bash

# Description: renews SSL certificate for Digital Ocean DNS
# Usage: renew_cert.sh

docker container run --rm \
    -v /.secrets/certbot/digitalocean.ini:/.secrets/certbot/digitalocean.ini:ro \
    -v ./letsencrypt/:/etc/letsencrypt/ \
    certbot/dns-digitalocean:v2.5.0 renew

