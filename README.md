## Nginx Docker Configuration
A Docker-Nginx setup that allows to
- Host websites over HTTP
- Generate a wildcard Letsencrypt SSL certificate to serve the websites over HTTPS

## Serving a Website
- Update `.env` file with your information.
- Copy your website into the `./sites/` directory.
- Copy the nginx basic template into the repo's root directory.
```bash
cp ./configs/base/nginx.template.conf .
```
- Update the root directive in the template file.
```nginx
root /sites/<website-directory-name>;
```
- Generate nginx config by filling in the template file with variables from `.env` and start the nginx container using this config.
```bash
./run.sh
```
- Verify that the website is accessible.
```bash
curl http://<domain>
```

## Serving Multiple Websites
It's possible to server multiple websites from a single nginx container by using a wildcard domain.
- Copy your other website into the `./sites/` directory.
- Add a new `server` context to the template file.
```nginx
server {
    listen <port>;
    server_name <sub>.${DOMAIN};
    root /sites/<other-website-directory-name>;
}
```
- Regenerate the nginx config and restart the docker compose.
```bash
./run.sh
```
- Verify that the website is accessible.
```bash
curl http://<sub>.<domain>
```

## Enabling HTTPS
To enable HTTPS, it's necessary to generate an SSL certificate and mount it into the nginx container.
This repo's scripts use `certbot/dns-digitalocean` [container](https://certbot-dns-digitalocean.readthedocs.io/en/stable/) to generate a wildcard certificate for a domain, so if you use another cloud provider, modify these scripts to use [another](https://eff-certbot.readthedocs.io/en/stable/using.html#dns-plugins) container:
- `./configs/ssl/create_cert.sh`
- `./configs/ssl/renew_cert.sh`

- Update `.env` file with your information.
- Put your [Digital Ocean API](https://cloud.digitalocean.com/settings/api/tokens) token into `/.secrets/certbot/digitalocean.ini` file.
```ini
dns_digitalocean_token = <token>
```
- Change that file's permissions, so that it's accessible only by `root`.
```bash
chmod go-rwx /.secrets/certbot/digitalocean.ini
```
- Run `./ssl/generate-ssl.sh` and follow the instructions.
- Copy the nginx SSL template into the repo's root directory.
```bash
cp ./configs/ssl/nginx.template.conf .
```
- Regenerate the nginx config and restart the docker compose.
```bash
./run.sh
```
- Verify that the website is accessible over HTTPS.
```bash
curl https://<domain>
```

## Renewing SSL Certificate
Letsencrypt certificates expire in [90 days](https://letsencrypt.org/2015/11/09/why-90-days.html), so it's necessary to renew them.
One possible approach to automate the renewal is to add a cronjob to daily check if the certificate is due to renewal and renew it.

- Add a cronjob to renew the certificate.
```bash
# open a crontab editor
crontab -e

# add an entry to daily check whether the certificate should be renewed and renew it
@daily ./<path-to-the-repo>/ssl/renew-ssl.sh
```

