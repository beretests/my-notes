#### Steps to Complete

- Ensure the variable `TIMESCALEDB_ENABLED` in the database environment file is set to true.
- Copied the `zabbix-sql-scripts/postgresql` directory from host to container by running 

```
docker container cp /usr/share/zabbix-sql-scripts/postgresql/ zabbix-postgres-server-1:/zabbix-sql-scripts
```

- **Be sure to turn off the zabbix server and nginx containers first to ensure there are no open database connections.** Ran the following commands to ensure `timescaledb` extension was enabled and migrate the database to chunks (not sure yet what that means but it took a really long time because there is already a lot of data in the database)

```
echo "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;" | sudo -u postgres psql zabbix
cat /usr/share/zabbix-sql-scripts/postgresql/timescaledb.sql | sudo -u zabbix psql zabbix
```

#### Useful info 

https://www.zabbix.com/documentation/current/en/manual/appendix/install/timescaledb 