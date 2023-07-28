locals {
  thresholds = {
    ACUUtilizationEvaluationPeriods                   = min(max(var.acu_utilization_evaluation_periods, 1), 100)
    ACUUtilizationThreshold                           = min(max(var.acu_utilization_threshold, 0), 100)
    BackupRetentionPeriodStorageUsedEvaluationPeriods = min(max(var.backup_retention_period_storage_used_evaluation_periods, 1), 100)
    BackupRetentionPeriodStorageUsedThreshold         = min(max(var.backup_retention_period_storage_used_threshold, 0), 100000000)
    ClusterCPUUtilizationEvaluationPeriods            = min(max(var.cluster_cpu_utilization_evaluation_periods, 1), 100)
    ClusterCPUUtilizationThreshold                    = min(max(var.cluster_cpu_utilization_threshold, 0), 100)
    ClusterFreeableMemoryEvaluationPeriods            = min(max(var.cluster_freeable_memory_evaluation_periods, 1), 100)
    ClusterFreeableMemoryThreshold                    = min(max(var.cluster_freeable_memory_threshold, 0), 100000000)
    ClusterVolumeReadIOPsEvaluationPeriods            = min(max(var.cluster_volume_read_iops_evaluation_periods, 1), 100)
    ClusterVolumeReadIOPsThreshold                    = max(var.cluster_volume_read_iops_threshold, 0)
    ClusterVolumeWriteIOPsEvaluationPeriods           = min(max(var.cluster_volume_write_iops_evaluation_periods, 1), 100)
    ClusterVolumeWriteIOPsThreshold                   = max(var.cluster_volume_write_iops_threshold, 0)
    ConnectionAttemptsEvaluationPeriods               = min(max(var.connection_attempts_evaluation_periods, 1), 100)
    ConnectionAttemptsThreshold                       = min(max(var.connection_attempts_threshold, 0), 1000)
    DatabaseConnectionsEvaluationPeriods              = min(max(var.database_connections_evaluation_periods, 1), 100)
    DatabaseConnectionsThreshold                      = min(max(var.database_connections_threshold, 1), 5000)
    InstanceDiskQueueDepthEvaluationPeriods           = min(max(var.instance_disk_queue_depth_evaluation_periods, 1), 100)
    InstanceDiskQueueDepthThreshold                   = min(max(var.instance_disk_queue_depth_threshold, 0), 100000)
    InstanceFreeableMemoryEvaluationPeriods           = min(max(var.instance_freeable_memory_evaluation_periods, 1), 100)
    InstanceFreeableMemoryThreshold                   = min(max(var.instance_freeable_memory_threshold, 0), 100000000)
    InstanceTempStorageIopsEvaluationPeriods          = min(max(var.instance_temp_storage_iops_evaluation_periods, 1), 100)
    InstanceTempStorageIopsThreshold                  = min(max(var.instance_temp_storage_iops_threshold, 0), 100000000)
    InstanceVolumeReadIOPsEvaluationPeriods           = min(max(var.instance_volume_read_iops_evaluation_periods, 1), 100)
    InstanceVolumeReadIOPsThreshold                   = max(var.instance_volume_read_iops_threshold, 0)
    InstanceVolumeWriteIOPsEvaluationPeriods          = min(max(var.instance_volume_write_iops_evaluation_periods, 1), 100)
    InstanceVolumeWriteIOPsThreshold                  = max(var.instance_volume_write_iops_threshold, 0)
    ReplicationLagEvaluationPeriods                   = min(max(var.replication_lag_evaluation_periods, 1), 100)
    ReplicationLagThreshold                           = min(max(var.replication_lag_threshold, 0), 100)
    ServerlessDatabaseCapacityEvaluationPeriods       = min(max(var.serverless_database_capacity_evaluation_periods, 1), 100)
    ServerlessDatabaseCapacityThreshold               = min(max(var.serverless_database_capacity_threshold, 0), 100000000)
    TotalBackupStorageBilledEvaluationPeriods         = min(max(var.total_backup_storage_billed_evaluation_periods, 1), 100)
    TotalBackupStorageBilledThreshold                 = max(var.total_backup_storage_billed_threshold, 0)
    ClusterVolumeBytesUsedEvaluationPeriods           = min(max(var.cluster_volume_bytes_used_evaluation_periods, 1), 100)
    ClusterVolumeBytesUsedThreshold                   = max(var.cluster_volume_bytes_used_threshold, 0)
  }
}