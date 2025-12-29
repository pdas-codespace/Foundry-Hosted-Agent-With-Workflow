#!/bin/bash
# Script to add GitHub secrets for Foundry Hosted Agent CI/CD
# Prerequisites: GitHub CLI (gh) installed and authenticated

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Please authenticate with GitHub CLI first: gh auth login"
    exit 1
fi

REPO="pdas-codespace/Foundry-Hosted-Agent-With-Workflow"

echo "Adding secrets to repository: $REPO"
echo "=========================================="

# Prompt for each secret value
read -p "Enter ACR_NAME : " ACR_NAME
read -p "Enter IMAGE_NAME : " IMAGE_NAME
read -p "Enter FOUNDRY_ACCOUNT : " FOUNDRY_ACCOUNT
read -p "Enter PROJECT_NAME : " PROJECT_NAME
read -p "Enter AGENT_NAME : " AGENT_NAME
read -p "Enter AZURE_AI_PROJECT_ENDPOINT : " AZURE_AI_PROJECT_ENDPOINT

echo ""
echo "Now we need AZURE_CREDENTIALS (Service Principal JSON)."
echo "Run this command to create one:"
echo ""
echo "  az ad sp create-for-rbac --name 'github-foundry-cicd' --role contributor --scopes /subscriptions/<sub-id>/resourceGroups/<rg> --sdk-auth"
echo ""
read -p "Paste the entire JSON output (then press Enter): " AZURE_CREDENTIALS

# Set secrets
echo ""
echo "Setting secrets..."

gh secret set ACR_NAME --repo "$REPO" --body "$ACR_NAME"
gh secret set IMAGE_NAME --repo "$REPO" --body "$IMAGE_NAME"
gh secret set FOUNDRY_ACCOUNT --repo "$REPO" --body "$FOUNDRY_ACCOUNT"
gh secret set PROJECT_NAME --repo "$REPO" --body "$PROJECT_NAME"
gh secret set AGENT_NAME --repo "$REPO" --body "$AGENT_NAME"
gh secret set AZURE_AI_PROJECT_ENDPOINT --repo "$REPO" --body "$AZURE_AI_PROJECT_ENDPOINT"
gh secret set AZURE_CREDENTIALS --repo "$REPO" --body "$AZURE_CREDENTIALS"

echo ""
echo "✅ All secrets have been added!"
echo ""
echo "Verify with: gh secret list --repo $REPO"
