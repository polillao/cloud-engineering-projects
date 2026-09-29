@description('Azure region for monitoring resources')
param location string = resourceGroup().location

@description('Environment name, used in resource naming')
param environmentName string = 'dev'

@description('Resource ID of the main VPN Gateway to monitor')
param vpnGatewayId string

@description('Resource ID of the WebApp NSG to monitor')
param webAppNsgId string

@description('Resource ID of the DB NSG to monitor')
param dbNsgId string

@description('Resource ID of the Admin NSG to monitor')
param adminNsgId string
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'log-netmaze-${environmentName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}
resource vpnGatewayResource 'Microsoft.Network/virtualNetworkGateways@2021-05-01' existing = {
  name: last(split(vpnGatewayId, '/'))
}
resource vpnGatewayDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-vpngw-${environmentName}'
  scope: vpnGatewayResource
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'GatewayDiagnosticLog'
        enabled: true
      }
      {
        category: 'TunnelDiagnosticLog'
        enabled: true
      }
    ]
  }
}
resource webAppNsgResource 'Microsoft.Network/networkSecurityGroups@2021-05-01' existing = {
  name: last(split(webAppNsgId, '/'))
}

resource webAppNsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-nsg-webapp-${environmentName}'
  scope: webAppNsgResource
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}

resource dbNsgResource 'Microsoft.Network/networkSecurityGroups@2021-05-01' existing = {
  name: last(split(dbNsgId, '/'))
}

resource dbNsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-nsg-db-${environmentName}'
  scope: dbNsgResource
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}

resource adminNsgResource 'Microsoft.Network/networkSecurityGroups@2021-05-01' existing = {
  name: last(split(adminNsgId, '/'))
}

resource adminNsgDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-nsg-admin-${environmentName}'
  scope: adminNsgResource
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'NetworkSecurityGroupEvent'
        enabled: true
      }
      {
        category: 'NetworkSecurityGroupRuleCounter'
        enabled: true
      }
    ]
  }
}
resource actionGroup 'Microsoft.Insights/actionGroups@2021-09-01' = {
  name: 'ag-netmaze-${environmentName}'
  location: 'global'
  properties: {
    groupShortName: 'netmaze'
    enabled: true
    emailReceivers: []
  }
}

resource nsgDenyAlert 'Microsoft.Insights/scheduledQueryRules@2021-08-01' = {
  name: 'alert-nsg-deny-${environmentName}'
  location: location
  properties: {
    displayName: 'NSG Deny Rate Alert'
    description: 'Alerts when NSG denies exceed threshold, indicating possible unauthorized access attempts'
    severity: 2
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    scopes: [
      logAnalytics.id
    ]
    criteria: {
      allOf: [
        {
          query: 'AzureDiagnostics | where Category == "NetworkSecurityGroupEvent" | where status_s == "Deny"'
          timeAggregation: 'Count'
          operator: 'GreaterThan'
          threshold: 5
        }
      ]
    }
    actions: {
      actionGroups: [
        actionGroup.id
      ]
    }
  }
}
output logAnalyticsWorkspaceId string = logAnalytics.id
output actionGroupId string = actionGroup.id
