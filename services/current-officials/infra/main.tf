data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  prefix       = "civics-officials-${var.environment}"
  prod         = var.environment == "prod"
  zip          = "${path.module}/../dist/current-officials.zip"
  lambda_names = toset(["api", "refresh", "attestation", "authorizer"])
}

resource "aws_dynamodb_table" "officials" {
  name         = "${local.prefix}-officials"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  point_in_time_recovery { enabled = true }
}
resource "aws_dynamodb_table" "attest" {
  name         = "${local.prefix}-app-attest"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }
  point_in_time_recovery { enabled = true }
}
resource "aws_ssm_parameter" "congress" {
  name  = "/civics/${var.environment}/congress-api-key"
  type  = "SecureString"
  value = "managed-outside-tofu"
  lifecycle { ignore_changes = [value] }
}
resource "aws_ssm_parameter" "test_key" {
  name  = "/civics/${var.environment}/current-officials-test-key"
  type  = "SecureString"
  value = "managed-outside-tofu"
  lifecycle { ignore_changes = [value] }
}
resource "aws_iam_role" "lambda" {
  for_each           = local.lambda_names
  name               = "${local.prefix}-${each.key}"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "logs" {
  for_each   = local.lambda_names
  role       = aws_iam_role.lambda[each.key].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_cloudwatch_log_group" "lambda" {
  for_each          = local.lambda_names
  name              = "/aws/lambda/${local.prefix}-${each.key}"
  retention_in_days = 30
}
resource "aws_iam_role_policy" "runtime" {
  for_each = aws_iam_role.lambda
  name     = "${each.key}-runtime"
  role     = each.value.id
  policy = jsonencode({ Version = "2012-10-17", Statement = concat(
    each.key == "api" ? [{ Effect = "Allow", Action = ["dynamodb:GetItem"], Resource = aws_dynamodb_table.officials.arn }] : [],
    each.key == "refresh" ? [{ Effect = "Allow", Action = ["dynamodb:PutItem"], Resource = aws_dynamodb_table.officials.arn }, { Effect = "Allow", Action = ["ssm:GetParameter"], Resource = aws_ssm_parameter.congress.arn }] : [],
    contains(["attestation", "authorizer"], each.key) ? [{ Effect = "Allow", Action = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:UpdateItem"], Resource = aws_dynamodb_table.attest.arn }] : [],
    each.key == "authorizer" ? [{ Effect = "Allow", Action = ["ssm:GetParameter"], Resource = aws_ssm_parameter.test_key.arn }] : []
  ) })
}
resource "aws_lambda_function" "function" {
  for_each         = { api = "src.api.lambda_handler", refresh = "src.refresh.lambda_handler", attestation = "src.attestation.lambda_handler", authorizer = "src.attestation.authorizer_handler" }
  function_name    = "${local.prefix}-${each.key}"
  role             = aws_iam_role.lambda[each.key].arn
  runtime          = "python3.13"
  handler          = each.value
  filename         = local.zip
  source_code_hash = filebase64sha256(local.zip)
  timeout          = each.key == "refresh" ? 120 : 15
  environment { variables = merge({ CONGRESSIONAL_TABLE_NAME = aws_dynamodb_table.officials.name }, contains(["attestation", "authorizer"], each.key) ? { APP_ATTEST_TABLE_NAME = aws_dynamodb_table.attest.name, APP_ATTEST_APP_ID = "E76XSQA67L.com.davidmoncada.Civics", TEST_API_KEY_PARAMETER = aws_ssm_parameter.test_key.name } : {}, each.key == "refresh" ? { CONGRESS_API_KEY_PARAMETER = aws_ssm_parameter.congress.name } : {}) }
  depends_on = [aws_cloudwatch_log_group.lambda]
}
resource "aws_api_gateway_rest_api" "api" {
  name                         = local.prefix
  disable_execute_api_endpoint = local.prod
  endpoint_configuration { types = ["REGIONAL"] }
}
resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "officials" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "current-officials"
}
resource "aws_api_gateway_authorizer" "attest" {
  count                            = local.prod ? 1 : 0
  name                             = "app-attest"
  rest_api_id                      = aws_api_gateway_rest_api.api.id
  type                             = "REQUEST"
  authorizer_uri                   = "arn:${data.aws_partition.current.partition}:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.function["authorizer"].arn}/invocations"
  authorizer_result_ttl_in_seconds = 0
}
resource "aws_api_gateway_method" "officials" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.officials.id
  http_method   = "GET"
  authorization = local.prod ? "CUSTOM" : "NONE"
  authorizer_id = local.prod ? aws_api_gateway_authorizer.attest[0].id : null
}
resource "aws_api_gateway_integration" "officials" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.officials.id
  http_method             = aws_api_gateway_method.officials.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.function["api"].invoke_arn
}
resource "aws_lambda_permission" "api" {
  for_each      = aws_lambda_function.function
  statement_id  = "ApiGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*"
}
resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers    = { redeployment = sha1(aws_api_gateway_integration.officials.id) }
  lifecycle { create_before_destroy = true }
}
resource "aws_api_gateway_stage" "api" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api.id
  stage_name    = var.environment
}
resource "aws_cloudwatch_event_rule" "refresh" {
  name                = "${local.prefix}-daily-refresh"
  schedule_expression = "rate(1 day)"
}
resource "aws_cloudwatch_event_target" "refresh" {
  rule = aws_cloudwatch_event_rule.refresh.name
  arn  = aws_lambda_function.function["refresh"].arn
}
resource "aws_lambda_permission" "refresh" {
  statement_id  = "EventBridgeRefresh"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function["refresh"].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.refresh.arn
}
