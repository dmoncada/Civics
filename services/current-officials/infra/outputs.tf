output "api_base_url" { value = var.environment == "prod" ? "https://civics.dmoncada.net/api/v1" : "${aws_api_gateway_stage.api.invoke_url}/v1" }
output "refresh_function_name" { value = aws_lambda_function.function["refresh"].function_name }
