// Bicep template for creating Container Registry, Container Apps Environment, and Container App
targetScope = 'resourceGroup'

// Parameters
@description('Name of the Azure Container Registry')
param containerRegistryName string

@description('Name of the Container Apps Environment')
param containerAppEnvironmentName string

@description('Name of the Container App')
param containerAppName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Container image to deploy')
param containerImage string = 'nginx:latest'

@description('Container port')
param containerPort int = 8000

@description('CPU allocation for the container')
param containerCpuCoreCount string = '0.5'

@description('Memory allocation for the container')
param containerMemory string = '1Gi'

@description('Minimum number of replicas')
param containerMinReplicas int = 0

@description('Maximum number of replicas')
param containerMaxReplicas int = 10

@description('Enable external ingress')
param enableIngress bool = true

@description('Allow insecure traffic')
param ingressAllowInsecure bool = false

// Variables
var tags = {
  environment: 'dev'
  project: 'fastmcp-server'
}

// Azure Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: containerRegistryName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    policies: {
      quarantinePolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: 'disabled'
      }
      retentionPolicy: {
        days: 7
        status: 'disabled'
      }
    }
    encryption: {
      status: 'disabled'
    }
    dataEndpointEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleBypassOptions: 'AzureServices'
    zoneRedundancy: 'Disabled'
  }
}

// Log Analytics Workspace for Container Apps Environment
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${containerAppEnvironmentName}-logs'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// Container Apps Environment
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: containerAppEnvironmentName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    zoneRedundant: false
  }
}

// Container App
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      ingress: enableIngress ? {
        external: true
        targetPort: containerPort
        allowInsecure: ingressAllowInsecure
      } : null
    }
    template: {
      revisionSuffix: 'initial'
      containers: [
        {
          name: 'fastmcp-server'
          image: containerImage
        }
      ]
    }
  }
}

// Outputs
@description('The login server of the Container Registry')
output containerRegistryLoginServer string = containerRegistry.properties.loginServer

@description('The name of the Container Registry')
output containerRegistryName string = containerRegistry.name

@description('The name of the Container Apps Environment')
output containerAppsEnvironmentName string = containerAppsEnvironment.name

@description('The name of the Container App')
output containerAppName string = containerApp.name

@description('The FQDN of the Container App')
output containerAppFQDN string = enableIngress ? containerApp.properties.configuration.ingress.fqdn : ''

@description('The URI of the Container App')
output containerAppURI string = enableIngress ? 'https://${containerApp.properties.configuration.ingress.fqdn}' : ''

@description('The resource ID of the Container Registry')
output containerRegistryId string = containerRegistry.id

@description('The resource ID of the Container Apps Environment')
output containerAppsEnvironmentId string = containerAppsEnvironment.id

@description('The resource ID of the Container App')
output containerAppId string = containerApp.id
