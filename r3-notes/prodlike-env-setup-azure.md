## Naming Conventions

```
$client=                                        # client identifier
$environment={demo,uat,prod}                    # environment type
$group=$client-r3-nonprod                       # resource group name
$zone={1,2,3}                                   # Azure availability zone
$web-server-name=$client-$environment-web-$zone   
$app-server-name=$client-$environment-app-$zone
$database-server-name=$client-environment-db
$web-nsg-name=$client-r3-nonprod-web-nsg
$app-nsg-name=$client-r3-nonprod-app-nsg
$admin-app-nsg-name=$client-r3-nonprod-admin-app-nsg

```

## Create resource group 

```
az group create -l canadacentral -n gnl-r3-nonprod
```

## Create NSGs

```
# for web server
az network nsg create -g gnl-r3-nonprod -n gnl-r3-nonprod-web-nsg

# allow ssh from ansible-controller machine only
az network nsg rule create -g gnl-r3-nonprod -n "Allow-ssh" --nsg-name gnl-r3-nonprod-web-nsg --priority 1000 --source-address-prefix \* --source-port-range \* --destination-address-prefix \* --destination-port-range 22 --access Allow --protocol TCP

# allow https from Cloudflare IP addresses only (the IP addresses are not likely to change but it's ideal to confirm first before setting up this rule)
az network nsg rule create -g gnl-r3-nonprod -n "Allow-https" --nsg-name gnl-r3-nonprod-web-nsg --priority 1000 --source-address-prefix 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22 2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32 2405:8100::/32 2a06:98c0::/29 2c0f:f248::/32 --source-port-range \* --destination-address-prefix \* --destination-port-range 443 --access Allow --protocol TCP

# allow incoming requests from zabbix server on port 10050
az network nsg rule create -g gnl-r3-nonprod -n "Allow-zabbix" --nsg-name gnl-r3-nonprod-web-nsg --priority 1010 --source-address-prefix zabbix-server-ip --source-port-range \* --destination-address-prefix \* --destination-port-range 10050 --access Allow --protocol TCP

# for app servers
az network nsg create -g gnl-r3-nonprod -n gnl-r3-nonprod-app-nsg
az network nsg rule create -g gnl-r3-nonprod -n "Allow-web-server" --nsg-name gnl-r3-nonprod-app-nsg --priority 1000 --source-address-prefix caddy-ip --source-port-range \* --destination-address-prefix \* --destination-port-range 3000 --access Allow --protocol TCP
az network nsg rule create -g gnl-r3-nonprod -n "Allow-ssh" --nsg-name gnl-r3-nonprod-app-nsg --priority 1010 --source-address-prefix ansible-controller-ip --source-port-range \* --destination-address-prefix \* --destination-port-range 22 --access Allow --protocol TCP
az network nsg rule create -g gnl-r3-nonprod -n "Allow-zabbix" --nsg-name gnl-r3-nonprod-app-nsg --priority 1020 --source-address-prefix zabbix-server-ip --source-port-range \* --destination-address-prefix \* --destination-port-range 10050 --access Allow --protocol TCP

# for admin app server
az network nsg create -g gnl-r3-nonprod -n gnl-r3-nonprod-admin-app-nsg
az network nsg rule create -g gnl-r3-nonprod -n "Allow-web-server" --nsg-name gnl-r3-nonprod-admin-app-nsg --priority 1000 --source-address-prefix caddy-ip --source-port-range \* --destination-address-prefix \* --destination-port-range 3000 --access Allow --protocol TCP
az network nsg rule create -g gnl-r3-nonprod -n "Allow-ssh" --nsg-name gnl-r3-nonprod-admin-app-nsg --priority 1010 --source-address-prefix ansible-controller-ip --source-port-range \* --destination-address-prefix \* --destination-port-range 22 --access Allow --protocol TCP
az network nsg rule create -g gnl-r3-nonprod -n "Allow-zabbix" --nsg-name gnl-r3-nonprod-admin-app-nsg --priority 1020 --source-address-prefix zabbix-server-ip --source-port-range \* --destination-address-prefix \* --destination-port-range 10050 --access Allow --protocol TCP
```

## Create servers in corresponding NSGs in 2 separate zones

```
# using mouse' script

# caddy servers (1 server per zone)
./new-vm -size caddy -zone 1 -name gnl-uat-caddy-1 -nsg gnl-r3-nonprod-web-nsg -group gnl-r3-nonprod
./new-vm -size caddy -zone 2 -name gnl-uat-caddy-2 -nsg gnl-r3-nonprod-web-nsg -group gnl-r3-nonprod

# app servers (2 servers, 1 per zone)
./new-vm -size web8 -zone 1 -name gnl-uat-app-A-1 -nsg gnl-r3-nonprod-app-nsg -group gnl-r3-nonprod
./new-vm -size web8 -zone 1 -name gnl-uat-app-A-2 -nsg gnl-r3-nonprod-app-nsg -group gnl-r3-nonprod


# admin servers (only 1 server)
./new-vm -size caddy -zone 1 -name gnl-uat-admin-app-1 -nsg gnl-r3-nonprod-admin-app-nsg -group gnl-r3-nonprod

# database server (zone-redundant HA postgres flexible server)
az postgres flexible-server create -g gnl-r3-nonprod -n gnl-uat-db -l canadacentral -u postgres --p some-pass --sku-name Standard_D2ds_v4 --tier GeneralPurpose --public-access Disabled --storage-size 64 --high-availability ZoneRedundant -y
```

