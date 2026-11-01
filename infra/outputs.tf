output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "function_app_name" {
  description = "Use with `func azure functionapp publish <name>`."
  value       = azurerm_function_app_flex_consumption.this.name
}

output "function_app_url" {
  value = "https://${azurerm_function_app_flex_consumption.this.default_hostname}"
}

output "default_function_key" {
  description = "Host key to send as `x-functions-key`."
  value       = data.azurerm_function_app_host_keys.this.default_function_key
  sensitive   = true
}
