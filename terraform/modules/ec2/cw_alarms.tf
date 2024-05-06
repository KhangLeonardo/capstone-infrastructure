resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "50"
  alarm_description   = "Alarm when CPU utilization exceeds 50%"
  alarm_actions       = [aws_sns_topic.cloudwatch_notifications.arn]
  dimensions = {
    InstanceId = aws_instance.backend_system.id
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_very_high" {
  alarm_name          = "cpu_utilization_very_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.cloudwatch_notifications.arn]
  dimensions = {
    InstanceId = aws_instance.backend_system.id
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  alarm_name          = "memory_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "50"
  alarm_description   = "Alarm when memory utilization exceeds 50%"
  alarm_actions       = [aws_sns_topic.cloudwatch_notifications.arn]
  dimensions = {
    InstanceId = aws_instance.backend_system.id
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_very_high" {
  alarm_name          = "memory_utilization_very_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when memory utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.cloudwatch_notifications.arn]
  dimensions = {
    InstanceId = aws_instance.backend_system.id
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_space_utilization_high" {
  alarm_name          = "disk_space_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "50"
  alarm_description   = "Alarm when disk space utilization exceeds 50%"
  alarm_actions       = [aws_sns_topic.cloudwatch_notifications.arn]
  dimensions = {
    InstanceId = aws_instance.backend_system.id
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_space_utilization_very_high" {
  alarm_name          = "disk_space_utilization_very_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alarm when disk space utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.cloudwatch_notifications.arn]
  dimensions = {
    InstanceId = aws_instance.backend_system.id
  }
}

resource "aws_sns_topic" "cloudwatch_notifications" {
  name = "cloudwatch_notifications"

  tags = merge(var.tags, {
    "Name"               = "cloudwatch_notifications"
    "TERRAFORM:Resource" = "aws_sns_topic"
    "TERRAFORM:Module"   = "ec2"
  })
}
