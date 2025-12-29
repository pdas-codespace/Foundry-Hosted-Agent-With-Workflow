# Script to add GitHub secrets for Foundry Hosted Agent CI/CD
# Prerequisites: GitHub CLI (gh) installed and authenticated

# Check if gh is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI (gh) is not installed. Install it from: https://cli.github.com/" -ForegroundColor Red
    exit 1
}

# Check if authenticated
$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Please authenticate with GitHub CLI first: gh auth login" -ForegroundColor Red
    exit 1
}

$REPO = "pdas-codespace/Foundry-Hosted-Agent-With-Workflow"

Write-Host "Adding secrets to repository: $REPO" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Prompt for each secret value
$ACR_NAME = Read-Host "Enter ACR_NAME "
$IMAGE_NAME = Read-Host "Enter IMAGE_NAME "
$FOUNDRY_ACCOUNT = Read-Host "Enter FOUNDRY_ACCOUNT "
$PROJECT_NAME = Read-Host "Enter PROJECT_NAME "
$AGENT_NAME = Read-Host "Enter AGENT_NAME "
$AZURE_AI_PROJECT_ENDPOINT = Read-Host "Enter AZURE_AI_PROJECT_ENDPOINT "

Write-Host ""
Write-Host "Now we need AZURE_CREDENTIALS (Service Principal JSON)." -ForegroundColor Yellow
Write-Host "Run this command to create one:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  az ad sp create-for-rbac --name 'github-foundry-cicd' --role contributor --scopes /subscriptions/<sub-id>/resourceGroups/<rg> --sdk-auth" -ForegroundColor Green
Write-Host ""
Write-Host "Paste the JSON below (paste all lines, then type 'END' on a new line and press Enter):" -ForegroundColor Yellow

$jsonLines = @()
while ($true) {
    $line = Read-Host
    if ($line -eq "END") { break }
    $jsonLines += $line
}
$AZURE_CREDENTIALS = $jsonLines -join "`n"

# Set secrets
Write-Host ""
Write-Host "Setting secrets..." -ForegroundColor Cyan

gh secret set ACR_NAME --repo $REPO --body $ACR_NAME
gh secret set IMAGE_NAME --repo $REPO --body $IMAGE_NAME
gh secret set FOUNDRY_ACCOUNT --repo $REPO --body $FOUNDRY_ACCOUNT
gh secret set PROJECT_NAME --repo $REPO --body $PROJECT_NAME
gh secret set AGENT_NAME --repo $REPO --body $AGENT_NAME
gh secret set AZURE_AI_PROJECT_ENDPOINT --repo $REPO --body $AZURE_AI_PROJECT_ENDPOINT
gh secret set AZURE_CREDENTIALS --repo $REPO --body $AZURE_CREDENTIALS

Write-Host ""
Write-Host "✅ All secrets have been added!" -ForegroundColor Green
Write-Host ""
Write-Host "Verify with: gh secret list --repo $REPO" -ForegroundColor Cyan
