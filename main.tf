# This is the SNS topic all events and alerts go to.
data "aws_sns_topic" "topic" {
  name = var.sns_topic_name
}

locals {
  cloudwatch_namespace = "AWS/RDS"
}

#------------------------------------------------------------------------------
# Generate an rds instance event sub that publishes to the sns topic.
resource "aws_db_event_subscription" "cluster_sub" {
  name        = var.db_instance_id
  sns_topic   = data.aws_sns_topic.topic.arn
  source_type = "db-cluster"
  source_ids  = [var.db_instance_id]
  tags        = var.tags

  event_categories = [
    "configuration change",
    "deletion",
    "failover",
    "failure",
    "global-failover",
    "maintenance",
    "notification",
    "restoration"
  ]

}

#------------------------------------------------------------------------------
# The code below defines alarms based upon Cloudwatch metrics.

resource "aws_cloudwatch_metric_alarm" "volume_read_iops" {
  count                     = var.create_volume_read_iops_alarm ? 1 : 0
  alarm_name                = "${var.db_instance_id}_volume_read_iops"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["VolumeReadIOPsEvaluationPeriods"]
  metric_name               = "VolumeReadIOPs"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Average"
  threshold                 = local.thresholds["VolumeReadIOPsThreshold"]
  alarm_description         = "Serverless average volume read IOPS exceeded threshold."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "volume_write_iops" {
  count                     = var.create_volume_write_iops_alarm ? 1 : 0
  alarm_name                = "${var.db_instance_id}_volume_write_iops"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["VolumeWriteIOPsEvaluationPeriods"]
  metric_name               = "VolumeWriteIOPs"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Average"
  threshold                 = local.thresholds["VolumeWriteIOPsThreshold"]
  alarm_description         = "Serverless average write IOPS exceeded threshold."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "volume_bytes_used" {
  count                     = var.create_volume_bytes_used_alarm ? 1 : 0
  alarm_name                = "${var.db_instance_id}_volume_bytes_used"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["VolumeBytesUsedEvaluationPeriods"]
  metric_name               = "VolumeBytesUsed"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Average"
  threshold                 = local.thresholds["VolumeBytesUsedThreshold"]
  alarm_description         = "Serverless volume bytes used exceeded threshold."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}


resource "aws_cloudwatch_metric_alarm" "backup_retention_period_storage_used" {
  count                     = var.create_backup_retention_period_storage_used_alarm ? 1 : 0
  alarm_name                = "${var.db_instance_id}_backup_retention_period_storage_used"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["BackupRetentionPeriodStorageUsedEvaluationPeriods"]
  metric_name               = "BackupRetentionPeriodStorageUsed"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Average"
  threshold                 = local.thresholds["BackupRetentionPeriodStorageUsedThreshold"]
  alarm_description         = "Serverless backup retention storage usage exceeded threshold."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "total_backup_storage_billed" {
  count                     = var.create_total_backup_storage_billed_alarm ? 1 : 0
  alarm_name                = "${var.db_instance_id}_total_backup_storage_billed"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["BackupRetentionPeriodStorageUsedEvaluationPeriods"]
  metric_name               = "TotalBackupStorageBilled"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Average"
  threshold                 = local.thresholds["BackupRetentionPeriodStorageUsedThreshold"]
  alarm_description         = "Serverless total backup storage billed has exceeded threshold."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  tags                      = var.tags
  treat_missing_data        = "breaching"
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "serverless_database_capacity" {
  count               = var.create_serverless_database_capacity_alarm ? 1 : 0
  alarm_name          = "${var.db_instance_id}_serverless_database_capacity_high"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = local.thresholds["ServerlessDatabaseCapacityEvaluationPeriods"]
  metric_name         = "ServerlessDatabaseCapacity"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = local.thresholds["ServerlessDatabaseCapacityThreshold"]
  alarm_description   = "Serverless database capacity has exceeded threshold."
  alarm_actions       = [data.aws_sns_topic.topic.arn]
  ok_actions          = [data.aws_sns_topic.topic.arn]
  tags                = var.tags
  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}
