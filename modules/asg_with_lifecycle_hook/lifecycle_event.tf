resource "aws_cloudwatch_event_rule" "launch" {
  name        = "${var.prefix}-asg-lifecycle-launch-event"
  description = "Event triggered when an instance is launched in the Auto Scaling Group"
  event_pattern = jsonencode({
    source      = ["aws.autoscaling"],
    detail-type = ["EC2 Instance-launch Lifecycle Action"],
    detail = {
      AutoScalingGroupName = [
        var.asg_name
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "launch" {
  rule = aws_cloudwatch_event_rule.launch.name
  arn  = var.lifecycle_function.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "${var.prefix}-allow-eventbridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lifecycle_function.name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.launch.arn
}
