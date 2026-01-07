variable "domain_name" {
  type        = string
}
variable "app_port" {
  type    = number
  default = 3000
}


variable "grafana_url" {
  description = "Grafana Cloud Prometheus Remote Write URL"
  type        = string
}

variable "grafana_user" {
  description = "Grafana Cloud Prometheus Username"
  type        = string
}

variable "grafana_password" {
  description = "Grafana Cloud API Key / Token"
  type        = string
  sensitive   = true
}