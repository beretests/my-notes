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

# Replace with your CSV file path
csvFilePath="/path/to/your/file.csv"


# Loop through CSV file and delete users
while IFS=, read -r displayName givenName surname userPrincipalName password; do
   # Delete Azure AD user
   az ad user delete --id "$userPrincipalName@$azureADDomain"
done < <(tail -n +2 $csvFilePath)

# Log out from Azure AD if the user logged in interactively
if [ -n "$(az account show --query user -o tsv)" ]; then
   az logout
fi