# API Gateway HTTP API do TaskFlow.
# Recebe chamadas públicas em /api/* e encaminha para o BFF via HTTP_PROXY.
# O gateway não contém regra de negócio nem transforma payloads.

resource "aws_apigatewayv2_api" "taskflow" {
  name          = var.api_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins  = var.frontend_origins
    allow_methods  = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    allow_headers  = ["authorization", "content-type", "x-correlation-id"]
    expose_headers = ["x-correlation-id"]
    max_age        = 86400
  }
}

# Integração HTTP_PROXY com o BFF publicado.
# O parâmetro {proxy} é preenchido a partir da rota /api/{proxy+}.
resource "aws_apigatewayv2_integration" "bff" {
  api_id                 = aws_apigatewayv2_api.taskflow.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = "${var.bff_base_url}/{proxy}"
  payload_format_version = "1.0"
}

# Rota principal do gateway.
# Por padrão, o BFF valida autenticação e autorização. O autorizador JWT de borda é opcional.
resource "aws_apigatewayv2_route" "proxy" {
  api_id             = aws_apigatewayv2_api.taskflow.id
  route_key          = "ANY /api/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.bff.id}"
  authorization_type = var.enable_jwt_authorizer ? "JWT" : "NONE"
  authorizer_id      = var.enable_jwt_authorizer ? aws_apigatewayv2_authorizer.jwt[0].id : null
}

# Estágio padrão com deploy automático.
# Como o estágio é $default, a URL pública não recebe sufixo de estágio.
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.taskflow.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 50
    throttling_rate_limit  = 100
  }

  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []

    content {
      destination_arn = aws_cloudwatch_log_group.gw[0].arn
      format = jsonencode({
        requestId       = "$context.requestId"
        sourceIp        = "$context.identity.sourceIp"
        httpMethod      = "$context.httpMethod"
        path            = "$context.path"
        status          = "$context.status"
        responseLatency = "$context.responseLatency"
      })
    }
  }
}