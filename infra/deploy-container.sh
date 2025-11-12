#!/bin/bash

set -e

echo "FastMCP Server - Container Deployment Script"
echo "============================================="

# Check if deployment-info.sh exists
if [ ! -f "deployment-info.sh" ]; then
  echo "Error: deployment-info.sh not found. Please run setup-infra.sh first."
  exit 1
fi

# Load deployment information
source ./deployment-info.sh

echo "Using deployment configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Container Registry: $CONTAINER_REGISTRY_NAME"
echo "  Registry Login Server: $REGISTRY_LOGIN_SERVER"
echo "  Container Apps Environment: $CONTAINER_APP_ENV_NAME"
echo ""

# Prompt for container app name
read -p "Enter Container App name (e.g., ca-fastmcp): " container_app_name

# Check if container app name is provided
if [ -z "$container_app_name" ]; then
  echo "Error: Container App name is required."
  exit 1
fi

# Generate image name with timestamp
timestamp=$(date +%Y%m%d%H%M%S)
image_name="fastmcp-server"
image_tag="v$timestamp"
full_image_name="$REGISTRY_LOGIN_SERVER/$image_name:$image_tag"

echo "Building and deploying container..."
echo "  Image: $full_image_name"
echo "  Container App: $container_app_name"
echo ""

# Check if logged in to Azure
echo "Checking Azure login status..."
if az account show > /dev/null 2>&1; then
  echo "Already logged in to Azure."
else
  echo "Not logged in. Initiating Azure login..."
  az login
  echo "Login completed."
fi

# Login to Azure Container Registry
echo "Logging in to Azure Container Registry..."
az acr login --name $CONTAINER_REGISTRY_NAME

# Build and push Docker image
echo "Building Docker image..."
docker build -t $image_name:$image_tag .

echo "Tagging image for Azure Container Registry..."
docker tag $image_name:$image_tag $full_image_name

echo "Pushing image to Azure Container Registry..."
docker push $full_image_name

# Deploy the container app
echo "Deploying Container App..."
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file infra/container-app.resources.bicep \
  --parameters containerAppName=$container_app_name \
               containerImage=$full_image_name \
               containerAppsEnvironmentId=$CONTAINER_APP_ENV_ID \
               containerRegistryName=$CONTAINER_REGISTRY_NAME

if [ $? -eq 0 ]; then
  echo ""
  echo "Container deployment completed successfully!"
  echo "Getting deployment outputs..."
  
  container_app_fqdn=$(az deployment group show --resource-group $RESOURCE_GROUP --name container-app.resources --query 'properties.outputs.containerAppFQDN.value' -o tsv)
  container_app_uri=$(az deployment group show --resource-group $RESOURCE_GROUP --name container-app.resources --query 'properties.outputs.containerAppURI.value' -o tsv)

  echo ""
  echo "Deployment Summary:"
  echo "==================="
  echo "Container Registry: $CONTAINER_REGISTRY_NAME"
  echo "Container Image: $full_image_name"
  echo "Container App: $container_app_name"
  
  if [ -n "$container_app_fqdn" ]; then
    echo "Container App FQDN: $container_app_fqdn"
    echo "Container App URI: $container_app_uri"
    echo ""
    echo "Test your application:"
    echo "  Health check: curl $container_app_uri/health"
    echo "  MCP endpoint: $container_app_uri/mcp"
  else
    echo "Could not retrieve Container App FQDN from deployment outputs"
  fi
  
  echo ""
  echo "To redeploy with updates:"
  echo "  ./deploy-container.sh"
  echo ""
  echo "To view logs:"
  echo "  az containerapp logs show --name $container_app_name --resource-group $RESOURCE_GROUP --follow"
else
  echo "Container deployment failed!"
  exit 1
fi