@description('Azure region for Private Link resources')
param location string = resourceGroup().location

@description('Environment name, used in resource naming')
param environmentName string = 'dev'

@description('Resource ID of the WebApp subnet from the network module')
param webAppSubnetId string

@description('Resource ID of the VNet, needed for the private DNS zone link')
param vnetId string
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stnm${environmentName}${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'pe-storage-${environmentName}'
  location: location
  properties: {
    subnet: {
      id: webAppSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'pe-storage-connection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
}

resource dnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'link-netmaze-${environmentName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
output storageAccountName string = storageAccount.name
