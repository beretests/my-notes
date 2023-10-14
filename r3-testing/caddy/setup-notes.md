### Important notes

- caddy needs to be installed with a dns module (likely cloudflare) to enable certificate generation. `xcaddy` is recommended for this type of installation of caddy with different modules
- caddy generates certs from Lets Encrypt or ZeroSSL, CA can be configured but may not be worthwhile. Caddy also handles autorenewal of certificates. Need to determine how exactly it does that to predict possible failure points
- JSON structure config is recommended for caddy API use. Caddyfile can be adapted for API use with simple configs, more complex configs must use JSON structure.
- caddy automatically websockets
- The default data storage location (for certificates and other state information) will be in /var/lib/caddy/.local/share/caddy.

- tags will be useful when creating VMs e.g --tags environment=production

- having the database and app (plus admin) servers in the same vnet may nullify the need for database server firewall rules

- app servers are only accessible for now via ssh from the ansible-controller

#### NGINX config

- certbot saves certs at /etc/letsencrypt/live/gnluat.citizenone.ca/fullchain.pem
- certbot saved key at /etc/letsencrypt/live/gnluat.citizenone.ca/privkey.pem
- This certificate expires on 2023-12-27. These files will be updated when the certificate renews. Certbot has set up a scheduled task to automatically renew this certificate in the background.
- NGINX run error `nginx[18601]: nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Unknown error)` can be resolved by running `sudo fuser -k 80/tcp`

#### Environment Naming convention

- Cloudflare only covers the apex domain and one level of subdomain by default with Universal SSL certicates on the free tier. To avoid `ERR_SSL_VERSION_OR_CIPHER_MISMATCH` errors, there are options which are only available on the Business or Enterprise tier