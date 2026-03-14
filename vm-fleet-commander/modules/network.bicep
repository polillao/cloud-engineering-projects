param location string
param vnetName string
param subnetName string
param nsgName string
//NSG (Network security Group)
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  properties: {
    //settings
    securityRules: [
      {
        name: 'Allow-RDP'
        properties:{
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix:'*'
          destinationPortRange:'3389'
        }
      }
    ]
  }
}
//VNET
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
    subnets:[
     {
      name: subnetName
      properties: {
        addressPrefix: '10.0.1.0/24'
        networkSecurityGroup: {
          id: nsg.id
        }
      }
     }
    ]

  }
}
//output
output subnetId string = vnet.properties.subnets[0].id
output nsgId string = nsg.id
