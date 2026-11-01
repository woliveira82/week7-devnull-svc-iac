variable "subscription_id" {
  description = "Azure subscription ID to deploy into."
  type        = string
}

variable "name" {
  description = "Base name used for all resources (lowercase letters, numbers and hyphens)."
  type        = string
  default     = "devnull-svc"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,40}$", var.name))
    error_message = "name must be 3-40 characters of lowercase letters, numbers and hyphens."
  }
}

variable "location" {
  description = "Azure region for all resources (must be permitted by your subscription policy)."
  type        = string
  default     = "uksouth"
}

variable "node_version" {
  description = "Node.js version for the Functions runtime."
  type        = string
  default     = "22"
}

variable "instance_memory_in_mb" {
  description = "Memory per instance on the Flex Consumption plan (512, 2048 or 4096). Lower memory stretches the monthly free grant."
  type        = number
  default     = 512
}

variable "maximum_instance_count" {
  description = "Upper bound for scale-out on the Flex Consumption plan. Kept low to limit spend."
  type        = number
  default     = 1
}

variable "log_daily_quota_gb" {
  description = "Daily Log Analytics ingestion cap in GB (0.1 GB/day stays under the 5 GB/month free allowance)."
  type        = number
  default     = 0.1
}

variable "monthly_budget_amount" {
  description = "Monthly budget for the resource group, in the subscription's billing currency."
  type        = number
  default     = 1
}

variable "budget_alert_emails" {
  description = "Emails notified by the cost budget. Leave empty to skip creating the budget."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    project = "devnull-svc"
  }
}
