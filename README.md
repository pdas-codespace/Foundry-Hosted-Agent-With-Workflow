# Foundry Hosted Agent

A concurrent workflow agent deployed on Azure AI Foundry that leverages three specialized agents (researcher, marketer, legal) to respond to product launch strategy inquiries.

## Architecture

This agent uses the Microsoft Agent Framework to create a concurrent workflow:
- **Researcher Agent**: Provides market and product research insights
- **Marketer Agent**: Crafts marketing strategies and messaging
- **Legal Agent**: Reviews compliance and policy concerns

## Prerequisites

- Python 3.10+
- Azure CLI installed and authenticated
- Access to Azure AI Foundry
- Azure Container Registry for hosting the agent image

## Setup

### 1. Clone and Configure (DevContainer also supported for you to launch through GH Codespaces)

```bash
# Clone the repository
git clone <repository-url>
cd Foundry-Hosted-Agent

# Create virtual environment
python -m venv .venv
.venv\Scripts\activate  # Windows
# source .venv/bin/activate  # Linux/Mac

# Install dependencies
pip install -r requirements.txt

# Copy and configure environment variables
cp .env.example .env
# Edit .env with your Azure resource details
```

### 2. Azure Resources Required

- **Azure AI Foundry Account** with a project
- **Azure OpenAI deployment** (e.g., gpt-4o, gpt-5)
- **Azure Container Registry** for hosting the agent image

### 3. Required Permissions

The Foundry Project Managed Identity needs:
- `Cognitive Services OpenAI User` role on the Azure OpenAI resource
- `Azure AI User` role on the Foundry project

## CI/CD Pipeline

This repository includes a GitHub Actions workflow that automatically builds and deploys the agent when changes are pushed to `main`.

### Setup GitHub Secrets

Add the following secrets to your repository (Settings → Secrets and variables → Actions):

One sample gh command to help you achieve that - 

```bash

# Set a simple text secret
gh secret set AGENT_NAME --repo <user-name>/<repo-name> --body "testconcurrentflowasagent"

```

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AZURE_CREDENTIALS` | Service Principal credentials (JSON) | See below |
| `AZURE_AI_PROJECT_ENDPOINT` | Foundry project endpoint | `https://<foundry-account>.services.ai.azure.com/api/projects/<project-name>` |
| `AZURE_OPENAI_ENDPOINT` | Azure OpenAI endpoint | `https://<foundry-account>.openai.azure.com/` |
| `ACR_NAME` | Azure Container Registry name | `myacr` (without .azurecr.io) |
| `IMAGE_NAME` | Container image name | `foundry-workflow-agent` |
| `FOUNDRY_ACCOUNT` | Foundry account name | `myfoundryaccount` |
| `PROJECT_NAME` | Foundry project name | `myproject` |
| `AGENT_NAME` | Name for the hosted agent | `MyHostedAgent` |

**Create `AZURE_CREDENTIALS`:**
```bash
az ad sp create-for-rbac --name "github-foundry-agent-cicd" \
  --role contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/<resource-group> \
  --sdk-auth
```
Copy the entire JSON output as the secret value and use to set AZURE_CREDENTIALS

### Required Role Assignments for CI/CD Service Principal

```bash
# ACR Contributor access (for az acr build)
az role assignment create --assignee <sp-app-id> --role "Contributor" \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.ContainerRegistry/registries/<acr-name>

# Cognitive Services access for agent management
az role assignment create --assignee <sp-app-id> --role "Cognitive Services Contributor" \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/<foundry-account>

# Azure AI User access at Foundry resource level (required for agent registration)
az role assignment create --assignee <sp-app-id> --role "Azure AI User" \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/<foundry-account>

# Azure AI User access at Foundry Project level
az role assignment create --assignee <sp-app-id> --role "Azure AI User" \
  --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/<foundry-account>/projects/<project-name>
```

### Workflow Triggers

- **Automatic**: Pushes to `main` that modify `main.py`, `requirements.txt`, or `Dockerfile`
- **Manual**: Use "Run workflow" in GitHub Actions to deploy with a custom version tag

## Manual Deployment

### Build and Push Container Image

```bash
az acr build --image <agent-name>:<version> --registry <your-acr>.azurecr.io --file Dockerfile .
```

### Register the Agent

```bash
python registerAgent.py
```

### Start the Agent

```bash
az cognitiveservices agent start \
  --account-name <foundry-account> \
  --project-name <project-name> \
  --name <agent-name> \
  --agent-version <version>
```

## Local Testing

```bash
python callHostedAgent.py
```
You can also test the deployed agent through Foundry Playground.

## Security Notes

- **Never commit `.env` files** - they contain secrets
- Use **Managed Identity** when running in Azure (preferred)
- Use **Service Principal** only for local development if needed
- Rotate secrets regularly
- Store production secrets in Azure Key Vault

## Files

| File | Description |
|------|-------------|
| `main.py` | Agent implementation with concurrent workflow |
| `registerAgent.py` | Script to register the agent in Foundry |
| `callHostedAgent.py` | Client script to test the deployed agent |
| `agent.yaml` | Agent configuration and metadata |
| `Dockerfile` | Container image definition |
| `requirements.txt` | Python dependencies |


