# 🌐 NetMaze Explorer

*(In progress — build not yet complete)*

## Tech Stack
Azure, Bicep, Virtual Networks, Network Security Groups (NSGs), Azure Bastion, Azure Private Link, Azure DNS

## What it does
Builds a hybrid-style Azure networking environment: a multi-subnet VNet (WebApp, Database, Admin) with per-subnet NSGs enforcing least-privilege traffic rules, VNet peering simulating an on-prem-to-cloud connection, Azure Bastion for secure administrative access without exposing VMs publicly, and Azure Private Link for private access to PaaS services.

## Why I built it
To practice the networking patterns real hybrid environments use — segmentation, least-privilege access control, and keeping traffic off the public internet — and to round out the networking domain of AZ-104 with a hands-on build.

## Status
Actively being built. Architecture and Bicep module structure planned; deployment and testing in progress.

---

*This section will be filled in with architecture diagrams, deployment steps, and screenshots once the build is complete.*
