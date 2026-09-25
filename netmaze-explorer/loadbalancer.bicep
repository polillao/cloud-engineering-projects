@description('Azure region for the Load Balancer')
param location string = resourceGroup().location

@description('Environment name, used in resource naming')
param environmentName string = 'dev'

resource lbPublicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pip-lb-${environmentName}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
resource loadBalancer 'Microsoft.Network/loadBalancers@2021-05-01' = {
  name: 'lb-webapp-${environmentName}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: {
            id: lbPublicIp.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'WebAppBackendPool'
      }
    ]
    probes: [
      {
        name: 'HttpProbe'
        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/'
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'HttpRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'lb-webapp-${environmentName}', 'LoadBalancerFrontEnd')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', 'lb-webapp-${environmentName}', 'WebAppBackendPool')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', 'lb-webapp-${environmentName}', 'HttpProbe')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
        }
      }
    ]
  }
}
output loadBalancerId string = loadBalancer.id
