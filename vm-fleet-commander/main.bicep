// This file uses the parameters from the json file to create the resources for the vnet and vm
param location string = resourceGroup().location
param vmName string
param vnetName string
param subnetName string
param nsgName string
param adminUsername string
// @secure encrypts the password so it is not exposed in logs or deployment history
@secure()
param adminPassword string
param vmSize string
// Deploys the vnet, subnet, and NSG.
// The subnet ID output is passed to the VM module.  
module network './modules/network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    vnetName: vnetName
    subnetName: subnetName
    nsgName: nsgName
  }
}
// Deploys the VM
// Calls for subnet id from the network file 
module vm './modules/virtualmachine.bicep' = {
  name: 'vmDeployment'
  params: {
    location: location
    vmName: vmName
    adminUsername: adminUsername
    adminPassword: adminPassword
    vmSize: vmSize
    subnetId: network.outputs.subnetId
  }
}
