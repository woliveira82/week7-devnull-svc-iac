# Infra (Terraform)

Provisions the Azure resources for the Dev Null Service:

- Resource Group
- Storage Account (required by the Functions host)
- Log Analytics Workspace + Application Insights
- Storage container `deployments` (holds the Flex deployment package)
- Flex Consumption plan (`FC1`)
- Function App on Flex Consumption (Functions v4, Node.js)

Terraform creates the infrastructure; the code is published with Azure Functions Core Tools.

## Cost (free tier)

The defaults are tuned to stay within Azure's free allowances:

| Resource | Free allowance | How the config stays inside it |
|---|---|---|
| Flex Consumption | 100,000 GB-s + 250,000 executions / month (on-demand) | 512 MB instances, max 1 instance, no always-ready instances |
| Log Analytics / App Insights | 5 GB ingestion / month, 31 days retention | 0.1 GB/day cap, 30 days retention, sampling in `host.json` |
| Storage Account | Not free (cents/month at this scale) | Standard LRS, one small container |
| Budget | Free | Alerts on any actual spend over 1 and on forecast over budget |

Set `budget_alert_emails` in `terraform.tfvars` to enable the budget alert. Budgets only notify; they don't stop resources.

## Prerequisites

- Terraform >= 1.5
- Azure CLI, signed in (`az login`)

## Deploy

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars   # set subscription_id (az account show --query id -o tsv)
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

## Publish the function code

From the repository root:

```bash
npm run build
func azure functionapp publish "$(terraform -chdir=infra output -raw function_app_name)"
```

## Smoke test

```bash
URL=$(terraform -chdir=infra output -raw function_app_url)
KEY=$(terraform -chdir=infra output -raw default_function_key)

curl -i "$URL/api/health"

curl -i -X POST "$URL/integration/events/product-updated" \
  -H "Content-Type: application/json" \
  -H "x-functions-key: $KEY" \
  --data-binary @samples/post-product-updated.json
```

## Tear down

```bash
terraform -chdir=infra destroy
```
