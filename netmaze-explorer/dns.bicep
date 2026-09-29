@description('The DNS zone name — a subdomain of your real domain')
param dnsZoneName string = 'netmaze.tedmaldonado.com'

@description('Public IP address of the Load Balancer to point the DNS record at')
param loadBalancerPublicIp string
resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: dnsZoneName
  location: 'global'
  properties: {}
}
resource aRecord 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  parent: dnsZone
  name: 'web'
  properties: {
    TTL: 300
    ARecords: [
      {
        ipv4Address: loadBalancerPublicIp
      }
    ]
  }
}
output dnsZoneName string = dnsZone.name
output nameServers array = dnsZone.properties.nameServers
