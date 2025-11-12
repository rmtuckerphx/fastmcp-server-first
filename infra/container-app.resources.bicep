// Bicep template for creating Container App
targetScope = 'resourceGroup'

// Parameters
@description('Name of the Container App')
param containerAppName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Container image to deploy (full path including registry)')
param containerImage string

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

@description('Resource ID of the Container Apps Environment')
param containerAppsEnvironmentId string

@description('Container Registry Name for authentication')
param containerRegistryName string

@description('Deployment timestamp for unique revision suffix')
param deploymentTimestamp string = utcNow()

// Variables
var tags = {
  environment: 'dev'
  project: 'fastmcp-server'
}

// Reference existing Container Registry for authentication
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

// Container App
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    configuration: {
      ingress: enableIngress ? {
        external: true
        targetPort: containerPort
        allowInsecure: ingressAllowInsecure
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
      } : null
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.listCredentials().username
          passwordSecretRef: 'registry-password'
        }
      ]
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
    }
    template: {
      revisionSuffix: 'v${uniqueString(deploymentTimestamp)}'
      containers: [
        {
          name: 'fastmcp-server'
          image: containerImage
          resources: {
            cpu: json(containerCpuCoreCount)
            memory: containerMemory
          }
        }
      ]
      scale: {
        minReplicas: containerMinReplicas
        maxReplicas: containerMaxReplicas
        rules: [
          {
            name: 'http-rule'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

// Outputs
@description('The name of the Container App')
output containerAppName string = containerApp.name

@description('The FQDN of the Container App')
output containerAppFQDN string = enableIngress ? containerApp.properties.configuration.ingress.fqdn : ''

@description('The URI of the Container App')
output containerAppURI string = enableIngress ? 'https://${containerApp.properties.configuration.ingress.fqdn}' : ''

@description('The resource ID of the Container App')
output containerAppId string = containerApp.id