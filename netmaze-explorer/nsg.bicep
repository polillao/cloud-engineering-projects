@description('Azure region for this NSG')
param location string = resourceGroup().location

@description('Name of the Network Security Group')
param nsgName string

@description('Array of security rule objects to apply to this NSG')
param securityRules array
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: securityRules
  }
}
output nsgId string = nsg.id
