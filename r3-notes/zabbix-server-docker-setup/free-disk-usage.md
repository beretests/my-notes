```bash
sudo apt-get autoremove
sudo du -sh /var/cache/apt 
sudo apt-get clean
sudo journalctl --disk-usage
sudo journalctl --vacuum-time=30d

docker exec -it zabbix-postgres-server-1 /bin/sh
/ # psql -U postgres -d zabbix
SELECT pg_size_pretty( pg_database_size('zabbix') );
SELECT pg_size_pretty( pg_total_relation_size('history') );
DELETE FROM history WHERE to_timestamp(clock) < NOW() - INTERVAL '30 days';
VACUUM (FULL, ANALYZE) history;

# enable compression
cat zabbix-sql-scripts/postgresql/timescaledb.sql |  psql -U zabbix -d zabbix

# for the following error
ERROR:  table "trends" is already partitioned
DETAIL:  It is not possible to turn tables that use inheritance into hypertables.
CONTEXT:  SQL statement "SELECT create_hypertable('trends', 'clock', chunk_time_interval => 2592000, migrate_data => true)"
PL/pgSQL function inline_code_block line 64 at PERFORM

# run the following commands to remove inheritance
SELECT inhrelid::regclass AS child, inhparent::regclass AS parent
FROM pg_inherits
WHERE inhparent = 'trends'::regclass;

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT inhrelid::regclass AS child FROM pg_inherits WHERE inhparent = 'trends_uint'::regclass) LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || r.child;
    END LOOP;
END;
$$;

# validate timescaledn zabbix compression https://www.zabbix.com/forum/zabbix-cookbook/468184-how-to-validate-your-timescaledb-zabbix-compression
SELECT pg_size_pretty( pg_database_size('zabbix') );

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_catalog = 'zabbix'
AND table_schema NOT LIKE 'pg_%'
AND table_schema != 'zabbix'
ORDER BY table_schema, table_name;

SELECT * FROM timescaledb_information.jobs
WHERE proc_name='policy_compression';
```