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
  alarm_name                = "${var.cluster_identifier}-cpu-utilization"
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
  alarm_name                = "${var.cluster_identifier}-freeable-memory"
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

resource "aws_cloudwatch_metric_alarm" "cluster_volume_read_iops" {
  alarm_name                = "${var.cluster_identifier}-cluster-volume-read-iops"
  actions_enabled           = var.actions_enabled
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["ClusterVolumeReadIOPsEvaluationPeriods"]
  metric_name               = "VolumeReadIOPs"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Average"
  threshold                 = local.thresholds["ClusterVolumeReadIOPsThreshold"]
  alarm_description         = "Cluster average volume read IOPS exceeded threshold."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBClusterIdentifier = var.cluster_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_volume_write_iops" {
  alarm_name                = "${var.cluster_identifier}-volume-write-iops"
  actions_enabled           = var.actions_enabled
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["ClusterVolumeWriteIOPsEvaluationPeriods"]
  metric_name               = "VolumeWriteIOPs"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Average"
  threshold                 = local.thresholds["ClusterVolumeWriteIOPsThreshold"]
  alarm_description         = "Cluster average write IOPS exceeded threshold."
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
resource "aws_cloudwatch_metric_alarm" "instance_volume_read_iops" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name                = "${each.key}-instance-volume-read-iops"
  actions_enabled           = var.actions_enabled
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["InstanceVolumeReadIOPsEvaluationPeriods"]
  metric_name               = "VolumeReadIOPs"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Average"
  threshold                 = local.thresholds["InstanceVolumeReadIOPsThreshold"]
  alarm_description         = "Instance average volume read IOPS exceeded threshold."
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
  alarm_name                = "${each.key}-instance-volume-write-iops"
  actions_enabled           = var.actions_enabled
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["InstanceVolumeWriteIOPsEvaluationPeriods"]
  metric_name               = "VolumeWriteIOPs"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Average"
  threshold                 = local.thresholds["InstanceVolumeWriteIOPsThreshold"]
  alarm_description         = "Instance average write IOPS exceeded threshold."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_volume_bytes_used" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name                = "${each.key}-instance-volume-bytes-used"
  actions_enabled           = var.actions_enabled
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["InstanceVolumeBytesUsedEvaluationPeriods"]
  metric_name               = "VolumeBytesUsed"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Average"
  threshold                 = local.thresholds["InstanceVolumeBytesUsedThreshold"]
  alarm_description         = "Instance volume bytes used exceeded threshold."
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
  alarm_name                = "${each.key}-backup-retention-period-storage-used"
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
  alarm_name                = "${each.key}-total-backup-storage-billed"
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
  alarm_name          = "${each.key}-serverless-database-capacity-high"
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
  alarm_name          = "${each.key}-replica-lag-high"
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
  alarm_name          = "${each.key}-acu-utilization-high"
  actions_enabled     = var.actions_enabled
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.thresholds["ACUUtilizationEvaluationPeriods"]
  metric_name         = "ACUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = local.thresholds["ACUUtilizationThreshold"]
  alarm_description   = "Aurora Capacity Units (ACU) utilization has exceeded threshold. Consider increasing ACU max-capacity."
  alarm_actions       = [data.aws_sns_topic.topic.arn]
  ok_actions          = [data.aws_sns_topic.topic.arn]
  tags                = var.tags
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "database_connections" {
  for_each            = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name          = "${each.key}-database-connections-high"
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

  alarm_name                = "${each.key}-instance-freeable-memory-low"
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
  alarm_name                = "${each.key}-instance-temp-storage-iops-high"
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

resource "aws_cloudwatch_metric_alarm" "instance_disk_queue_depth" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name                = "${each.key}-disk-queue-depth-high"
  actions_enabled           = var.actions_enabled
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["InstanceDiskQueueDepthEvaluationPeriods"]
  metric_name               = "DiskQueueDepth"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = local.thresholds["InstanceDiskQueueDepthThreshold"]
  alarm_description         = "Disk Queue Depth is high on this instance."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "connection_attempts_high" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  alarm_name                = "${each.key}-connection-attempts-high"
  actions_enabled           = var.actions_enabled
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["ConnectionAttemptsEvaluationPeriods"]
  metric_name               = "ConnectionAttempts"
  namespace                 = local.cloudwatch_namespace
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = local.thresholds["ConnectionAttemptsThreshold"]
  alarm_description         = "Connection Attempts (successful and unsuccessful) is high on this instance."
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  ok_actions                = [data.aws_sns_topic.topic.arn]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}
