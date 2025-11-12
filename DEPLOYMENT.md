# FastMCP Server - Two-Phase Deployment

This project uses a two-phase deployment approach to separate infrastructure provisioning from application deployment.

## Phase 1: Infrastructure Setup

Creates the foundational Azure resources:
- Azure Container Registry (ACR)
- Container Apps Environment
- Log Analytics Workspace

### Run Infrastructure Setup

```bash
# Navigate to project directory
cd /path/to/fastmcp-server-first

# Run infrastructure setup
bash ./infra/setup-infra.sh
```

This script will:
1. Prompt for Azure login (if needed)
2. Let you select Azure subscription
3. Create a resource group
4. Deploy infrastructure resources
5. Save deployment information to `deployment-info.sh`

## Phase 2: Container Deployment

Builds and deploys the application:
- Builds Docker image
- Pushes image to Azure Container Registry
- Creates Container App

### Run Container Deployment

**Bash Script**
```bash
bash ./infra/deploy-container.sh
```

This script will:
1. Load deployment information from Phase 1
2. Build the Docker image
3. Push image to Azure Container Registry
4. Deploy the Container App
5. Provide application endpoints for testing

## Benefits of Two-Phase Approach

1. **Separation of Concerns**: Infrastructure and application deployments are independent
2. **Faster Iterations**: Redeploy applications without recreating infrastructure
3. **Cost Efficiency**: Infrastructure resources persist while applications can be updated
4. **Better CI/CD**: Different pipelines for infrastructure vs application changes

## Project Structure

```
infra/
├── setup-infra.sh              # Phase 1: Infrastructure setup
├── deploy-container.sh         # Phase 2: Container deployment (Bash)
├── infrastructure.resources.bicep  # Infrastructure Bicep template
├── container-app.resources.bicep   # Container App Bicep template
└── container.resources.bicep   # Original combined template (legacy)
```

## Testing Your Deployment

After successful deployment, test your application:

```bash
# Health check
curl https://your-app-fqdn/health

# MCP endpoint  
curl https://your-app-fqdn/mcp
```

## Redeployment

To update your application:
1. Make code changes
2. Run Phase 2 deployment again: `bash ./infra/deploy-container.sh`

Infrastructure resources will remain unchanged, only the application will be redeployed with a new image version.