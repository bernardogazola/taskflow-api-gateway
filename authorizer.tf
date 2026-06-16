# Recursos opcionais de segurança e observabilidade.
# Com os valores padrão, o gateway fica público e o BFF permanece responsável pela validação do JWT.

resource "aws_apigatewayv2_authorizer" "jwt" {
  count            = var.enable_jwt_authorizer ? 1 : 0
  api_id           = aws_apigatewayv2_api.taskflow.id
  authorizer_type  = "JWT"
  name             = "taskflow-jwt"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer   = var.jwt_issuer
    audience = var.jwt_audience
  }

  lifecycle {
    precondition {
      condition     = var.jwt_issuer != "" && length(var.jwt_audience) > 0
      error_message = "Para habilitar enable_jwt_authorizer, informe jwt_issuer e ao menos uma entrada em jwt_audience."
    }
  }
}

# Rota pública para autenticação quando o autorizador JWT estiver habilitado.
# Assim login e cadastro continuam acessíveis sem token.
resource "aws_apigatewayv2_route" "auth_public" {
  count              = var.enable_jwt_authorizer ? 1 : 0
  api_id             = aws_apigatewayv2_api.taskflow.id
  route_key          = "ANY /api/auth/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.bff.id}"
  authorization_type = "NONE"
}

# Log group opcional para logs de acesso do API Gateway.
resource "aws_cloudwatch_log_group" "gw" {
  count             = var.enable_access_logs ? 1 : 0
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = 14
}