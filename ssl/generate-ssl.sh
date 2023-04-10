#!/bin/bash

# Description: generates SSL certificate for digital ocean
# Usage: generate-ssl.sh
# Reference: https://certbot-dns-digitalocean.readthedocs.io/en/stable/#credentials
# Reference: https://www.digitalocean.com/community/tutorials/how-to-acquire-a-let-s-encrypt-certificate-using-dns-validation-with-certbot-dns-digitalocean-on-ubuntu-20-04

$domain=<your-domain>

# creates SSL certificate
docker container run --rm -it \
    -v /.secrets/certbot/digitalocean.ini:/.secrets/certbot/digitalocean.ini:ro \
    -v ./letsencrypt/:/etc/letsencrypt/ \
    certbot/dns-digitalocean:v2.5.0 certonly \
    --dns-digitalocean \
    --dns-digitalocean-credentials /.secrets/certbot/digitalocean.ini \
    -d "$domain" \
    -d "*.$domain"

