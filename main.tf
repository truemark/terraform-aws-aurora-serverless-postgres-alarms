# This is the SNS topic all events and alerts go to.
data "aws_sns_topic" "topic" {
  name = var.sns_topic_name
}

data "aws_rds_cluster" "cluster" {
  cluster_identifier = var.cluster_identifier
}

locals {
  cloudwatch_namespace = "AWS/RDS"
}

#------------------------------------------------------------------------------
# Generate an rds instance event sub that publishes to the sns topic.
resource "aws_db_event_subscription" "instance_sub" {
  name        = "${data.aws_rds_cluster.cluster.cluster_identifier}-instances"
  sns_topic   = data.aws_sns_topic.topic.arn
  source_type = "db-instance"
  source_ids  = data.aws_rds_cluster.cluster.cluster_members
  tags        = var.tags
  event_categories = [
    "availability",
    "backtrack",
    "configuration change",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "notification",
    "read replica",
    "recovery",
    "restoration",
    "security",
    "security patching"
  ]
}

# Generate an rds cluster event sub that publishes to the sns topic.
resource "aws_db_event_subscription" "cluster_sub" {
  name        = "${data.aws_rds_cluster.cluster.cluster_identifier}-cluster"
  sns_topic   = data.aws_sns_topic.topic.arn
  source_type = "db-cluster"
  source_ids  = [data.aws_rds_cluster.cluster.cluster_identifier]
  tags        = var.tags
  event_categories = [
    "configuration change",
    "deletion",
    "failover",
    "failure",
    "global-failover",
    "maintenance",
    "migration",
    "notification",
    "serverless"
  ]
}
#------------------------------------------------------------------------------
# The code below defines cluster alarms based upon Cloudwatch metrics.
resource "aws_cloudwatch_metric_alarm" "cluster_cpu_utilization" {
  alarm_name                = "${var.cluster_identifier}_cpu_utilization"
  actions_enabled           = var.actions_enabled
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["ClusterCPUUtilizationEvaluationPeriods"]
  metric_name               = "CPUUtilization"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = local.thresholds["ClusterCPUUtilizationThreshold"]
  alarm_description         = "Serverless cluster CPU utilization exceeded threshold."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBClusterIdentifier = var.cluster_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_freeable_memory" {
  alarm_name                = "${var.cluster_identifier}_freeable_memory"
  actions_enabled           = var.actions_enabled
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["ClusterFreeableMemoryEvaluationPeriods"]
  metric_name               = "FreeableMemory"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Minimum"
  threshold                 = local.thresholds["ClusterFreeableMemoryThreshold"]
  alarm_description         = "Serverless cluster CPU freeable memory exceeded threshold."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBClusterIdentifier = var.cluster_identifier
  }
}



#------------------------------------------------------------------------------
# The code below defines instance alarms based upon Cloudwatch metrics.
resource "aws_cloudwatch_metric_alarm" "volume_read_iops" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name                = "${each.key}_volume_read_iops"
  actions_enabled           = var.actions_enabled
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
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "volume_write_iops" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name                = "${each.key}_volume_write_iops"
  actions_enabled           = var.actions_enabled
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
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "volume_bytes_used" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name                = "${each.key}_volume_bytes_used"
  actions_enabled           = var.actions_enabled
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
    DBInstanceIdentifier = each.key
  }
}


resource "aws_cloudwatch_metric_alarm" "backup_retention_period_storage_used" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name                = "${each.key}_backup_retention_period_storage_used"
  actions_enabled           = var.actions_enabled
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
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "total_backup_storage_billed" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name                = "${each.key}_total_backup_storage_billed"
  actions_enabled           = var.actions_enabled
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
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "serverless_database_capacity" {
  for_each            = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name          = "${each.key}_serverless_database_capacity_high"
  actions_enabled     = var.actions_enabled
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
    DBInstanceIdentifier = each.key
  }
}

# This is only relevant on the reader. TODO: Change this to only create this on the reader.
resource "aws_cloudwatch_metric_alarm" "replica_lag" {
  for_each            = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name          = "${each.key}_replica_lag_high"
  actions_enabled     = var.actions_enabled
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.thresholds["ReplicationLagEvaluationPeriods"]
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = local.thresholds["ReplicationLagThreshold"]
  alarm_description   = "Aurora Replica Lag has exceeded threshold. Consider increasing ACU on the reader."
  alarm_actions       = [data.aws_sns_topic.topic.arn]
  ok_actions          = [data.aws_sns_topic.topic.arn]
  tags                = var.tags
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "acu_utilization" {
  for_each            = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name          = "${each.key}_acu_utilization_high"
  actions_enabled     = var.actions_enabled
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.thresholds["ACUUtilizationEvaluationPeriods"]
  metric_name         = "ACUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = local.thresholds["ACUUtilizationThreshold"]
  alarm_description   = "Aurora Capacity Units (ACU) utilization has exceeded threshold. Consider increasing ACU max_capacity."
  alarm_actions       = [data.aws_sns_topic.topic.arn]
  ok_actions          = [data.aws_sns_topic.topic.arn]
  tags                = var.tags
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "database_connections" {
  for_each            = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name          = "${each.key}_database_connections_high"
  actions_enabled     = var.actions_enabled
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.thresholds["DatabaseConnectionsEvaluationPeriods"]
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = local.thresholds["DatabaseConnectionsThreshold"]
  alarm_description   = "The number of connections to this database instance is reaching threshold."
  alarm_actions       = [data.aws_sns_topic.topic.arn]
  ok_actions          = [data.aws_sns_topic.topic.arn]
  tags                = var.tags
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_freeable_memory" {
  for_each = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }

  alarm_name                = "${each.key}_freeable_memory_low"
  actions_enabled           = var.actions_enabled
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = local.thresholds["InstanceFreeableMemoryEvaluationPeriods"]
  metric_name               = "FreeableMemory"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Minimum"
  threshold                 = local.thresholds["InstanceFreeableMemoryThreshold"]
  alarm_description         = "Instance freeable memory is low. Examine performance and/or increase max ACU."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_temp_storage_iops" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name                = "${each.key}_instance_temp_storage_iops_high"
  actions_enabled           = var.actions_enabled
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["InstanceTempStorageIopsEvaluationPeriods"]
  metric_name               = "TempStorageIOPS"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = local.thresholds["InstanceTempStorageIopsThreshold"]
  alarm_description         = "IOPS on local storage is high."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

