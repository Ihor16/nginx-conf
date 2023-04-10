## Nginx Docker Configuration
An Nginx setup for Docker that includes
- Configuration for hosting static webpages
- Generation of SSL wildcard certificate for digital ocean

## How to serve a website
- Clone the repo.
- Start Nginx container.
```bash
docker copose up -d
```
- Put your website into the `./sites/` directory.
- Update `./nginx.conf` file, e.g,
```nginx
server {
    listen <port>;
    server_name <domain.com>;
    root /sites/<website>;
}
```
- Verify that the website is accessible, e.g.,
```bash
curl <domain.com>:<port>
```
- If you have a wildcard domain name, it's possible to server multiple websites from a single nginx container by adding a new `server` context, e.g.,
```nginx
server {
    listen <port>;
    server_name <subdomain>.<domain.com>;
    root /sites/<other-website>;
}
```

## How to enable HTTPS
It's necessary to generate SSL certificates and mount them into the nginx container.
The scripts in this repo use `certbot/dns-digitalocean` container, so if you use another cloud provider, modify the script to use [another](!!! link) container.
- Copy [Digital Ocean API](!!! link) token and put it in `/.secrets/certbot/digitalocean.ini` file, e.g.,
```ini
dns_digitalocean_token = <your-token>
```
- Change that file's permissions, so that it's accessible only by `root`.
```bash
chmod go-rwx /.secrets/certbot/digitalocean.ini
```
- Specify your domain in `./ssl/generate-ssl.sh`, e.g.,
```bash
$domain=domain.com
```
- Run `./ssl/generate-ssl.sh` and follow the instructions.
- Replace `<your-domain>` by your actual domain in `./ssl/nginx.conf`.
- Copy `./ssl/nginx.conf` into the repo's root directory, i.e., replace `./nginx.conf` file by `./ssl/nginx.conf`.
- Add a cronjob to renew the certificate, e.g.,
```bash
# open a crontab editor
crontab -e

# add an entry to daily check whether the certificate should be renewed and renew it
@daily ./<path-to-the-repo>/ssl/renew-ssl.sh
```
- Reload the container
```bash
docker compose down && docker compose up -d
```
- Verify that the website is accessible over HTTPS, e.g.,
```bash
curl https://<domain.com>:<port>
```
