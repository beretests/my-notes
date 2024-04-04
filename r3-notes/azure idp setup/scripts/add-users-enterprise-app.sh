#!/bin/bash

# Replace with your Azure AD domain
azureADDomain="vivvoappstudios.onmicrosoft.com"

# Check if the user is already logged in
if [ -z "$(az account show --query user -o tsv)" ]; then
   # If not logged in, prompt for admin credentials
   read -p "Enter Azure AD admin username: " adminUsername
   read -s -p "Enter Azure AD admin password: " adminPassword
   echo
   # Log in to Azure AD
   az login -u $adminUsername -p $adminPassword --service-principal --tenant $azureADDomain
fi

# Get service principal and app role IDs
servicePrincipalId=$(az ad sp list --filter "displayName eq '$appDisplayName'" | jq '.[].id')
appRoleId=$(az ad sp list --filter "displayName eq '$appDisplayName'" | jq '.[].appRoles[0].id')

# Replace with your CSV file path
csvFilePath="/path/to/your/file.csv"

# Loop through CSV file and create users
while IFS=, read -r displayName givenName surname userPrincipalName password; do
    # Get user ID
    userId=$(az ad user list --filter "userPrincipalName eq 'r3-test@vivvoappstudios.onmicrosoft.com'" | jq '.[].id')

    # Add user to the enterprise app
    az rest --method post --uri https://graph.microsoft.com/beta/users/$userId/appRoleAssignments --body "{\"appRoleId\": \"$appRoleId\", \"principalId\": \"$userId\", \"resourceId\": \"$servicePrincipalId\"}" --headers "Content-Type=application/json"
done < <(tail -n +2 $csvFilePath)

# Log out from Azure AD if the user logged in interactively
if [ -n "$(az account show --query user -o tsv)" ]; then
   az logout
fi