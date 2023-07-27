locals {
  thresholds = {
    BackupRetentionPeriodStorageUsedEvaluationPeriods = min(max(var.backup_retention_period_storage_used_evaluation_periods, 1), 100)
    BackupRetentionPeriodStorageUsedThreshold         = min(max(var.backup_retention_period_storage_used_threshold, 0), 100000000)
    ServerlessDatabaseCapacityEvaluationPeriods       = min(max(var.serverless_database_capacity_evaluation_periods, 1), 100)
    ServerlessDatabaseCapacityThreshold               = min(max(var.serverless_database_capacity_threshold, 0), 100000000)
    TotalBackupStorageBilledEvaluationPeriods         = min(max(var.total_backup_storage_billed_evaluation_periods, 1), 100)
    TotalBackupStorageBilledThreshold                 = max(var.total_backup_storage_billed_threshold, 0)
    VolumeBytesUsedEvaluationPeriods                  = min(max(var.volume_bytes_used_evaluation_periods, 1), 100)
    VolumeBytesUsedThreshold                          = max(var.volume_bytes_used_threshold, 0)
    VolumeReadIOPsEvaluationPeriods                   = min(max(var.volume_read_iops_evaluation_periods, 1), 100)
    VolumeReadIOPsThreshold                           = max(var.volume_read_iops_threshold, 0)
    VolumeWriteIOPsEvaluationPeriods                  = min(max(var.volume_write_iops_evaluation_periods, 1), 100)
    VolumeWriteIOPsThreshold                          = max(var.volume_write_iops_threshold, 0)

    ClusterCPUUtilizationEvaluationPeriods = min(max(var.cluster_cpu_utilization_evaluation_periods, 1), 100)
    ClusterCPUUtilizationThreshold         = min(max(var.cluster_cpu_utilization_threshold, 0), 100)

    ClusterFreeableMemoryEvaluationPeriods = min(max(var.cluster_freeable_memory_evaluation_periods, 1), 100)
    ClusterFreeableMemoryThreshold         = min(max(var.cluster_freeable_memory_threshold, 0), 100000000)
    ReplicationLagEvaluationPeriods        = min(max(var.replication_lag_evaluation_periods, 1), 100)
    ReplicationLagThreshold                = min(max(var.replication_lag_threshold, 0), 100)


    ACUUtilizationEvaluationPeriods = min(max(var.acu_utilization_evaluation_periods, 1), 100)
    ACUUtilizationThreshold         = min(max(var.acu_utilization_threshold, 0), 100)

    DatabaseConnectionsEvaluationPeriods = min(max(var.database_connections_evaluation_periods, 1), 100)
    DatabaseConnectionsThreshold         = min(max(var.database_connections_threshold, 1), 5000)


    InstanceFreeableMemoryEvaluationPeriods = min(max(var.instance_freeable_memory_evaluation_periods, 1), 100)
    InstanceFreeableMemoryThreshold         = min(max(var.instance_freeable_memory_threshold, 0), 100000000)


    InstanceTempStorageIopsEvaluationPeriods = min(max(var.instance_temp_storage_iops_evaluation_periods, 1), 100)
    InstanceTempStorageIopsThreshold         = min(max(var.instance_temp_storage_iops_threshold, 0), 100000000)


  }
}