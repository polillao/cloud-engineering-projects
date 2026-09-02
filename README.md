# Cloud Engineering Projects
![Azure](https://img.shields.io/badge/Azure-Logic%20Apps-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Status](https://img.shields.io/badge/status-active-success.svg)

Hands-on Azure projects built while transitioning from systems administration 
into cloud engineering. Each project maps to an AZ-104 exam domain and solves 
a problem I encountered in real sysadmin work.

---

## 📂 Projects

### 🚀 Onboard Automator
- **Tech Stack:** Azure Logic Apps, Microsoft Entra ID, Graph API, SharePoint, O365
- **What it does:** Auto-provisions new hires in M365 — creates accounts, assigns 
licenses, sets mailbox permissions, and notifies managers automatically.
- **Why I built it:** I managed this process manually at a law firm. This automates it end-to-end.
- **Link:** [Onboard Automator](./onboarding-automator.md)

### 🔐 ShareSafely
- **Tech Stack:** Python, Flask, Azure Blob Storage, SAS Tokens, Azure App Service
- **What it does:** Secure file sharing app with time-limited access links, RBAC, 
and secrets managed via Azure Key Vault.
- **Why I built it:** Legal and enterprise environments need controlled, auditable 
file sharing — not consumer tools.
- **Link:** [ShareSafely](./sharesafely.md)

### 📦 VM Fleet Commander
- **Tech Stack:** Azure, Bicep, ARM, Azure Virtual Machines
- **What it does:** Deploys and manages Azure VM infrastructure using parameterized 
Bicep templates across multiple environments.
- **Why I built it:** To practice repeatable, scalable IaC deployments the way 
they're done in real cloud environments.
- **Link:** [VM Fleet Commander](./vm-fleet-commander.md)

### 🌐 NetMaze Explorer *(in progress)*
- **Tech Stack:** Azure Virtual Networks, VPN Gateway, Network Security Groups (NSGs), Azure Bastion, Azure Private Link, Azure DNS, Azure Load Balancer
- **What it does:** Designs a hybrid networking environment connecting a simulated on-premises network to Azure via site-to-site VPN, with segmented subnets, NSG traffic rules, private endpoint access to PaaS services, and load-balanced, DNS-resolved web resources.
- **Why I built it:** To practice the networking domain hands-on — hybrid connectivity, secure admin access, and traffic control are core to real-world Azure administration.
- **Link:** [NetMaze Explorer](./netmaze-explorer.md)

---
