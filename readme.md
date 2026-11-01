# Dev Null Service

This service exposes endpoints that accept integration events and discards them after logging. It's useful for local testing, demos, or as a placeholder sink.

## Tech stack

- Azure Functions v4 (Node.js)
- TypeScript (compiled to `dist/`)
- Azure Functions Programming Model v4 (`@azure/functions`)

## Local setup

1. Install dependencies

```bash
npm install
```

2. Create local settings from template

```bash
cp local.settings.template.json local.settings.json
```

3. Build

```bash
npm run build
```

4. Start the Functions host

```bash
npm start
```

Host listens on `http://localhost:7071` by default.

## Deploy to Azure

Infrastructure is managed with Terraform in [`infra/`](infra/) (Resource Group, Storage Account, Application Insights, Flex Consumption plan and Function App). Defaults are tuned to stay within Azure's free allowances; see [`infra/README.md`](infra/README.md) for details.

Prerequisites: Terraform >= 1.5, Azure CLI, Azure Functions Core Tools (installed as a dev dependency).

1. Sign in and select subscription

```bash
az login
az account show --query id --output tsv
```

2. Configure variables

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
```

Set `subscription_id` (from the previous step) and, optionally, `location` and `budget_alert_emails`.

3. Provision the infrastructure

```bash
terraform -chdir=infra init
terraform -chdir=infra plan -out tfplan
terraform -chdir=infra apply tfplan
```

4. Publish the code

Terraform creates an empty Function App; the code is published with Core Tools:

```bash
npm run build
npx func azure functionapp publish "$(terraform -chdir=infra output -raw function_app_name)"
```

5. Read the app URL and function key

```bash
terraform -chdir=infra output -raw function_app_url
terraform -chdir=infra output -raw default_function_key
```

6. Tear down

```bash
terraform -chdir=infra destroy
```

## Endpoints

- Route prefix is disabled in `host.json`, so there is no `/api` prefix.

### Product Updated

- Method: `POST`
- Path: `/integration/events/product-updated`
- Auth: function-level (host or function keys). Locally you can call without a key if the host is configured to allow it.
- Body schema (JSON):

```json
{
  "id": "string",
  "name": "string",
  "pricePence": 1234,
  "description": "string",
  "updatedAt": "2025-01-01T12:34:56.000Z"
}
```

Notes:

- `updatedAt` must be an ISO 8601 string (Date.toISOString format).
- The service validates the payload and returns 400 on validation errors; otherwise 202 Accepted.

Sample payload file: `samples/post-product-updated.json`.

Without key locally:

```bash
curl -i -X POST http://localhost:7071/integration/events/product-updated \
  -H "Content-Type: application/json" \
  --data-binary @samples/post-product-updated.json
```

With host key in Azure:

```bash
URL=$(terraform -chdir=infra output -raw function_app_url)
KEY=$(terraform -chdir=infra output -raw default_function_key)

curl -i -X POST "$URL/integration/events/product-updated" \
  -H "Content-Type: application/json" \
  -H "x-functions-key: $KEY" \
  --data-binary @samples/post-product-updated.json
```

Expected response:

```http
HTTP/1.1 202 Accepted
{"message":"accepted"}
```

Validation error example:

```http
HTTP/1.1 400 Bad Request
{"error":"ValidationError","details":["updatedAt must be an ISO 8601 string (Date.toISOString)"]}
```
