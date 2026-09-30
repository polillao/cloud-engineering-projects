# 🌐 NetMaze Explorer

Azure hybrid networking project: a segmented VNet connected to a simulated on-premises network over a real site-to-site VPN, with least-privilege NSG rules, Bastion-only admin access, private connectivity to a PaaS service, load-balanced web resources, custom DNS, and full monitoring — all defined as Infrastructure as Code and deployed/tested live, twice.

## Tech Stack
Azure Virtual Networks, VPN Gateway, Network Security Groups (NSGs), Azure Bastion, Azure Private Link, Azure DNS, Azure Load Balancer, Azure Monitor / Log Analytics, Bicep

## Architecture

**Main VNet** (`10.0.0.0/16`) — five subnets:

| Subnet | Address range | Purpose |
|---|---|---|
| `snet-webapp-dev` | `10.0.1.0/24` | Public-facing web tier |
| `snet-db-dev` | `10.0.2.0/24` | Backend data tier, no direct internet access |
| `snet-admin-dev` | `10.0.3.0/24` | Administrative access only, via Bastion |
| `AzureBastionSubnet` | `10.0.4.0/26` | Reserved for Azure Bastion |
| `GatewaySubnet` | `10.0.5.0/27` | Reserved for the VPN Gateway |

**Simulated on-premises VNet** (`192.168.0.0/16`) — a second, isolated VNet standing in for a physical on-prem network, with its own workload subnet and `GatewaySubnet`.

**Hybrid connectivity:** a real site-to-site VPN connects the two VNets, using two `VpnGw1AZ` gateways (one per VNet) and a pair of `Vnet2Vnet` connection resources — one in each direction, both authenticated with a shared key. Live-tested and confirmed `Connected` on both sides.

**Network security:** each workload subnet (WebApp, Database, Admin) has its own NSG:
- **WebApp NSG** — allows inbound HTTP/HTTPS (80/443) from the internet
- **Database NSG** — allows inbound SQL (1433) only from the WebApp subnet
- **Admin NSG** — allows inbound RDP (3389) only from the Bastion subnet

**Administrative access** goes entirely through Azure Bastion — no VM in this project has a public IP.

**Private PaaS access:** a Storage Account is reachable only via Private Link, with a Private DNS Zone linked to the VNet so internal name resolution returns the private IP. Public access on the storage account is disabled.

**Load balancing:** a Standard SKU Load Balancer distributes HTTP traffic across the WebApp subnet, with the test VM's NIC attached to its backend pool.

**Custom DNS:** a public Azure DNS zone (`netmaze.tedmaldonado.com`) with an A record pointing at the Load Balancer's public IP.

**Monitoring:** a Log Analytics workspace collects diagnostic logs from the VPN Gateway and all three NSGs, with an alert rule configured to fire on elevated NSG deny rates.

## Key Design Decisions

- **Real VPN Gateway, not peering.** An earlier version of this project used VNet peering as a stand-in for hybrid connectivity to save cost. This rebuild replaced that with an actual site-to-site VPN between two real gateways, matching the original spec and giving a genuine "I configured a VPN tunnel" story rather than a routing shortcut.
- **Two connection resources, not one.** A VNet-to-VNet VPN requires a connection resource on each gateway, each pointing at the other — not a single shared connection. Missing the second direction leaves the tunnel stuck at `NotConnected` even though everything else deploys successfully.
- **`VpnGw1AZ`, not `VpnGw1`.** Microsoft deprecated the non-availability-zone VPN Gateway SKUs; only the `*AZ` SKUs can be created going forward. This only surfaced as a deployment-time error, not a `what-if` or `bicep build` warning.
- **Modular Bicep structure**, one file per concern (`network`, `onprem-network`, `vpngateway`, `nsg`, `bastion`, `privatelink`, `loadbalancer`, `dns`, `monitoring`, `testvms`), orchestrated by `main.bicep` — mirrors how production environments separate ownership and review across network topology, security policy, and operations.
- **Environment-aware naming** throughout, so the same template could deploy `dev`, `test`, or `prod` without code changes.
- **Ephemeral deployment.** The full stack, including both VPN Gateways, was deployed, tested, and torn down the same session both times it was built, to keep cost proportional to actual use rather than idle infrastructure.

## Deployment & Validation Process

