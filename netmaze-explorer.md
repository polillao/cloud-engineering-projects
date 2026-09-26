# 🌐 NetMaze Explorer

Azure networking project simulating a hybrid, secure environment: segmented subnets, least-privilege access rules, encrypted admin access, and private connectivity to a PaaS service — all defined as Infrastructure as Code and deployed/tested live.

## Tech Stack
Azure Virtual Networks, Network Security Groups (NSGs), Azure Bastion, Azure Private Link, Azure Private DNS, Azure Load Balancer, Bicep (modular, reusable templates)

## Architecture

A single VNet (`10.0.0.0/16`) is split into four subnets:

| Subnet | Address range | Purpose |
|---|---|---|
| `snet-webapp-dev` | `10.0.1.0/24` | Public-facing web tier |
| `snet-db-dev` | `10.0.2.0/24` | Backend data tier, no direct internet access |
| `snet-admin-dev` | `10.0.3.0/24` | Administrative access only, via Bastion |
| `AzureBastionSubnet` | `10.0.4.0/26` | Reserved subnet for Azure Bastion (mandatory exact name) |

Each subnet (except Bastion's) has its own NSG enforcing least-privilege access:
- **WebApp NSG** — allows inbound HTTP/HTTPS (80/443) from the internet
- **Database NSG** — allows inbound SQL (1433) only from the WebApp subnet
- **Admin NSG** — allows inbound RDP (3389) only from the Bastion subnet

Administrative access to VMs goes through **Azure Bastion**, not exposed RDP — no VM in this project has a public IP.

A **Storage Account** is reached exclusively via **Azure Private Link**, with a **Private DNS Zone** linked to the VNet so internal name resolution returns the private IP instead of the public endpoint. Public network access on the storage account is explicitly disabled.

An **Azure Load Balancer** (Standard SKU) distributes traffic across the WebApp subnet with an HTTP health probe.

## Key Design Decisions

- **VNet peering instead of VPN Gateway** to simulate hybrid connectivity — a real VPN Gateway costs $140+/month just provisioned; peering demonstrates the same trust-relationship concept for a fraction of the cost, appropriate for a lab environment. In production, this would be a VPN Gateway or ExpressRoute connection.
- **Modular Bicep structure** (`network.bicep`, `nsg.bicep`, `bastion.bicep`, `privatelink.bicep`, `loadbalancer.bicep`, `testvms.bicep`, orchestrated by `main.bicep`) — mirrors how production environments separate network topology from security policy, so each can be reviewed, versioned, and changed independently.
- **Environment-aware naming** (`${environmentName}` parameterized throughout) — the same template could deploy `dev`, `test`, or `prod` environments without code changes.
- **Basic SKU Bastion, Standard SKU Load Balancer** — Bastion's Basic tier is sufficient for browser-based admin access at a fraction of Standard's cost; the Load Balancer required Standard SKU due to an Azure subscription-level restriction on Basic SKU public IPs (encountered live during deployment — see Lessons Learned).
- **Ephemeral deployment** — the full stack was deployed, tested, and torn down within about 20 minutes to keep cloud spend near zero (total cost: well under $1).

## Deployment & Validation Process

1. Wrote and validated each Bicep module individually with `az bicep build`
2. Validated the full template against Azure with `az deployment group validate`
3. Ran `az deployment group what-if` to confirm the exact resource plan before touching real infrastructure
4. Deployed live with `az deployment group create`
5. Tested connectivity and access live (see below)
6. Tore down immediately with `az group delete`

## Live Testing

Two test VMs (`vm-webapp-test`, `vm-db-test`, no public IPs) were deployed into the WebApp and Database subnets to validate the network design end-to-end:

- **Bastion access confirmed** — connected to `vm-webapp-test` entirely through the browser-based Azure Bastion session, with no public IP on the VM at any point.
- **NSG rules confirmed** — verified each subnet's inbound rules matched the design (see screenshots).
- **Private DNS resolution confirmed** — `nslookup` against the storage account's blob endpoint from inside the VNet resolved to a private `10.0.x.x` address, confirming the Private Link + Private DNS Zone chain works end-to-end, not just deployed.

## Screenshots

![Resource group overview](./screenshots/resource-group-overview.png)
![Bastion session — connected to vm-webapp-test with no public IP](./screenshots/bastion-session.png)
![WebApp NSG inbound rules](./screenshots/nsg-webapp-rules.png)
![Database NSG inbound rules](./screenshots/nsg-db-rules.png)
![Admin NSG inbound rules](./screenshots/nsg-admin-rules.png)
![Private DNS resolution to a private IP](./screenshots/nslookup-private-dns.png)

## Lessons Learned

- **Nested module outputs and `az deployment group validate`** — Azure's `validate` command can short-circuit deep validation of nested modules when they depend on another module's outputs (a known limitation, not a template error). `what-if` handled the full dependency chain correctly and was the more reliable pre-deploy check.
- **Basic SKU public IP quota** — this subscription's tier doesn't allow any Basic SKU public IP addresses at all, which failed the Load Balancer deployment mid-run. Fixed by switching both the public IP and Load Balancer to Standard SKU (they must match tiers).
- **Storage account naming** — `uniqueString()` combined with a naming prefix can exceed Azure's 24-character limit for storage account names; kept the prefix short (`stnm`) to leave headroom.
- **Cross-cloud portability** — used Bicep's `environment().suffixes.storage` function instead of hardcoding `core.windows.net`, so the same template would resolve correctly if deployed into a different Azure cloud (e.g. Azure Government).

## Why I Built It

To practice the networking patterns real hybrid environments use — segmentation, least-privilege access control, secure administrative access, and private service connectivity — and to round out the networking domain of AZ-104 with a hands-on, fully deployed and tested build rather than just theory.