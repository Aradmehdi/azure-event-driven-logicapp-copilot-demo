#!/usr/bin/env bash
set -e

# Ställ in variabler
RG="la-copilot-demo-rg"
LOC="westeurope"
ST="lacopilot$RANDOM"
QUEUE="outqueue"
LAW="la-copilot-law"
AI="la-copilot-ai"
LAPLAN="la-copilot-plan"
LAAPP="la-copilot-demo"

echo "==> Skapar Resource Group"
az group create -n $RG -l $LOC

echo "==> Skapar Storage Account, container och Queue"
az storage account create -n $ST -g $RG -l $LOC --sku Standard_LRS
az storage container create --account-name $ST -n incoming --auth-mode login
az storage queue create --account-name $ST -n $QUEUE --auth-mode login

echo "==> Skapar Log Analytics Workspace"
az monitor log-analytics workspace create -g $RG -n $LAW -l $LOC

echo "==> Hämtar Resource ID för Log Analytics"
LAW_RES_ID=$(az monitor log-analytics workspace show -g $RG -n $LAW --query id -o tsv)

echo "==> Skapar Application Insights"
az monitor app-insights component create \
  -g $RG -l $LOC -a $AI \
  --kind web --application-type web \
  --workspace $LAW_RES_ID

echo "==> Skapar App Service Plan för Logic App Standard"
az appservice plan create \
  --name $LAPLAN \
  --resource-group $RG \
  --location $LOC \
  --sku WS1 \
  --is-linux

echo "==> Skapar Logic App Standard"
az webapp create \
  --resource-group $RG \
  --plan $LAPLAN \
  --name $LAAPP \
  --runtime "dotnet:6" \
  --deployment-local-git

echo "==> Kopplar Application Insights till Logic App"
az resource update \
  --resource-group $RG \
  --name $LAAPP \
  --resource-type "Microsoft.Web/sites" \
  --set properties.siteConfig.appSettings="[{\"name\":\"APPINSIGHTS_INSTRUMENTATIONKEY\",\"value\":\"$(az monitor app-insights component show -g $RG -a $AI --query instrumentationKey -o tsv)\"},{\"name\":\"APPLICATIONINSIGHTS_CONNECTION_STRING\",\"value\":\"$(az monitor app-insights component show -g $RG -a $AI --query connectionString -o tsv)\"}]"

echo ""
echo "==================== KLART ===================="
echo "Resource Group:            $RG"
echo "Storage Account:           $ST"
echo "Queue:                     $QUEUE"
echo "Log Analytics workspace:   $LAW"
echo "App Insights:              $AI"
echo "Logic App Standard name:   $LAAPP"
echo "App Service Plan:          $LAPLAN"
echo ""
echo "Din Logic App är nu skapad!"
echo "Du kan nu publicera workflows (la-copilot-demo/ mappen) via VS Code eller ZIP deploy."
echo "================================================="



