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

# Define infrastructure resource names
container_registry_name="acr${container_suffix//[^a-zA-Z0-9]/}"
container_app_env_name="cae-${container_suffix}"

# Deploy infrastructure resources (Container Registry, Container Apps Environment, Log Analytics)
echo "Deploying infrastructure resources..."
az deployment group create --resource-group $rg_name --template-file infra/infrastructure.resources.bicep \
  --parameters containerRegistryName=$container_registry_name \
  containerAppEnvironmentName=$container_app_env_name

if [ $? -eq 0 ]; then
  echo "Infrastructure deployment completed successfully!"
  echo "Getting deployment outputs..."
  registry_login_server=$(az deployment group show --resource-group $rg_name --name infrastructure.resources --query 'properties.outputs.containerRegistryLoginServer.value' -o tsv)
  environment_id=$(az deployment group show --resource-group $rg_name --name infrastructure.resources --query 'properties.outputs.containerAppsEnvironmentId.value' -o tsv)

  echo "Container Registry: $container_registry_name"
  echo "Registry Login Server: $registry_login_server"
  echo "Container Apps Environment: $container_app_env_name"
  
  # Save deployment info for use by deploy-container.sh
  echo "#!/bin/bash" > deployment-info.sh
  echo "export RESOURCE_GROUP=\"$rg_name\"" >> deployment-info.sh
  echo "export CONTAINER_REGISTRY_NAME=\"$container_registry_name\"" >> deployment-info.sh
  echo "export CONTAINER_APP_ENV_NAME=\"$container_app_env_name\"" >> deployment-info.sh
  echo "export CONTAINER_APP_ENV_ID=\"$environment_id\"" >> deployment-info.sh
  echo "export REGISTRY_LOGIN_SERVER=\"$registry_login_server\"" >> deployment-info.sh
  
  chmod +x deployment-info.sh
  echo "Deployment information saved to deployment-info.sh"
  echo ""
  echo "Next steps:"
  echo "1. Run './deploy-container.sh' to build and deploy your container application"
else
  echo "Infrastructure deployment failed!"
  exit 1
fi