@description('Azure region for the monitoring hub')
param location string = resourceGroup().location

@description('Environment name, used in resource naming')
param environmentName string = 'dev'

@description('Days to keep logs in the workspace')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('Daily ingestion cap in GB, a cost guardrail')
param dailyQuotaGb int = 1

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'log-insightscape-${environmentName}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionInDays
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
  }
}

output workspaceId string = workspace.id
output workspaceName string = workspace.name
