#!/bin/bash

set -e

echo "Checking Azure login status..."
if az account show > /dev/null 2>&1; then
  echo "Already logged in to Azure."
else
  echo "Not logged in. Initiating Azure login..."
  az login
  echo "Login completed."
fi

echo "Listing available subscriptions:"
az account list --output table

read -p "Enter the number of the subscription to use (1-based): " sub_num

# Get number of subscriptions
subscriptions=$(az account list --query 'length(@)' -o tsv)

if [ "$sub_num" -lt 1 ] || [ "$sub_num" -gt "$subscriptions" ]; then
  echo "Invalid subscription number. Please enter a number between 1 and $subscriptions."
  exit 1
fi

index=$((sub_num - 1))
sub_id=$(az account list --query "[$index].id" -o tsv)
az account set --subscription $sub_id

echo "Subscription set to: $(az account show --query 'name' -o tsv)"

read -p "Enter Resource Group name: " rg_name

read -p "Enter Owner tag: " owner_tag

read -p "Enter location [default: eastus]: " location
location=${location:-eastus}

echo "Creating resource group '$rg_name' in $location with owner tag '$owner_tag'..."
az group create --name $rg_name --location $location --tags owner=$owner_tag

read -p "Enter suffix for Container resources: " container_suffix

# Define container resource names
container_registry_name="acr${container_suffix//[^a-zA-Z0-9]/}"
container_app_env_name="cae-${container_suffix}"
container_app="ca-${container_suffix}"

# create container resources by calling container.resources.bicep file passing container_ var as params
echo "Deploying container resources..."
az deployment group create --resource-group $rg_name --template-file infra/container.resources.bicep \
  --parameters containerRegistryName=$container_registry_name \
  containerAppEnvironmentName=$container_app_env_name \
  containerAppName=$container_app

if [ $? -eq 0 ]; then
  echo "Deployment completed successfully!"
  echo "Getting deployment outputs..."
  outputs=$(az deployment group show --resource-group $rg_name --name container.resources --query properties.outputs -o json)
  container_app_fqdn=$(echo $outputs | jq -r '.containerAppFQDN.value // empty')

if [ -n "$container_app_fqdn" ]; then
    echo "Container App FQDN: $container_app_fqdn"
else
    echo "Could not retrieve Container App FQDN from deployment outputs"
fi 
