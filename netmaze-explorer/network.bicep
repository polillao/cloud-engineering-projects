@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name, used in resource naming')
param environmentName string = 'dev'

@description('Name of the virtual network')
param vnetName string = 'vnet-netmaze-${environmentName}'

@description('Address space for the entire VNet')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Address prefix for the WebApp subnet')
param webAppSubnetPrefix string = '10.0.1.0/24'

@description('Address prefix for the Database subnet')
param dbSubnetPrefix string = '10.0.2.0/24'

@description('Address prefix for the Admin subnet')
param adminSubnetPrefix string = '10.0.3.0/24'

@description('Address prefix for the Azure Bastion subnet')
param bastionSubnetPrefix string = '10.0.4.0/26'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-webapp-${environmentName}'
        properties: {
          addressPrefix: webAppSubnetPrefix
        }
      }
      {
        name: 'snet-db-${environmentName}'
        properties: {
          addressPrefix: dbSubnetPrefix
        }
      }
      {
        name: 'snet-admin-${environmentName}'
        properties: {
          addressPrefix: adminSubnetPrefix
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionSubnetPrefix
        }
      }
    ]
  }
}
resource webAppSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: vnet
  name: 'snet-webapp-${environmentName}'
}

resource dbSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: vnet
  name: 'snet-db-${environmentName}'
}

resource adminSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: vnet
  name: 'snet-admin-${environmentName}'
}

resource bastionSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: vnet
  name: 'AzureBastionSubnet'
}

output webAppSubnetId string = webAppSubnetRef.id
output dbSubnetId string = dbSubnetRef.id
output adminSubnetId string = adminSubnetRef.id
output bastionSubnetId string = bastionSubnetRef.id
output vnetId string = vnet.id
