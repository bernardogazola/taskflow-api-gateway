output "gateway_url" {
  description = "URL base pública do API Gateway. As chamadas públicas seguem o formato <gateway_url>/api/..."
  value       = aws_apigatewayv2_api.taskflow.api_endpoint
}

output "api_id" {
  description = "Identificador do HTTP API na AWS."
  value       = aws_apigatewayv2_api.taskflow.id
}

output "stage_invoke_url" {
  description = "URL de invocação do estágio padrão."
  value       = aws_apigatewayv2_stage.default.invoke_url
}