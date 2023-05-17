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

# variable "dns_zone_name" {
#   type        = string
#   description = "(Required) The DNS zone name."
#   default     = "mrb-autogpt.com"
# }
