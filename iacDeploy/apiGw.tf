####Create rest API GW
resource "aws_api_gateway_rest_api" "api" {
  description = "Automated by TF"
  name        = "${var.resource_name}"
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "Flask Lab"
      version = "1.0"
    }
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
#### Create the resource which will be proxy
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id # In this case, the parent id should the gateway root_resource_id.
  path_part   = "{proxy+}"
}
#### Create the methods to be used. Here i've set ANY in the frontend as a test purpose
resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}
#### Once the resource and methods are create, deploy API base on the new resource and method created
resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_integration.integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
#### Create to the next step to create a dev stage with the deployment created above
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"
}
#### Integrate the Lambda function with the API GW with type PROXY
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"  ##When integrating the api_gw, we must used POST (Frontend is ANY and BAckend should be POST)
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.function.invoke_arn
}
#### Create a model reponse to be used by the gateway method response and gateway integration response
resource "aws_api_gateway_model" "model" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  name = "Empty"
  description = "This is a default empty schema mode"
  content_type = "application/json"
  schema = "{\n  \"$schema\": \"http://json-schema.org/draft-04/schema#\",\n  \"title\": \"Empty Schema\",\n  \"type\": \"object\"\n}"
}
#### Create the gateway method response
resource "aws_api_gateway_method_response" "response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.method.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.model.name
  }
}
#### Create the gateway integration response with status code and response template same as the method response
resource "aws_api_gateway_integration_response" "response_method_integration" {
  depends_on = [
    aws_api_gateway_integration.integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method_response.response.http_method
  status_code = aws_api_gateway_method_response.response.status_code
  response_templates = {
    "application/json" = aws_api_gateway_model.model.name
  }
}
