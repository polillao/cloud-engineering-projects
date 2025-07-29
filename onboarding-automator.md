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
![Logic App Diagram](./assets/onboarding-automator.svg)
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
| ManagerEmail| Text | manager&#xfeff;@&#xfeff;contoso.com |
## Deployment

 ## Security Considerations/Concerns
 - Passwords are emailed in plain text for demo purposes.
 - The Logic App uses a **Managed Identity** with the following Entra ID Roles:
    - User Administrator
    - License Administrator 
 ## Testing
 - Add a new user entry to the SharePoint list
 - Verify user creation in Entra ID
 - Confirm email delivery to the manager
 - Confirm license assignment
## Known Issues / Future Improvements
- Add support for group assignments
- Store passwords using Key Vault or send via securelink
- Add UI form to create entries in SharePoint 
## License
[MIT License](LICENSE)
## Acknowledgements
Inspired by [@madebygps](https://github.com/madebygps) as a part of the clould-engineering-projects for the az-104.
Built by Built by **[Ted Maldonado](https://github.com/polillao)** as part of a hands-on cloud automation portfolio.
