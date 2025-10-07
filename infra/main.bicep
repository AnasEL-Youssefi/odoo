@description('Location for all resources')
param location string = resourceGroup().location

@description('Prefix for resource names')
param prefix string = 'odoo'

@description('Admin username for VM')
param adminUsername string = 'adminuser'

@description('SSH public key')
param adminPublicKey string

@description('vm size')
param vmSize string = 'Standard_B2ms'

@description('postgresql enabled?')
param useAzurePostgres bool = true

// Resource names
var vnetName = '${prefix}-vnet'
var subnetName = '${prefix}-subnet'
var nicName = '${prefix}-nic'
var vmName = '${prefix}-vm'
var storageName = toLower('${prefix}storage${uniqueString(resourceGroup().id)}')
var kvName = toLower('${prefix}kv${uniqueString(resourceGroup().id)}')

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
    subnets: [
      {
        name: subnetName
        properties: { addressPrefix: '10.0.1.0/24' }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-04-01' = {
  name: '${prefix}-pip'
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: vnet.properties.subnets[0].id }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: { id: publicIP.id }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2024-04-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: { vmSize: vmSize }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: { publicKeys: [ { path: '/home/${adminUsername}/.ssh/authorized_keys', keyData: adminPublicKey } ] }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy' // Ubuntu 22.04 LTS - avoids "Pro" confusion
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: { createOption: 'FromImage' }
    }
    networkProfile: { networkInterfaces: [ { id: nic.id } ] }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-06-01' = {
  name: storageName
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: { allowBlobPublicAccess: false }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01-preview' = {
  name: kvName
  location: location
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: subscription().tenantId
    accessPolicies: []
    enableSoftDelete: true
  }
}

output vmPublicIP string = publicIP.properties.ipAddress
output storageAccountName string = storageAccount.name
output keyVaultName string = keyVault.name
