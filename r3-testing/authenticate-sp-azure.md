On the Ansible (or other) server, enter the following:

for Zabbix (in non-prod subscription): 
export AZURE_SUBSCRIPTION_ID="2638b066-e087-4170-9a37-5d9763d78bce"
export AZURE_CLIENT_ID="605c1ea1-19e2-4f36-8642-ec64a665c3f9"
export AZURE_SECRET=OmX8Q~eC0oZj-4VtQsDh6Bc.Nxv3wuaQhLlfYa7d
export AZURE_TENANT="f02178f4-704a-465a-9ad9-a0f01179e0cd"

How to get those values:

###### Subscription and Tenant IDs: 

```
az account show --query '{tenantId:tenantId,subscriptionid:id}'
```

###### Client ID

```
az ad sp list --display-name 'CitizenOne Monitoring' --query '{clientId:[0].appId}'
```
