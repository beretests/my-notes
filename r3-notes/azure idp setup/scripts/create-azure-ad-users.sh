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


# Loop through CSV file and create users
while IFS=, read -r displayName givenName surname userPrincipalName password; do
   # Create Azure AD user
   az ad user create --display-name "$displayName" --given-name "$givenName" --surname "$surname" --user-principal-name "$userPrincipalName@$azureADDomain" --password "$password" --force-change-password-next-login false --account-enabled true
done < <(tail -n +2 $csvFilePath)

# Log out from Azure AD if the user logged in interactively
if [ -n "$(az account show --query user -o tsv)" ]; then
   az logout
fi