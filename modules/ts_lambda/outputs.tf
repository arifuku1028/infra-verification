output "lambda_function" {
  value = {
    arn  = aws_lambda_function.this.arn
    name = aws_lambda_function.this.function_name
  }
}

output "lambda_role" {
  value = {
    arn  = aws_iam_role.lambda.arn
    name = aws_iam_role.lambda.name
  }
  
}
