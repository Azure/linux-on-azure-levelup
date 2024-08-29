@description('Name of the vnet')
param vnetName string = 'linuxlevelup-vnet'

@description('Address prefix for vnet')
param vnetPrefix string = '10.0.0.0/21'

@description('Name of Application Gateway subnet')
param snet1Name string = 'linuxlevelup-appgw-snet'

@description('description')
param snet1Prefix string = '10.0.0.0/24'

@description('description')
param snet2Name string = 'linuxlevel-web-snet'

@description('description')
param snet2Prefix string = '10.0.1.0/24'

@description('description')
param snet3Name string = 'linuxlevelup-data-snet'

@description('description')
param snet3Prefix string = '10.0.2.0/24'

@description('description')
param bastionPrefix string = '10.0.3.0/24'

@description('NSG for web vms')
param webvmNSG string = 'linuxlevelup-webvm-nsg'

@description('NSG for database vm ')
param datavmNSG string = 'linuxlevelup-datavm-nsg'

@description('NSG for subnets')
param snetNSG string = 'linuxlevelup-snet-nsg'

@description('Name of Application Gateway ')
param appgwName string = 'linuxlevelup-appgw-01'

@description('Application Gateway Public IP Name')
param pipName string = 'Enter a unique name for the Public IP'

@description('BastionHost Name')
param bastionName string = 'linuxlevelupbastionHost'

@description('Public IP for the Bastion Host ')
param bastionPipName string = 'Enter a unique name for the Public IP'

@description('Name of web server 1')
param vm1Name string = 'web-01'

@description('Name of web server 2')
param vm2Name string = 'web-02'

@description('name of database server')
param vm3Name string = 'db-01'

@description('Administrator account')
param adminusername string = 'azlinuxadmin'

@description('SSH Public Key for web-01')
param admin1PublicKey string = ' '

@description('SSH Public Key for web-02')
param admin2PublicKey string = ' '

@description('SSH Public Key for db-01')
param admin3PublicKey string = ' '

resource pip 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: pipName
  location: resourceGroup().location
  tags: {
    displayName: pipName
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionPip 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: bastionPipName
  location: resourceGroup().location
  tags: {
    displayName: bastionPipName
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource snetNSG_resource 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: snetNSG
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'SnetgAccessRule'
        properties: {
          description: 'NSG rule for subnets'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: vnetPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'SnetgRuleHTTP'
        properties: {
          description: 'NSG rule for subnets'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: snet1Prefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource webvmNSG_resource 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: webvmNSG
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'SSH'
        properties: {
          description: 'Allow SSH Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: vnetPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'HTTP'
        properties: {
          description: 'Allow HTTP Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource datavmNSG_resource 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: datavmNSG
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'DataInbound'
        properties: {
          description: 'Allow access to the database'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: snet2Prefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'SSH'
        properties: {
          description: 'SSH access to the db-01'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: vnetPrefix
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: resourceGroup().location
  tags: {
    displayName: vnetName
    Project: 'Linux LevelUp 2025'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetPrefix
      ]
    }
    subnets: [
      {
        name: snet1Name
        properties: {
          addressPrefix: snet1Prefix
        }
      }
      {
        name: snet2Name
        properties: {
          addressPrefix: snet2Prefix
          networkSecurityGroup: {
            id: snetNSG_resource.id
          }
        }
      }
      {
        name: snet3Name
        properties: {
          addressPrefix: snet3Prefix
          networkSecurityGroup: {
            id: snetNSG_resource.id
          }
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: bastionPrefix
        }
      }
    ]
  }
}

resource appgw 'Microsoft.Network/applicationGateways@2023-11-01' = {
  name: appgwName
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      family: 'Generation_2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, snet1Name)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIP'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'appGatewayFrontendPort'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appGatewayBackendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: '10.0.1.4'
            }
            {
              ipAddress: '10.0.1.5'
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'appGatewayBackendHttpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
        }
      }
    ]
    httpListeners: [
      {
        name: 'appGatewayHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appgwName,
              'appGatewayFrontendIP'
            )
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appgwName, 'appGatewayFrontendPort')
          }
          protocol: 'Http'
          sslCertificate: null
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'HTTP_IN'
        properties: {
          ruleType: 'Basic'
          priority: '100'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appgwName, 'appGatewayHttpListener')
          }
          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              appgwName,
              'appGatewayBackendPool'
            )
          }
          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appgwName,
              'appGatewayBackendHttpSettings'
            )
          }
        }
      }
    ]
    routingRules: []
    probes: []
    rewriteRuleSets: []
    redirectConfigurations: []
    privateLinkConfigurations: []
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
  }
  dependsOn: [
    vnet
  ]
}

resource vm1Name_NIC 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: '${vm1Name}-NIC'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, snet2Name)
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet
    webvmNSG_resource
  ]
}

resource vm1 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vm1Name
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    osProfile: {
      computerName: vm1Name
      adminUsername: adminusername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminusername}/.ssh/authorized_keys'
              keyData: admin1PublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'fromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vm1Name_NIC.id
        }
      ]
    }
  }
}

resource vm2Name_NIC 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: '${vm2Name}-NIC'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, snet2Name)
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet
    webvmNSG_resource
  ]
}

resource vm2 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vm2Name
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    osProfile: {
      computerName: vm2Name
      adminUsername: adminusername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminusername}/.ssh/authorized_keys'
              keyData: admin2PublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'fromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vm2Name_NIC.id
        }
      ]
    }
  }
}

resource vm3Name_NIC 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: '${vm3Name}-NIC'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, snet3Name)
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet
    datavmNSG_resource
  ]
}

resource vm3 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vm3Name
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    osProfile: {
      computerName: vm3Name
      adminUsername: adminusername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminusername}/.ssh/authorized_keys'
              keyData: admin3PublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'fromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vm3Name_NIC.id
        }
      ]
    }
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2020-05-01' = {
  name: bastionName
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'AzureBastionSubnet')
          }
          publicIPAddress: {
            id: bastionPip.id
          }
        }
      }
    ]
  }
  dependsOn: [
    vnet
  ]
}
