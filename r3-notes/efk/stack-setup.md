These installation instructions are for the EFK stack using Docker on Ubuntu 22.04 (Jammy) machine

## Prerequisites
* A server running Ubuntu 22.04 with a minimum of 6GB of RAM.
* A non-root user with sudo privileges.
* Any running firewall allows http and https.
* A Fully Qualified domain name (FQDN) pointing to the server like, `kibana.example.com`.
* Everything is updated. `sudo apt update && sudo apt upgrade`

## Install Docker and Docker Compose

* Add Docker's official GPG key

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
```

* Add the Docker repository

```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

* Ensure system is updated `sudo apt update`
* Install Docker and Docker compose plugin

```
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin

mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

chmod +x ~/.docker/cli-plugins/docker-compose
docker compose version
```

* Add user to docker group `sudo usermod -aG docker ${USER}`

## Create Docker Compose File

* Create new directory for EFK stack `mkdir efk && cd efk`
* Create `docker-compose.yml` file and add the following code (perhaps a template will be ideal for this)

```
services:
  # Deploy using the custom image automatically be created during the build process.
  fluentd:
    build: ./fluentd
    volumes:
      - ./fluentd/conf:/fluentd/etc
    links: # Sends incoming logs to the elasticsearch container.
      - elasticsearch
    depends_on:
      - elasticsearch
    ports: # Exposes the port 24224 on both TCP and UDP protocol for log aggregation
      - 24224:24224
      - 24224:24224/udp

  elasticsearch:
    image: elasticsearch:8.7.1
    ports: # bound to local machine port to receive logs from remote hosts
      - 9200:9200
    environment:
      - discovery.type=single-node # Runs as a single-node
      - xpack.security.enabled=false
    volumes: # Stores elasticsearch data locally on the esdata Docker volume
      - esdata:/usr/share/elasticsearch/data

  kibana:
    image: kibana:8.7.1
    links: # Links kibana service to the elasticsearch container
      - elasticsearch
    depends_on:
      - elasticsearch
    ports:
      - 5601:5601
    environment: # Defined host configuration
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200

# Define the Docker volume named esdata for the Elasticsearch container.
volumes:
  esdata:
```

## Set up Fluentd Build Files

* Create fluentd and configuration directory and switch to fluentd directory `mkdir fluentd/conf -p`
* Create `Dockerfile` and add the following to it

```
# fluentd/Dockerfile
FROM fluent/fluentd:v1.16-debian-1
USER root
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-document", "--version", "5.3.0"]
USER fluent
```

* Switch to `conf` directory, create `fluent.conf` file and add the following

```
# bind fluentd on IP 0.0.0.0
# port 24224
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

# sendlog to the elasticsearch
# the host must match to the elasticsearch
# container service
<match *.**>
  @type copy
  <store>
    @type elasticsearch_dynamic
    hosts elasticsearch:9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    tag_key @log_name
    include_timestamp true
    flush_interval 30s
  </store>
  <store>
    @type stdout
  </store>
</match>
```

## Run the Docker Containers
* Go back to the `efk` directory and start the containers `docker compose up -d`. Confirm that all three containers - efk-fluentd-1, efk-kibana-1, efk-elasticsearch-1 are running without errors (using `docker ps` and `docker logs`). Get the IP address of the elasticsearch container (using `docker inspect`) and confirm it's working (using `curl`)

## Configure Kibana

* Go to Kibana URL in browser, `http://<efk-server-IP>:5601`
* Click `Explore on my own` on Welcome screen to proceed to Kibana dashboard
* Click the 'Stack Management' link to set up the Kibana data view. Select the option `Kibana >> Data Views` from the left sidebar to open the data view page.
* Click the Create data view button to proceed.
* Enter the name of the data view and the index pattern as fluentd-*. Make sure the Timestamp field is set to @timestamp. The source field will be automatically updated. Click the Save data view to Kibana button to finish creating the data view.
* click on the top menu (ellipsis), and click on the Discover option to show the logs monitoring.


## Install NGINX

* Import NGINX's signing key

```
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
| sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
```
* Add the repository for Nginx's stable version.

```
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg arch=amd64] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
| sudo tee /etc/apt/sources.list.d/nginx.list
```

* Update the system repositories `sudo apt update`
* Install NGINX `sudo apt install nginx`
* Verify the installation and start the NGINX server `nginx -v && sudo systemctl start nginx`

## Setup SSL

* Update snapd `sudo snap install core && sudo snap refresh core`
* Install certbot `sudo snap install --classic certbot`
* Create symlink to `/usr/bin` directory `sudo ln -s /snap/bin/certbot /usr/bin/certbot`
* Generate SSL certificate for desired domain, e.g. `kibana.example.com`

```
sudo certbot certonly --nginx --agree-tos --no-eff-email --staple-ocsp --preferred-challenges http -m name@example.com -d kibana.example.com
```

* Generate a Diffie-Hellman group certificate

```
sudo openssl dhparam -dsaparam -out /etc/ssl/certs/dhparam.pem 4096
```

* Check the certbot renewal scheduler service `sudo systemctl list-timers`. `snap.certbot.renew.service` should be listed as one of the services to be run
* Do a dry run of the process to check whether the SSL renewal is working fine `sudo certbot renew --dry-run`

## Configure NGINX

* Create and open the NGINX configuration file for Kibna `sudo nano /etc/nginx/conf.d/kibana.conf` and add the following

```
server {
        listen 80; listen [::]:80;
        server_name kibana.example.com;
        return 301 https://$host$request_uri;
}

server {
        server_name kibana.example.com;
        charset utf-8;

        listen 443 ssl http2;
        listen [::]:443 ssl http2;

        access_log /var/log/nginx/kibana.access.log;
        error_log /var/log/nginx/kibana.error.log;

        ssl_certificate /etc/letsencrypt/live/kibana.example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/kibana.example.com/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/kibana.example.com/chain.pem;
        ssl_session_timeout 1d;
        ssl_session_cache shared:MozSSL:10m;
        ssl_session_tickets off;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

		resolver 8.8.8.8;

        ssl_stapling on;
        ssl_stapling_verify on;
        ssl_dhparam /etc/ssl/certs/dhparam.pem;

        location / {
                proxy_pass http://localhost:5601;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
        }
}
```

* Open the `/etc/nginx/nginx.conf` file and add the following line before the `include /etc/nginx/conf.d/*.conf;` line

```
server_names_hash_bucket_size  64;
```

* Verify the configuration, `nginx -t`. If all is ok, restart the NGINX service.
* Open the `docker-compose.yml` file in efk directory and paste the line `SERVER_PUBLICBASEURL=https://kibana.example.com` in the environments section of the kibana service. It should look like this:

```
    environment: # Defined host configuration
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
      - SERVER_PUBLICBASEURL=https://kibana.example.com
```
* Stop and restart the containers to update the configuration 

```
docker compose down --remove-orphans
docker compose up -d
```

* The Kibana dashboard should be accessible via the URL https://kibana.example.com from anywhere 