1. Built and validated each module individually with `az bicep build`
2. Validated the full template against Azure with `az deployment group validate`
3. Ran `az deployment group what-if` to confirm the exact resource plan before touching real infrastructure
4. Deployed live with `az deployment group create`
5. Diagnosed and fixed two real deployment-time failures (see Lessons Learned)
6. Tested connectivity, access, and security boundaries live (below)
7. Tore down immediately after each test session with `az group delete`

## Live Testing

- **VPN tunnel:** confirmed `Connected` in both directions via `az network vpn-connection show`.
- **Negative NSG test:** from `vm-admin-test` (Admin subnet), `Test-NetConnection` to the DB VM on port 1433 correctly failed — the Admin subnet has no path to the Database subnet.
- **Positive NSG test:** used Azure's `test-ip-flow` diagnostic (both CLI and the Portal's IP flow verify tool) to authoritatively confirm the WebApp-to-DB path on port 1433 is allowed by the intended rule, in both directions (`AllowVnetOutBound` outbound from WebApp, `Allow-SQL-From-WebApp` inbound to DB).
- **Bastion access:** connected to test VMs entirely through the browser-based Bastion session, no public IP on any VM at any point.
- **Load Balancer:** confirmed `nic-webapp-test` is genuinely attached to the backend pool via the Portal. Did not install a web service on the test VM, so the health probe correctly reports the backend as unhealthy and HTTP traffic to the Load Balancer's public IP times out — this is expected, correct behavior given no listener exists, not a configuration fault.
- **DNS:** the public DNS zone and A record deployed and validated in Azure; registrar-side delegation to make it resolve on the public internet was out of scope for this pass.

## Screenshots

![VPN connection status — both directions Connected](./screenshots/vpn-connection-status.png)
![Negative test: Admin subnet blocked from reaching DB VM on 1433](./screenshots/nsg-negative-test-admin-to-db.png)
![IP flow verify: WebApp outbound to DB allowed](./screenshots/ip-flow-verify-webapp-outbound.png)
![IP flow verify: DB inbound from WebApp allowed](./screenshots/ip-flow-verify-db-inbound.png)
![Bastion session — connected to a test VM with no public IP](./screenshots/bastion-session.png)
![vm-webapp-test overview showing no public IP](./screenshots/vm-no-public-ip.png)
![WebApp NSG inbound rules](./screenshots/nsg-webapp-rules.png)
![Database NSG inbound rules](./screenshots/nsg-db-rules.png)
![Admin NSG inbound rules](./screenshots/nsg-admin-rules.png)
![Load Balancer backend pool showing nic-webapp-test attached](./screenshots/loadbalancer-backend-pool.png)

## Lessons Learned

- **NSG allowed ≠ reachable.** The first positive-path test failed even though the NSG correctly allowed it — because Windows' own host firewall, running inside the VM, independently blocks unsolicited inbound connections by default. Both the Azure network layer (NSG) and the guest OS layer (Windows Firewall) have to agree before traffic gets through. Opening the same port in the guest firewall, then re-verifying with Azure's `test-ip-flow` tool rather than an app-layer test, cleanly separated "is the network path open" from "is something listening."
- **VNet-to-VNet VPN needs two connection resources.** Documented in Microsoft's own setup guide, but easy to miss: one connection object per direction, sharing the same key.
- **VPN Gateway SKU deprecation.** `VpnGw1`–`VpnGw5` (non-AZ) are no longer creatable; only the `*AZ` SKUs are accepted now. This kind of platform-level change won't show up in `what-if` or a linter — only a live deploy attempt surfaces it.
- **Incremental deployment is genuinely useful during iteration.** Both fixes (SKU, missing connection) only required redeploying the same template; Azure recognized everything already correctly deployed and only created what was missing or previously failed — a 3-minute redeploy instead of another 35-minute full run.

## Why I Built It

To practice the full networking domain hands-on: hybrid connectivity, segmentation, least-privilege access control, secure administrative access, private service connectivity, load balancing, custom DNS, and monitoring — and to build and fix a real, live Azure environment rather than a paper design.

## License

[MIT License](https://github.com/polillao/cloud-engineering-projects/blob/main/LICENSE)

## Acknowledgements

Inspired by [@madebygps](https://github.com/madebygps) as part of the cloud-engineering-projects for the AZ-104.
Built by **[Ted Maldonado](https://github.com/polillao)** as part of a hands-on cloud automation portfolio.