## Database Setup

```
# add firewall rules for app servers
az postgres flexible-server firewall-rule create -g gnl-r3-nonprod --server-name gnl-uat-db -n Allow-app-A-1 --start-ip-address app-A-1-ip
az postgres flexible-server firewall-rule create -g gnl-r3-nonprod --server-name gnl-uat-db -n Allow-app-A-2 --start-ip-address app-A-2-ip
az postgres flexible-server firewall-rule create -g gnl-r3-nonprod --server-name gnl-uat-db -n Allow-admin-app --start-ip-address admin-app-ip

# allow plpgsql extension
az postgres flexible-server parameter set -g gnl-r3-nonprod --server-name gnl-uat-db --subscription 2638b066-e087-4170-9a37-5d9763d78bce --name azure.extensions --value plpgsql
```

## Caddy Server Setup

### Install go
```
sudo apt update
sudo apt upgrade
wget https://go.dev/dl/go1.21.1.linux-amd64.tar.gz          # or most recent stable version from https://go.dev/
sudo tar -C /usr/local/ -xzf go1.21.1.linux-amd64.tar.gz
cd /usr/local/
ls          # see that go has been extracted
echo $PATH
sudo nano $HOME/.profile
export PATH=$PATH:/usr/local/go/bin     # add to .profile
source $HOME/.profile
cat $HOME/.profile      # verify that file saved correctly
go version      # test that go commands can be run from terminal
```

### Install xcaddy and add to PATH

```
wget https://github.com/caddyserver/xcaddy/releases/download/v0.3.5/xcaddy_0.3.5_linux_amd64.tar.gz     or latest stable version from https://github.com/caddyserver/xcaddy/releases
sudo tar -C /usr/local/bin -xzf xcaddy_0.3.5_linux_amd64.tar.gz
```

### Install caddy with cloudflare dns module

```
xcaddy build --with github.com/caddy-dns/cloudflare
```

### running custom caddy binaries while keeping support files from the caddy package

This procedure allows users to take advantage of the default configuration, systemd service files and bash-completion from the official package.

```
# Install caddy package for linux distribution in use
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy

# with custom caddy binary in current directory
sudo dpkg-divert --divert /usr/bin/caddy.default --rename /usr/bin/caddy
sudo mv ./caddy /usr/bin/caddy.custom
sudo update-alternatives --install /usr/bin/caddy caddy /usr/bin/caddy.default 10
sudo update-alternatives --install /usr/bin/caddy caddy /usr/bin/caddy.custom 50
```

`dpkg-divert` will move `/usr/bin/caddy` binary to `/usr/bin/caddy.default` and put a diversion in place in case any package want to install a file to this location.

`update-alternatives` will create a symlink from the desired caddy binary to `/usr/bin/caddy`.

### Switch between custom (xcaddy install) and default (package install) caddy binaries 

```
update-alternatives --config caddy
```

Follow the on screen information


### Configure Caddy

```
# Globally recognized cloudflare DNS challenge config
{
        acme_dns cloudflare {env.CLOUDFLARE_AUTH_TOKEN}
}

gnluat.citizenone.ca {
    # Set this path to your site's directory.
    # root * /usr/share/caddy

    # Enable the static file server.
    # file_server

    # Another common task is to set up a reverse proxy:
    # reverse_proxy localhost:8080

    reverse_proxy {
        to 20.151.67.213:3000 20.63.114.76:3000

        # configure load balancer policy
        lb_policy cookie {
                fallback round_robin
        }
        lb_retries 2
    }

    # Set up logging

    log {
        # Error logs
        level ERROR
        output file /var/log/caddy/gnl-uat-error.log {
                roll_size 100MiB
                roll_keep 5
                roll_keep_for 720h
        }
    }
}
```


```
caddy reload --config /etc/caddy/Caddyfile
```

### Configure Nginx

- Increase openFD limit
- Increase worker connections to 6144
- Add proxy read timeout setting to vanadium.conf (Included `proxy_read_timeout 3600;` in location block of NGINX config)

## Cloudflare Configuration

* Set SSL to Full or Full (strict)
* Add DNS records
  * A records for app server IP addresses
  * required records for mail server (Mailgun) to enable email delivery
* Create API token for caddy config
* Create Page Rule to cache all assets
* Create page rule to only allow HTTPs
* Create page rule redirect to maintenance page

## App Server Setup

- Install the application per the instructions in the deploy guide, skipping the last step to setup NGINX and get SSL certificates with certbot
- Add the puma settings to `.env` to improve performance (for F8s, `WEB_CONCURRENCY=7, RAILS_MAX_THREADS=2`)

## Create SSH config on ansible controller (TODO)


## Monitoring Setup

* Install Zabbix agent on the just created servers. TODO - outline the steps
* Complete host configuration on zabbix server to enable collection of server metrics by zabbix


## Log Aggregation Setup (TODO)

