#!/usr/bin/env bash

# initial command for the certs:
# sudo docker run -it --rm --name certbot-cf  -v "/volume1/docker/certbot:/etc/letsencrypt"  -v "/volume1/docker/certbot:/var/lib/letsencrypt"  -v "/volume1/docker/certbot:/var/log"  -v "/volume1/docker/certbot:/certs"  certbot/dns-cloudflare certonly --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini --dns-cloudflare-propagation-seconds 30 -d example.com -d sub.example.com

docker run --rm --name certbot-cf \
 -v "/volume1/docker/certbot:/etc/letsencrypt" \
 -v "/volume1/docker/certbot:/var/lib/letsencrypt" \
 -v "/volume1/docker/certbot:/var/log" \
 -v "/volume1/docker/certbot:/certs" \
 certbot/dns-cloudflare renew --noninteractive --quiet