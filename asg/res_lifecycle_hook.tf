resource "aws_autoscaling_lifecycle_hook" "launch" {
  name                   = "attach-eni-hook"
  autoscaling_group_name = aws_autoscaling_group.this.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  default_result         = "ABANDON"
  heartbeat_timeout      = 300
}

resource "aws_cloudwatch_event_rule" "launch" {
  name        = "${local.prefix}-asg-lifecycle-launch-event"
  description = "Event triggered when an instance is launched in the Auto Scaling Group"
  event_pattern = jsonencode({
    source      = ["aws.autoscaling"],
    detail-type = ["EC2 Instance-launch Lifecycle Action"],
    detail = {
      AutoScalingGroupName = [aws_autoscaling_group.this.name]
    }
  })
}

resource "aws_cloudwatch_event_target" "launch" {
  rule = aws_cloudwatch_event_rule.launch.name
  arn  = aws_lambda_function.eni_failover.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "${local.prefix}-eni-failover-permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eni_failover.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.launch.arn
}
