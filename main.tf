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
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "Serverless cluster CPU utilization exceeded threshold."
  alarm_name                = "${var.cluster_identifier}-cpu-utilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["ClusterCPUUtilizationEvaluationPeriods"]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  metric_name               = "CPUUtilization"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Maximum"
  tags                      = var.tags
  threshold                 = local.thresholds["ClusterCPUUtilizationThreshold"]
  treat_missing_data        = "breaching"
  dimensions = {
    DBClusterIdentifier = var.cluster_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_freeable_memory" {
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "Serverless cluster CPU freeable memory exceeded threshold."
  alarm_name                = "${var.cluster_identifier}-freeable-memory"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = local.thresholds["ClusterFreeableMemoryEvaluationPeriods"]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  metric_name               = "FreeableMemory"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Minimum"
  tags                      = var.tags
  threshold                 = local.thresholds["ClusterFreeableMemoryThreshold"]
  treat_missing_data        = "breaching"
  dimensions = {
    DBClusterIdentifier = var.cluster_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_volume_read_iops" {
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "Cluster average volume read IOPS exceeded threshold."
  alarm_name                = "${var.cluster_identifier}-cluster-volume-read-iops"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["ClusterVolumeReadIOPSEvaluationPeriods"]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  metric_name               = "VolumeReadIOPs"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Average"
  tags                      = var.tags
  threshold                 = local.thresholds["ClusterVolumeReadIOPSThreshold"]
  treat_missing_data        = "breaching"
  dimensions = {
    DBClusterIdentifier = var.cluster_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_volume_write_iops" {
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "Cluster average write IOPS exceeded threshd."
  alarm_name                = "${var.cluster_identifier}-volume-write-iops"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["ClusterVolumeWriteIOPSEvaluationPeriods"]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  metric_name               = "VolumeWriteIOPS"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Average"
  tags                      = var.tags
  threshold                 = local.thresholds["ClusterVolumeWriteIOPSThreshold"]
  treat_missing_data        = "breaching"
  dimensions = {
    DBClusterIdentifier = var.cluster_identifier
  }
}

# resource "aws_cloudwatch_metric_alarm" "cluster_volume_bytes_used" {
#   alarm_name                = "${var.cluster_identifier}-instance-volume-bytes-used"
#   actions_enabled           = var.actions_enabled
#   comparison_operator       = "ThanThreshold"
#   evaluation_periods        = local.thresholds["ClusterVolumeBytesUsedEvaluationPeriods"]
#   metric_name               = "VolumeBytesUsed"
#   namespace                 = local.cloudwatch_namespace
#   period                    = "60"
#   statistic                 = "Average"
#   threshold                 = local.thresholds["ClusterVolumeBytesUsedThreshold"]
#   alarm_description         = "Instance volume bytes used exceeded threshold."
#   alarm_actions             = [data.aws_sns_topic.topic.arn]
#   ok_actions                = [data.aws_sns_topic.topic.arn]
#   insufficient_data_actions = [data.aws_sns_topic.topic.arn]
#   treat_missing_data        = "breaching"
#   tags                      = var.tags
#   dimensions = {
#     DBClusterIdentifier = var.cluster_identifier
#   }
# }

resource "aws_cloudwatch_metric_alarm" "backup_retention_period_storage_used" {
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "Serverless backup retention storage usage exceeded threshold."
  alarm_name                = "${var.cluster_identifier}-backup-retention-period-storage-used"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["BackupRetentionPeriodStorageUsedEvaluationPeriods"]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  metric_name               = "BackupRetentionPeriodStorageUsed"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Average"
  tags                      = var.tags
  threshold                 = local.thresholds["BackupRetentionPeriodStorageUsedThreshold"]
  treat_missing_data        = "breaching"
  dimensions = {
    DBClusterIdentifier = var.cluster_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_temp_storage_iops" {
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "Cluster IOPS on local storage is high."
  alarm_name                = "${var.cluster_identifier}-cluster-temp-storage-iops-high"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["ClusterTempStorageIopsEvaluationPeriods"]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  metric_name               = "TempStorageIOPS"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Maximum"
  tags                      = var.tags
  threshold                 = local.thresholds["ClusterTempStorageIopsThreshold"]
  treat_missing_data        = "breaching"
  dimensions = {
    DBClusterIdentifier = var.cluster_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "total_backup_storage_billed" {
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "Serverless total backup storage billed has exceeded threshold."
  alarm_name                = "${var.cluster_identifier}-total-backup-storage-billed"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["BackupRetentionPeriodStorageUsedEvaluationPeriods"]
  insufficient_data_actions = []
  metric_name               = "TotalBackupStorageBilled"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Average"
  tags                      = var.tags
  threshold                 = local.thresholds["BackupRetentionPeriodStorageUsedThreshold"]
  treat_missing_data        = "breaching"
  dimensions = {
    DBClusterIdentifier = var.cluster_identifier
  }
}

#------------------------------------------------------------------------------
# The code below defines instance alarms based upon Cloudwatch metrics.
resource "aws_cloudwatch_metric_alarm" "instance_read_iops" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "Instance average  read IOPS exceeded threshold."
  alarm_name                = "${each.key}-instance-read-iops"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["InstanceReadIOPSEvaluationPeriods"]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  metric_name               = "ReadIOPS"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Average"
  tags                      = var.tags
  threshold                 = local.thresholds["InstanceReadIOPSThreshold"]
  treat_missing_data        = "breaching"
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_write_iops" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "Instance average write IOPS exceeded threshold."
  alarm_name                = "${each.key}-instance-write-iops"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["InstanceWriteIOPSEvaluationPeriods"]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  metric_name               = "WriteIOPS"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Average"
  tags                      = var.tags
  threshold                 = local.thresholds["InstanceWriteIOPSThreshold"]
  treat_missing_data        = "breaching"
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "serverless_database_capacity" {
  for_each            = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  actions_enabled     = var.actions_enabled
  alarm_actions       = [data.aws_sns_topic.topic.arn]
  alarm_description   = "Serverless database capacity has exceeded threshold."
  alarm_name          = "${each.key}-serverless-database-capacity-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.thresholds["ServerlessDatabaseCapacityEvaluationPeriods"]
  metric_name         = "ServerlessDatabaseCapacity"
  namespace           = "AWS/RDS"
  ok_actions          = [data.aws_sns_topic.topic.arn]
  period              = "60"
  statistic           = "Maximum"
  tags                = var.tags
  threshold           = local.thresholds["ServerlessDatabaseCapacityThreshold"]
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

# This is only relevant on the reader. TODO: Change this to only create this on the reader.
resource "aws_cloudwatch_metric_alarm" "replica_lag" {
  for_each            = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  actions_enabled     = var.actions_enabled
  alarm_actions       = [data.aws_sns_topic.topic.arn]
  alarm_description   = "Aurora Replica Lag has exceeded threshold. Consider increasing ACU on the reader."
  alarm_name          = "${each.key}-replica-lag-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.thresholds["ReplicationLagEvaluationPeriods"]
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  ok_actions          = [data.aws_sns_topic.topic.arn]
  period              = "60"
  statistic           = "Maximum"
  tags                = var.tags
  threshold           = local.thresholds["ReplicationLagThreshold"]
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "acu_utilization" {
  for_each            = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  actions_enabled     = var.actions_enabled
  alarm_actions       = [data.aws_sns_topic.topic.arn]
  alarm_description   = "Aurora Capacity Units (ACU) utilization has exceeded threshold. Consider increasing ACU max-capacity."
  alarm_name          = "${each.key}-acu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.thresholds["ACUUtilizationEvaluationPeriods"]
  metric_name         = "ACUUtilization"
  namespace           = "AWS/RDS"
  ok_actions          = [data.aws_sns_topic.topic.arn]
  period              = "60"
  statistic           = "Maximum"
  tags                = var.tags
  threshold           = local.thresholds["ACUUtilizationThreshold"]
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "database_connections" {
  for_each            = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  actions_enabled     = var.actions_enabled
  alarm_actions       = [data.aws_sns_topic.topic.arn]
  alarm_description   = "The number of connections to this database instance is reaching threshold."
  alarm_name          = "${each.key}-database-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = local.thresholds["DatabaseConnectionsEvaluationPeriods"]
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  ok_actions          = [data.aws_sns_topic.topic.arn]
  period              = "60"
  statistic           = "Maximum"
  tags                = var.tags
  threshold           = local.thresholds["DatabaseConnectionsThreshold"]
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_freeable_memory" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "Instance freeable memory is low. Examine performance and/or increase max ACU."
  alarm_name                = "${each.key}-instance-freeable-memory-low"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = local.thresholds["InstanceFreeableMemoryEvaluationPeriods"]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  metric_name               = "FreeableMemory"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Minimum"
  tags                      = var.tags
  threshold                 = local.thresholds["InstanceFreeableMemoryThreshold"]
  treat_missing_data        = "breaching"
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_temp_storage_iops" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "IOPS on local storage is high."
  alarm_name                = "${each.key}-instance-temp-storage-iops-high"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["InstanceTempStorageIopsEvaluationPeriods"]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  metric_name               = "TempStorageIOPS"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Maximum"
  tags                      = var.tags
  threshold                 = local.thresholds["InstanceTempStorageIopsThreshold"]
  treat_missing_data        = "breaching"
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_disk_queue_depth" {
  for_each                  = { for key, value in data.aws_rds_cluster.cluster.cluster_members : key => value }
  actions_enabled           = var.actions_enabled
  alarm_actions             = [data.aws_sns_topic.topic.arn]
  alarm_description         = "Disk Queue Depth is high on this instance."
  alarm_name                = "${each.key}-disk-queue-depth-high"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = local.thresholds["InstanceDiskQueueDepthEvaluationPeriods"]
  insufficient_data_actions = [data.aws_sns_topic.topic.arn]
  metric_name               = "DiskQueueDepth"
  namespace                 = local.cloudwatch_namespace
  ok_actions                = [data.aws_sns_topic.topic.arn]
  period                    = "60"
  statistic                 = "Maximum"
  threshold                 = local.thresholds["InstanceDiskQueueDepthThreshold"]
  treat_missing_data        = "breaching"
  tags                      = var.tags
  dimensions = {
    DBInstanceIdentifier = each.key
  }
}

