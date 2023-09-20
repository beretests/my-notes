### Docker

1. Add template to host, `Docker by Zabbix Agent 2`

2. Add zabbix user to docker group `sudo usermod -aG docker zabbix`

3. Restart zabbix agent `systemctl restart zabbix-agent2`


### NGINX

1. Add template to host, `NGINX by HTTP`

2. Verify that stub status module is available, `nginx -V 2>&1 | grep -o with-http_stub_status_module`

3. Create new configuration file for stub status in `/etc/nginx/conf.d` and add the following:

    ```
    server {
        listen 81;
        server_name localhost;

        access_log off;
        allow 127.0.0.1;
        # deny all;
        allow 159.203.36.31;

        location /nginx_status {
            # Choose your status module

            # freely available with open source NGINX
            stub_status;

            # for open source NGINX < version 1.7.5
            stub_status on;

            # available only with NGINX Plus
            # status;

            # ensures the version information can be retrieved
            server_tokens on;
        }
    }
    ```

4. Verify that macro values in nginx template match values in config file

5. Restart NGINX `systemctl restart nginx`

6. Restart zabbix agent `systemctl restart zabbix-agent2`


### Azure 



### Redis




### 