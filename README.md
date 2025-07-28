# Onboarding-Automator (Azure Logic App) 
Automates the user onboarding process by creating m365 accounts based on SharePoint list entries.
## Overview 
Onboard Automator is a serverless automation workflow built with Azure Logic Apps that:
- Listens for new entries in a SharePoint Online list ("New Hire")
- Automatically creates a Microsoft Entra ID (Azure AD) user
- Assigns a M365 license
- Sends the account credentials to the listed manager
This eliminates manual onboarding tasks and ensures consistency accross the onboarding process.
## Tech Stack
- Azure Logic Apps
- Microsoft Entra ID (Azure AD)
- Microsoft Graph API
- SharePoint Online
- O365 (Outlook Email Connector)
## Visual
 [coming soon]   
## Features
- Dynamic Display Name, UPN, Mail Nickname generation
- Temporary password generation (```TempXXXX```) with random GUID segment
- Password reset enforced at first login
- Email to manager with login credentials
- License assignment via Graph API with Managed Identity
## Triggers and Flow
1. **Trigger**: when a new itm is created in the SharePoint "New Hire" list
2. **Initialize Password Variable**: ```TempXXXX``` format
3. **Create User in Entra ID**
4. **Assign License** (via HTTP call to Microsoft Graph)
5. **Email Manager with Credentials**
## Sample SharePoint Columns
| Column Name | Type | Example |
| --- | --- | --- |
| FirstName | Text | John |
| LastName | Text | Johnson |
| JobTitle | Text | Sales |
| Department | Choice | Sales |
| StartDate | Date & Time | mm/dd/yyyy |
| ManagerEmail| Text | manager@contoso.com |
