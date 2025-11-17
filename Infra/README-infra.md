# Infrastructure Deployment (Azure)

Detta projekt bygger en serverless pipeline i Azure som består av:

- Storage Account (container + queue)
- Logic App Standard
- Event Grid + Blob-triggerad ingestion
- Log Analytics Workspace
- Application Insights
- App Service Plan (WS1 Linux)

Alla resurser skapas med `deploy.sh`.

#Förutsättningar

Installera:

- Azure CLI
- Bash (Windows: Git Bash)
- En Azure-prenumeration
- Du måste vara inloggad:

```bash
az login

