### Use HTTPS - Commands run

``` bash
# in /etc/zabbix/nginx_ssl.conf

sed -i '5s/zabbix/zabbixmonitor.citizenone.ca/' /etc/zabbix/nginx_ssl.conf
sed -i '19s/ssl.crt/fullchain2.pem/' /etc/zabbix/nginx_ssl.conf
sed -i '20s/ssl.key/privkey2.pem/' /etc/zabbix/nginx_ssl.conf
sed -i '21d' /etc/zabbix/nginx_ssl.conf
```

### Redirect HTTP to HTTPS

``` bash
# in /etc/zabbix/nginx.conf

sed -i '6,89d' /etc/zabbix/nginx.conf
sed -i '5 a\    return 301 https://$host$request_uri;' /etc/zabbix/nginx.conf
sed -i 's/zabbix/_/' /etc/zabbix/nginx.conf
```

#### Issues
Copied files from letsencrypt archive to `zbx_data_directory`

```
cp -r /etc/letsencrypt/archive/zabbixmonitor.citizenone.ca/* zbx_env/etc/ssl/nginx
```

Encountered error on restarting nginx:

```
2024/03/16 15:37:48 [emerg] 5492#5492: cannot load certificate key "/etc/ssl/nginx/privkey2.pem": BIO_new_file() failed (SSL: error:8000000D:system library::Permission denied:calling f
open(/etc/ssl/nginx/privkey2.pem, r) error:10080002:BIO routines::system lib) 
```

Resolved by changing the permissions on the affected private key

```
chmod 644 zbx_env/etc/ssl/nginx/privkey2.pem
```

#### Other Notes

- NGINX upstream configuration files can be found in `etc/zabbix`. 1 for http and another for https and both are symlinked to the files in `/etc/nginx/conf.d/`.
- Running `service nginx restart` will fail with error `2024/03/18 00:54:39 [emerg] 37530#37530: bind() to [::]:8080 failed (98: Address already in use) nginx: [emerg] bind() to [::]:8080 failed (98: Address already in use)`. Workaround is to kill the nginx service running on port 8080 (and/or 8443) by running `fuser -k 8080/tcp`. A new nservice instance will then be spawned with the new config.