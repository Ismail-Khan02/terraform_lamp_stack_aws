resource "aws_cloudwatch_log_group" "lamp_log_group" {
  name              = "/ec2/lamp/user-data"
  retention_in_days = 7

  tags = {
    Name = "LAMP_Log_Group"
    Environment = var.environment
  }
  
}

resource "aws_sns_topic" "lamp_notifications" {
  name = "lamp-notifications"

  tags = {
    Name = "LAMP_Notifications"
    Environment = var.environment
  }
  
}

resource "aws_sns_topic_subscription" "lamp_subscription" { 
  topic_arn = aws_sns_topic.lamp_notifications.arn
  protocol  = "email"
  endpoint  = var.alert_email
  
}

resource "aws_cloudwatch_metric_alarm" "lamp_cpu_utilization" {
  alarm_name          = "LAMP_CPU_Utilization_Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_actions = [aws_sns_topic.lamp_notifications.arn]

  alarm_description   = "This alarm triggers when CPU utilization exceeds 80% for 10 minutes."
  
  dimensions = {
    InstanceId = aws_instance.lamp_instance.id
  }

  tags = {
    Name = "LAMP_CPU_Alarm"
    Environment = var.environment
  }
  
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  alarm_name          = "LAMP_Status_Check_Failed_Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 0
  alarm_actions = [aws_sns_topic.lamp_notifications.arn]

  alarm_description   = "This alarm triggers when the instance fails status checks."

  dimensions = {
    InstanceId = aws_instance.lamp_instance.id
  }

  tags = {
    Name = "LAMP_Status_Check_Alarm"
    Environment = var.environment
  }
  
}