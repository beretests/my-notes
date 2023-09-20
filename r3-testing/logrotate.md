Culled from [this online article](https://betterstack.com/community/guides/logging/how-to-manage-log-files-with-logrotate-on-ubuntu-20-04/)

### Standard logrotate configuration
Create a standard configuration file for your application logs and place it in the `/etc/logrotate.d/`

```
sudo nano /etc/logrotate.d/<app name>
```

Add following text to file

```
/var/log/<app name>/*.log
{
    daily
    missingok
    rotate 7
    compress
    notifempty
}
```

Test configuration

```
sudo logrotate /etc/logrotate.conf --debug
```

Check last date and time of log file rotation

```
sudo cat /var/lib/logrotate/status | grep 'app name'
```

### System-independent logrotate configuration
This does not run on default system schedule and configuration file must be outside `/etc/logrotate.d/`.
Create `logrotate.conf` in desired directory

```
nano <path-to-dir>/logrotate.conf
```

Populate file with folllowing contents:

```
/<path-to-app-logs>/*.log
{
    monthly
    missingok
    rotate 7
    compress
    notifempty
}
```

Create logrotate state file to store information such as the last rotation date and time, the number of rotations performed, and other relevant details.
Location of state file for default logrotate setup `/var/lib/logrotate/`

```
logrotate <path-to-app-dir>/logrotate.conf --state <path-to-app-dir>/logrotate.state
```

Open the cron jobs configuration file

```
crontab -e
```

Add following line to bottom of file

```
0 * * * * /usr/sbin/logrotate <path-to-app-dir>/logrotate.conf --state /home/<user>/logify/logrotate.state  # app sample path left here intentionally
```
_0 7 * * * - minutes hour day week month_

Save and close the modified file and observe the output below:

```
crontab: installing new crontab
```
