variable "client_id" {
  description = "Azure Client ID"
}

variable "client_secret" {
  description = "Azure Client Secret"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
}

variable "tenant_id" {
  description = "Azure Tenant ID"
}

variable "prefix" {
  type        = string
  description = "(Required) The prefix to use for all resources in this example"
  default     = "mrb-autogpt"
}

variable "openai_api_key" {
  type        = string
  description = "OpenAI API Key"
  default     = ""
  sensitive   = true
}

variable "vmss_capacity" {
  type        = number
  description = "The initial capacity of the VM Scale Set"
  default     = 2
}

variable "vmss_min_capacity" {
  type        = number
  description = "The minimum capacity of the VM Scale Set"
  default     = 1
}

variable "vmss_max_capacity" {
  type        = number
  description = "The maximum capacity of the VM Scale Set"
  default     = 5
}
