@description('Azure region for VPN Gateway resources')
param location string = resourceGroup().location

@description('Environment name, used in resource naming')
param environmentName string = 'dev'

@description('Resource ID of the main VNet GatewaySubnet')
param mainGatewaySubnetId string

@description('Resource ID of the on-prem VNet GatewaySubnet')
param onpremGatewaySubnetId string

@secure()
@description('Shared key for the VPN connection between the two gateways')
param sharedKey string
resource mainGatewayPip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pip-vpngw-main-${environmentName}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource onpremGatewayPip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pip-vpngw-onprem-${environmentName}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
resource mainGateway 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = {
  name: 'vpngw-main-${environmentName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          subnet: {
            id: mainGatewaySubnetId
          }
          publicIPAddress: {
            id: mainGatewayPip.id
          }
        }
      }
    ]
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
  }
}

resource onpremGateway 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = {
  name: 'vpngw-onprem-${environmentName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          subnet: {
            id: onpremGatewaySubnetId
          }
          publicIPAddress: {
            id: onpremGatewayPip.id
          }
        }
      }
    ]
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
  }
}
resource mainToOnpremConnection 'Microsoft.Network/connections@2021-05-01' = {
  name: 'conn-main-to-onprem-${environmentName}'
  location: location
  properties: {
        virtualNetworkGateway1: {
      id: mainGateway.id
      properties: {}
    }
    virtualNetworkGateway2: {
      id: onpremGateway.id
      properties: {}
    }
    connectionType: 'Vnet2Vnet'
    sharedKey: sharedKey
  }
}
output connectionId string = mainToOnpremConnection.id
output mainGatewayId string = mainGateway.id
