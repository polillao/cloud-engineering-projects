@description('Azure region for all resources')
param location string = resourceGroup().location

@description('Environment name, used in resource naming')
param environmentName string = 'dev'

module network 'network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    environmentName: environmentName
  }
}
module webAppNsg 'nsg.bicep' = {
  name: 'webAppNsgDeployment'
  params: {
    location: location
    nsgName: 'nsg-webapp-${environmentName}'
    securityRules: [
      {
        name: 'Allow-HTTP-HTTPS-Inbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '80'
            '443'
          ]
        }
      }
    ]
  }
}
module dbNsg 'nsg.bicep' = {
  name: 'dbNsgDeployment'
  params: {
    location: location
    nsgName: 'nsg-db-${environmentName}'
    securityRules: [
      {
        name: 'Allow-SQL-From-WebApp'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '10.0.1.0/24'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '1433'
        }
      }
    ]
  }
}
module adminNsg 'nsg.bicep' = {
  name: 'adminNsgDeployment'
  params: {
    location: location
    nsgName: 'nsg-admin-${environmentName}'
    securityRules: [
      {
        name: 'Allow-RDP-From-Bastion'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '10.0.4.0/26'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}
resource webAppSubnetAssociation 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: 'vnet-netmaze-${environmentName}/snet-webapp-${environmentName}'
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: webAppNsg.outputs.nsgId
    }
  }
  dependsOn: [
    network
  ]
}
resource dbSubnetAssociation 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: 'vnet-netmaze-${environmentName}/snet-db-${environmentName}'
  properties: {
    addressPrefix: '10.0.2.0/24'
    networkSecurityGroup: {
      id: dbNsg.outputs.nsgId
    }
  }
  dependsOn: [
    network
  ]
}
resource adminSubnetAssociation 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: 'vnet-netmaze-${environmentName}/snet-admin-${environmentName}'
  properties: {
    addressPrefix: '10.0.3.0/24'
    networkSecurityGroup: {
      id: adminNsg.outputs.nsgId
    }
  }
  dependsOn: [
    network
  ]
}
