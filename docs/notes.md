# Nginx config notes
Based on [NGINX Fundamentals](https://www.udemy.com/course/nginx-fundamentals/) course.


## Intro
- `nginx -T` | gets current configurations
- `nginx -V` | gets current version and installed modules


## Configuration
- `key value` | directive
- `key {}` | context
- `events {}` | has to be present
- `include mime.types;` | includes header types for common file types
- `server_name *.name;` | matches subdomains, this directive is used in the `server` context
- `return 200 "message";` | prints message on opening a page
- `location /name {}` | matches page names beginning with `name`, e.g., `site.com/name`, `site.com/naming`, or `site.com/name/more`
- `location = /name {}` | matches exactly the page with `name`, e.g., only `site.com/name`
- `location ~ /name[0-9] {}` | matches regular expression, e.g., `site.com/name1`
- `location ~* /name[0-9] {}` | matches case-insensitive regular expression, e.g., `site.com/Name1`
- `location ^~ /Name1 {}` | same as prefix, but prioritized higher than regex

Location priorities:
1. exact match
2. priority prefix
3. regex
    - if case insensitive and case sensitive both match, uses one that occurs first
4. prefix

- `if ( $arg_apikey != 1 ) {}` | checks for `apikey` parameter, e.g., `name.com/?apikey=1`
- `set $var 1;` | creates a variable `var` with its value set to `1`
- `if ( $date_local ~ "Saturday|Sunday" ) {}` | checks if the local date's day is a weekend
- `location = /logo { return 307 /path/image.png }` | redirects request for `/logo` to return an image in `/path/image.png`, e.g., `name.com/logo` would return an image
- `rewrite /logo /path/image.png;` | redirects requests for `/logo` to return the file in `/path/image.png`, but keeps the user-entered path in the browser
- `rewrite /logo /path/image.png last;` | does not make further rewrites to the `/path/image.png` path
- Prints message if the `$uri` is not found
```nginx
try_files $uri /not_found;

location /not_found {
    return 404 "sorry, file could not be found";
}
```
- `docker container inspect --format '{{.LogPath}}' nginx` | finds path to container logs
- `sudo sh -c 'echo "" > $(docker container inspect --format '{{.LogPath}}' nginx)'` | clears logs of `nginx` container, can't track logs in real-time after cleaning
- Redirects logs for `/secure` path to a `secure.access.log` file
```nginx
location /secure {
    access_log /var/log/nginx/secure.access.log;
    return 200 "Welcome to secure area.";
}
```
e.g., `name.com/secure` request logs will be saved in `secure.access.log` file
- Disables logs for `/secure` path
```nginx
location /secure {
    access_log off;
    return 200 "Welcome to secure area.";
}
```
e.g., `name.com/secure` request will not be logged
- `index index.php index.html;` | changes default file, e.g., `name.com` would serve `index.php`, and if it's not found, would serve `index.html`
- Passes request for file `*.php` to PHP service running as a docker container called `php`
```nginx
# fastcgi_params needs to include
# fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
location ~\.php$ {
    include fastcgi_params;
    fastcgi_pass php:9000;
}
```
- `nproc` | gets number of CPU cores
- `lscpu` | describes the processor
- `worker_processes auto;` | creates num of workers based on the num of CPUs
- `ulimit -n` | shows how many files can be opened at once per CPU core
- `events { worker_connections 1024; }` | enables 1024 simultaneous connections per CPU core
- Skips buffering of static files and optimizes size of each packet
```nginx
sendfile on;
tcp_nopush on;
```
- `load_module modules/ngx_http_image_filter_module.so;` | loads a module located in `/etc/nginx/`


## Performance
- `location = /path { add_header my_header "text"; }` | for `/path` request, adds a header `my_header` with value `"text"`
- Tells client to cache the response for 1 hour for .jpg and .png requests
```nginx
location ~* \.(jpg|png)$ {
    access_log off;
    add_header Cache-Control public;
    add_header Pragma public;
    add_header Vary Accept-Encoding;
    expires 1h;
}
```
- Adds gzip compression to request for .css and .js files; the `add_header Vary Accept-Encoding` must be present
```nginx
gzip on;
gzip_comp_level 3;

gzip_types text/css;
gzip_types text/javascript;
```
- `curl -I -H "Accept-Encoding: gzip" ihor16.com/cover.css` | sends a request indicating that it can accept `gzip` encoding
- `ab -n 100 -c 10 ihor16.com/info.php` | generates `10` connections at a time `10` times, so `100` requests overall, to `ihor16.com/info.php`
- Enables microcache and cache bypass flag
```nginx
http {

    include mime.types;

    # Configuring microcache
    fastcgi_cache_path /tmp/nginx_cache levels=1:2 keys_zone=ZONE_1:100m inactive=60m;
    fastcgi_cache_key "$scheme$request_method$host$request_uri";
    add_header X-Cache $upstream_cache_status;

    server {

        listen 80;
        server_name ihor16.com;

        root /sites/bootstrap/;

        # Caching by default
        set $no_cache 0;

        # Checking for cache bypass flag
        if ( $arg_skipcache = 1 ) {
            set $no_cache 1;
        }

        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_pass php:9000;

            # Enabling cache
            fastcgi_cache ZONE_1;
            fastcgi_cache_valid 200 60m;
            fastcgi_cache_bypass $no_cache;
            fastcgi_no_cache $no_cache;
        }

    }

}
```
- `curl -I ihor16.com/info.php?skipcache=1` | sends cache bypass flag and checks the response header
- `openssl req -x509 -days 10 -nodes -newkey rsa:2048 -keyout ./self.key -out ./self.crt` | creates a self-signed ssl certificate in current directory
- `curl -Ik https://ihor16.com/` | sends request to https that has a self-signed certificate
- Enables HTTP 2.0 and SSL
```nginx
server {
    listen 443 ssl http2;
    ssl_certificate /etc/nginx/ssl/self.crt;
    ssl_certificate_key /etc/nginx/ssl/self.key;
}
```
- `nghttp2-client` | need this to benchmark the response timings
- `nghttp -nys https://ihor16.com/index.html` | shows timings of received responses only the response for the specified file, i.e., `index.html`
- `nghttp -nysa https://ihor16.com/index.html` | shows timings of received responses for the specified file and it's linked assets, e.g., `index.html` along with `style.css`
- Pushes additional data to a client as a part of response
```nginx
location = /index.html {
    # resources that will be pushed together with index.html
    http2_push /cover.css;
    http2_push /assets/dist/css/bootstrap.min.css;
}
```


## Security
- Redirects http request to https
```nginx
server {
    listen 80;
    server_name _;
    return 301 https://$host$request_uri;
}
```
- `openssl dhparam -out ./dhparam.pem 2048` | generates DH parameter in current directory, its size, i.e., `2048`, must correspond to the size of the ssl key
- Enables TLS
```nginx
# Enabling TLS
ssl_protocols TLSv1.3 TLSv1.2;

# Optimizing cipher suits
ssl_prefer_server_ciphers on;
# https://syslink.pl/cipherlist/
ssl_ciphers EECDH+AESGCM:EDH+AESGCM;

# Enabling DH params
ssl_dhparam /etc/nginx/ssl/dhparam.pem;
```
- `siege` | need this to perform load testing
- `siege -v -r 2 -c 5 https://ihor16.com/img.png` | sends `2` requests per user with `5` users, so `10` requests overall, to `https://ihor16.com/img.png`
- `vi $HOME/.siege/siege.conf` | need to disable `json_output = true` to see the verbose output
- `htpasswd -c ./.htpasswd user1` | creates a password for `user1` and stores it in `./.htpasswd` file
- Adds basic authentication to `name.com/van.jpg` request
```nginx
location = /van.jpg {
    auth_basic "";
    auth_basic_user_file /etc/nginx/passwd/.htpasswd;
    try_files $uri $uri/ =404;
}
```
- `server_tokens off;` | removes nginx version from the response header


## Reverse Proxy
- Redirects traffic to PHP server listening on port `9999`
```nginx
location /php {
    proxy_pass "http://php-server:9999/";
}
```
- Redirects traffic to another website
```nginx
location /org {
    proxy_pass "http://nginx.org/";
}
```
- `echo "Request path: " . $_SERVER["REQUEST_URI"];` | prints request path on PHP server
- `add_header proxied nginx;` | adds a custom header `proxied: nginx` to the client
- `var_dump(getallheaders());` | prints all headers received on PHP server
- `proxy_set_header proxied nginx;` | adds a custom header `proxied: nginx` to the server
