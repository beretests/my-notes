## Variable Declaration

```
$client=                                        # client identifier
$environment={demo,uat,prod}                    # environment type
$no={1, 2,...}                                  # used to denote multiples of particular resource
$avail={A,B}                                    # Portage blue green availability zones
$group=gnl-r3-nonprod                           # resource group name
$zone={1,2,3}                                   # Azure availability zone
$web-server-name=$client-$environment-web-$no   
$app-server-name=$client-$environment-app-$avail-$no


```

## Create resource group 

```
az group create -l canadacentral -n gnl-r3-nonprod
```

## Create NSGs

```
# for caddy (or other web server)
az network nsg create -g gnl-r3-nonprod -n gnl-r3-nonprod-web-nsg
az network nsg rule create -g gnl-r3-nonprod -n "Allow-ssh-http-https" --nsg-name gnl-r3-nonprod-web-nsg --priority 1000 --source-address-prefix \* --source-port-range \* --destination-address-prefix \* --destination-port-range 22 80 443 --access Allow --protocol TCP
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

# app servers (2 servers per zone)
./new-vm -size web8 -zone 1 -name gnl-uat-app-A-1 -nsg gnl-r3-nonprod-app-nsg -group gnl-r3-nonprod
./new-vm -size web8 -zone 1 -name gnl-uat-app-A-2 -nsg gnl-r3-nonprod-app-nsg -group gnl-r3-nonprod
./new-vm -size web8 -zone 2 -name gnl-uat-app-B-1 -nsg gnl-r3-nonprod-app-nsg -group gnl-r3-nonprod
./new-vm -size web8 -zone 2 -name gnl-uat-app-B-2 -nsg gnl-r3-nonprod-app-nsg -group gnl-r3-nonprod

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
az postgres flexible-server firewall-rule create -g gnl-r3-nonprod --server-name gnl-uat-db -n Allow-app-B-1 --start-ip-address app-B-1-ip
az postgres flexible-server firewall-rule create -g gnl-r3-nonprod --server-name gnl-uat-db -n Allow-app-B-2 --start-ip-address app-B-2-ip 
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

## App Server Setup

- Install the application per the instructions in the deploy guide, skipping the last step to setup NGINX
- Add the puma settings to `.env` to improve performance (for F8s, `WEB_CONCURRENCY=7, RAILS_MAX_THREADS=2`)

## Create SSH config on ansible controller (TODO)

## Monitoring Setup

* Install Zabbix agent on all app servers - except database server
* Complete host configuration on zabbix server to enable collection of server metrics by zabbix

## Log Aggregation Setup (TODO)

