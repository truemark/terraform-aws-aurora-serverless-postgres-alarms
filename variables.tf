variable "actions_enabled" {
  description = "Toggle to enable or disable alarm actions (notifications)."
  type        = bool
  default     = true
}

variable "backup_retention_period_storage_used_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "backup_retention_period_storage_used_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 10000
}

variable "cluster_identifier" {
  description = "The name of the cluster to monitor."
  type        = string
  nullable    = false
}

variable "cluster_cpu_utilization_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "cluster_cpu_utilization_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 90
}

variable "cluster_freeable_memory_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "cluster_freeable_memory_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 1000000000
}

variable "serverless_database_capacity_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "serverless_database_capacity_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 128
}

variable "sns_topic_name" {
  description = "The name of the SNS topic to publish alerts to."
  type        = string
}

variable "tags" {
  description = "Tags to be added to all resources."
  type        = map(string)
}

variable "total_backup_storage_billed_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "total_backup_storage_billed_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 10000
}

variable "cluster_volume_bytes_used_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "cluster_volume_bytes_used_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 10000
}

variable "cluster_volume_read_iops_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "instance_volume_read_iops_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 10000
}

variable "instance_volume_write_iops_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "instance_volume_write_iops_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 10000
}

variable "replication_lag_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "replication_lag_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 100
}

variable "acu_utilization_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "acu_utilization_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 90
}

variable "database_connections_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "database_connections_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 2000
}

variable "instance_freeable_memory_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "instance_freeable_memory_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 1000000000
}

variable "instance_temp_storage_iops_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "instance_temp_storage_iops_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 1000000000
}

variable "instance_disk_queue_depth_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "instance_disk_queue_depth_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 20
}

variable "connection_attempts_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "connection_attempts_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 20
}


variable "cluster_volume_read_iops_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 10000
}

variable "cluster_volume_write_iops_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "cluster_volume_write_iops_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 10000
}

variable "instance_volume_read_iops_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

