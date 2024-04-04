### Issue

Took a very long time to figure out how to get zabbix agent2 running in docker, and couldn't get the stats to be sent to Zabbix server at zabbixmonitor.citizenone.ca. The previous agent running on host was eventually used to connect to the zabbix server (in active mode). Agent2 container was not successfully created from the docker compose file.

Tried:
Run zabbix agent2 in container with command:

```
docker run --name zabbix-agent2 --network=zabbix_zbx_net_backend --env-file env_vars/.env_agent -p 10050:10050 --restart=unless-stopped -v zbx_env/etc/zabbix/zabbix_agent2.d:/etc/zabbix/zabbix_agent2.d:rw  --link zabbix-zabbix-server-1:zabbix-server --init -d zabbix/zabbix-agent2:ubuntu-6.4-latest 
```

Error:

```
** Preparing Zabbix agent plugin configuration files
**** Configuration file '/etc/zabbix/zabbix_agent2.d/plugins.d/mongodb.conf' does not exist
**** Configuration file '/etc/zabbix/zabbix_agent2.d/plugins.d/postgresql.conf' does not exist
zabbix_agent2 [7]: ERROR: Cannot read configuration: cannot include "/etc/zabbix/zabbix_agent2.d/plugins.d/*.conf": stat /etc/zabbix/zabbix_agent2.d/plugins.d: no such file or directory
```




