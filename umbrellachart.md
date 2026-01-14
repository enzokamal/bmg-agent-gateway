# BMG Agent Gateway Umbrella Chart

## Introduction

The BMG Agent Gateway is implemented as a Helm umbrella chart, which is a best practice for deploying complex, multi-component applications. An umbrella chart allows you to manage and deploy multiple related components as a single release while maintaining separation of concerns and modularity.

### What is an Umbrella Chart?

An umbrella chart is a Helm chart that contains other charts (subcharts) as dependencies. Instead of having all Kubernetes manifests in a single monolithic chart, the umbrella chart orchestrates the deployment of multiple specialized subcharts. This approach provides:

- **Modularity**: Each component can be developed, tested, and versioned independently
- **Reusability**: Subcharts can be reused in other umbrella charts
- **Maintainability**: Easier to manage complex applications with multiple services
- **CI/CD Ready**: Better suited for automated deployment pipelines

### Chart Structure

```
bmg-agent-gateway/
├── Chart.yaml              # Umbrella chart metadata and dependencies
├── values.yaml             # Global configuration values
├── templates/              # Shared templates (Gateway, Policy)
│   ├── _helpers.tpl        # Shared helper functions
│   ├── gateway-policy.yaml # Authentication policy
│   └── NOTES.txt           # Post-installation notes
└── charts/                 # Subcharts directory
    ├── agent/              # Agent subchart
    │   ├── Chart.yaml
    │   ├── values.yaml
    │   └── templates/
    ├── ui/                 # UI subchart
    │   ├── Chart.yaml
    │   ├── values.yaml
    │   └── templates/
    ├── mcp-hubspot/        # MCP HubSpot subchart
    │   ├── Chart.yaml
    │   ├── values.yaml
    │   └── templates/
    └── mcp-mssql/          # MCP MSSQL subchart
        ├── Chart.yaml
        ├── values.yaml
        └── templates/
```

### Components

1. **Agent**: Core orchestration service that manages MCP server connections
2. **UI**: Web interface for user interaction with the agent system
3. **MCP HubSpot**: MCP server providing HubSpot CRM integration
4. **MCP MSSQL**: MCP server providing Microsoft SQL Server database access
5. **Gateway**: Routes traffic between components and enforces authentication
6. **Policy**: Azure AD authentication policy for secure access

## Prerequisites

Before running the umbrella chart, ensure your Kubernetes cluster meets these requirements:

### Kubernetes Version
- Kubernetes 1.19 or higher

### Helm Version
- Helm 3.0 or higher

### Required Controllers and APIs
- **Gateway API**: Install Gateway API CRDs
  ```bash
  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
  ```
- **Agent Gateway Controller**: Install the Agent Gateway CRDs and controller
  ```bash
  helm upgrade --install agentgateway-crds \
      oci://cr.agentgateway.dev/charts/agentgateway-crds \
      --version v2.2.0-beta.4 \
      --namespace "${AGENTGATEWAY_NAMESPACE}" \
      --create-namespace

  helm upgrade --install agentgateway \
      oci://cr.agentgateway.dev/charts/agentgateway \
      --version v2.2.0-beta.4 \
      --namespace "${AGENTGATEWAY_NAMESPACE}" \
      --create-namespace
  ```

### External Dependencies
- Azure AD application registration
- MSSQL database server
- HubSpot API access

## Installation

### 1. Prepare Your Environment

```bash
# Clone or download the chart
git clone <repository-url>
cd bmg-agent-gateway

# Update dependencies (downloads subcharts)
helm dependency update
```

### 2. Configure Values

Create a `values.yaml` file with your custom configuration:

```yaml
# Namespace for deployment
namespace: "agentgateway-system"

# Azure Configuration
azure:
  clientId: "your-azure-client-id"
  tenantId: "your-azure-tenant-id"

# Agent Configuration
agent:
  secret:
    deepseekApiKey: "your-api-key"

# UI Configuration
ui:
  secret:
    azureClientSecret: "your-client-secret"
    secretKey: "your-secret-key"

# MCP MSSQL Configuration
mcpMssql:
  deployment:
    env:
      mssqlServer: "your-mssql-server"
      mssqlDatabase: "your-database"
      mssqlPort: "1433"
      mssqlUser: "your-username"
      mssqlPassword: "your-password"
```

### 3. Install the Umbrella Chart

```bash
# Dry run first to validate
helm install my-release . --dry-run --debug

# Install with custom values
helm install my-release . -f values.yaml --namespace agentgateway-system --create-namespace
```

### 4. Verify Installation

```bash
# Check all pods
kubectl get pods -n agentgateway-system

# Check services
kubectl get svc -n agentgateway-system

# Check gateway and routes
kubectl get gateway,httproute -n agentgateway-system
```

## Accessing the Application

Once deployed, access the UI through the Gateway:

```bash
# Port forward for local access
kubectl port-forward -n agentgateway-system svc/agentgateway-proxy 8080:8080

# Visit: http://localhost:8080/ui
```

## Subchart Management

### Updating Subcharts

To update a specific subchart:

```bash
# Update dependencies
helm dependency update

# Upgrade the release
helm upgrade my-release . -f values.yaml
```

### Overriding Subchart Values

You can override subchart values in the umbrella chart's `values.yaml`:

```yaml
# Override agent replica count
agent:
  deployment:
    replicas: 3

# Disable a subchart (if supported)
mcp-hubspot:
  enabled: false
```

### Developing Subcharts

For development, you can install subcharts individually:

```bash
# Install only the agent subchart
helm install agent-test ./charts/agent -f agent-values.yaml
```

## Best Practices

### 1. Value Inheritance
- Use the umbrella chart's `values.yaml` for global configuration
- Subcharts should have sensible defaults
- Avoid hardcoding values in templates

### 2. Naming Conventions
- Use consistent naming across subcharts
- Leverage Helm's built-in naming helpers
- Include release name in resource names for multi-tenancy

### 3. Dependency Management
- Keep subchart versions in sync with main chart
- Use version ranges for flexibility
- Test upgrades thoroughly

### 4. Resource Separation
- Each resource type in separate template files
- Use `---` separators if multiple resources per file (not recommended)
- Group related resources logically

### 5. CI/CD Integration
- Use `helm dependency update` in pipelines
- Validate with `helm lint` and `helm template`
- Test installations in staging environments

## Troubleshooting

### Common Issues

1. **Subchart Not Found**: Run `helm dependency update`
2. **Value Conflicts**: Check for duplicate keys in values files
3. **Resource Conflicts**: Ensure unique names across subcharts
4. **Dependency Issues**: Verify subchart versions and compatibility

### Debugging Commands

```bash
# List dependencies
helm dependency list

# Render templates with debug
helm template my-release . --debug

# Check release status
helm status my-release

# View release values
helm get values my-release
```

## Migration from Monolithic Chart

If migrating from a monolithic chart:

1. Extract component manifests into subcharts
2. Create separate `values.yaml` for each subchart
3. Update the umbrella chart to reference subcharts
4. Test thoroughly in staging
5. Update CI/CD pipelines

## References

- [Helm Umbrella Charts](https://helm.sh/docs/chart_template_guide/subcharts_and_globals/)
- [Chart Dependencies](https://helm.sh/docs/helm/helm_dependency/)
- [Gateway API](https://gateway-api.sigs.k8s.io/)
- [Agent Gateway](https://agentgateway.dev/)