### Steps to setup Azure as identity provider

1. Create enterprise app

```bash
# Get enterprise app display name from user input
read -p "Enter enterpise app display name: " appDisplayName
az ad sp create 
```

2. Get enterprise app ID and store in variable

```bash
appId=$(az ad sp list --filter "displayName eq '$appDisplayName'" | jq '.[].appId')
```

3. Enable single signon for enterprise app via SAML

```bash
az ad sp update --id $appId --set preferredSingleSignOnMode=saml
```

4. Update notification email addresses

```bash
az ad sp update --id $appId --set notificationEmailAddresses="['e@vivvo.com', 'fireteam@vivvo.com']"
```

5. Update reply URLs

```bash
az ad sp update --id $appId --set replyUrls="['https://web.ca']"
```

6. Other possible SAML config

```bash
az ad app update --id <application-id> --set sso.saml.assertionElements=<assertion-elements> sso.saml.attributeName=<attribute-name>
```

7. Get enterprise app servicePrincipalNames and update with identifier or entity ID

```bash
servicePrincipalNames=$(az ad sp list --filter "displayName eq 'CitizenOne R3 Dev'" | jq '.[].servicePrincipalNames')
servicePrincipalNames=$(echo $servicePincipalNames | jq '. += ["12345"]')
echo $servicePrincipalNames
```

8. Create azure AD test users - run `create-azure-ad-users.sh`

9. Get users by id and add to enterprise app - run `add-users-enterprise-app.sh`


### Steps to delete enterprise app and its users

1. Delete users from csv list - run `delete-azure-ad-users.sh`

2. Delete enterprise app

```bash
read -p "Enter enterpise app display name to delete: " appDisplayName
servicePrincipalId=$(az ad sp list --filter "displayName eq '$appDisplayName'" | jq '.[].id')
az ad sp delete --id $servicePrincipalId
```