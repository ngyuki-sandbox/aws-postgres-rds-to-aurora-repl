
resource "aws_cloudwatch_log_metric_filter" "alarm" {
  name           = "errors"
  log_group_name = aws_cloudwatch_log_group.aurora.name

  pattern = <<-EOT
    [date, time, meta="*:ERROR:", ...]
  EOT

  metric_transformation {
    namespace = aws_cloudwatch_metric_alarm.alarm.namespace
    name      = aws_cloudwatch_metric_alarm.alarm.metric_name
    value     = "1"
  }
}

data "aws_sns_topic" "alarm" {
  name = var.sns_topic_name
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name          = "RdsErrorCount"
  alarm_actions       = [data.aws_sns_topic.alarm.arn]
  ok_actions          = [data.aws_sns_topic.alarm.arn]
  namespace           = "CWLog"
  metric_name         = "${aws_rds_cluster.aurora.cluster_identifier}/RdsErrorCount"
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = 60
  threshold           = 6
  evaluation_periods  = 1
}
