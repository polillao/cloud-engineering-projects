@description('Azure region for the simulated on-premises network')
param location string = resourceGroup().location

@description('Environment name, used in resource naming')
param environmentName string = 'dev'

@description('Name of the on-premises VNet')
param onpremVnetName string = 'vnet-onprem-${environmentName}'

@description('Address space for the on-premises VNet')
param onpremAddressPrefix string = '192.168.0.0/16'

@description('Address prefix for the on-premises workload subnet')
param onpremSubnetPrefix string = '192.168.1.0/24'

@description('Address prefix for the GatewaySubnet (mandatory name, minimum /27)')
param gatewaySubnetPrefix string = '192.168.255.0/27'
resource onpremVnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: onpremVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        onpremAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'snet-onprem-${environmentName}'
        properties: {
          addressPrefix: onpremSubnetPrefix
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
}
resource onpremSubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: onpremVnet
  name: 'snet-onprem-${environmentName}'
}

resource gatewaySubnetRef 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: onpremVnet
  name: 'GatewaySubnet'
}

output onpremVnetId string = onpremVnet.id
output onpremSubnetId string = onpremSubnetRef.id
output gatewaySubnetId string = gatewaySubnetRef.id
