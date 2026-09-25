@description('Azure region for test VMs')
param location string = resourceGroup().location

@secure()
@description('Admin password for test VMs')
param adminPassword string

@description('Admin username for test VMs')
param adminUsername string = 'azureadmin'

@description('Resource ID of the WebApp subnet')
param webAppSubnetId string

@description('Resource ID of the Database subnet')
param dbSubnetId string
resource webAppNic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: 'nic-webapp-test'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: webAppSubnetId
          }
        }
      }
    ]
  }
}

resource webAppTestVm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: 'vm-webapp-test'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm-webapp-test'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: webAppNic.id
        }
      ]
    }
  }
}
resource dbNic 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: 'nic-db-test'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: dbSubnetId
          }
        }
      }
    ]
  }
}

resource dbTestVm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: 'vm-db-test'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm-db-test'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: dbNic.id
        }
      ]
    }
  }
}
