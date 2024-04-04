- Edit or create a new file /etc/systemd/system/nginx.service.d/override.conf.

```
sudo systemctl edit nginx.service
```

- Append the following:

```
[Service]
LimitNOFILE=65535
```

- Save and close file. Reload disk changes for systemd

```
sudo systemctl daemon-reload
```

- Edit nginx.conf file

```
nano /etc/nginx/nginx.conf
```

- Add the following in main context of config file (outside server and events), then save and close file

```
###############################################################################################################
# Must be less than LimitNOFILE for systemd 
# or /etc/security/limits.conf (non-systemd)
# E.g. if LimitNOFILE is 65535, I set to 30000 (systemd)
# E.g. if "nginx       hard    nofile  30000" in the  /etc/security/limits.conf, I set to 30000 (non-systemd)
###############################################################################################################
worker_rlimit_nofile 30000;
```

- Reload nginx

```
systemctl restart nginx
```

- Test for new FD limits 

```
grep -i 'Max open files' /proc/$(cat /var/run/nginx.pid)/limits
```