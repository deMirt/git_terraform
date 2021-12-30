variable "region" {
  description = "AWS Region to deploy Server"
  default     = "us-east-2"
  type        = string
}

variable "allow_ports" {
  description = "List of ports to open for server"
  default     = ["80", "443", "22", "8080"]
  type        = list(any)
}
