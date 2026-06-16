variable "bff_base_url" {
  type        = string
  description = "URL pública HTTPS do BFF implantado. Deve ser informada sem barra ao final."

  validation {
    condition     = startswith(var.bff_base_url, "https://")
    error_message = "A variável bff_base_url deve ser uma URL HTTPS."
  }
}

variable "frontend_origins" {
  type        = list(string)
  description = "Origens permitidas no CORS do gateway, normalmente as URLs públicas do frontend."

  validation {
    condition     = length(var.frontend_origins) > 0
    error_message = "A lista frontend_origins não pode estar vazia."
  }
}

variable "aws_region" {
  type        = string
  description = "Região AWS onde o API Gateway será provisionado."
  default     = "us-east-1"
}

variable "api_name" {
  type        = string
  description = "Nome do recurso HTTP API na AWS."
  default     = "taskflow-gateway"
}

variable "enable_jwt_authorizer" {
  type        = bool
  description = "Habilita o autorizador JWT no API Gateway. Por padrão, a validação do JWT fica no BFF."
  default     = false
}

variable "jwt_issuer" {
  type        = string
  description = "URL do emissor OIDC usada pelo autorizador JWT quando enable_jwt_authorizer estiver habilitado."
  default     = ""
}

variable "jwt_audience" {
  type        = list(string)
  description = "Audiência(s) aceitas pelo autorizador JWT quando enable_jwt_authorizer estiver habilitado."
  default     = []
}

variable "enable_access_logs" {
  type        = bool
  description = "Habilita logs de acesso do gateway no CloudWatch."
  default     = false
}