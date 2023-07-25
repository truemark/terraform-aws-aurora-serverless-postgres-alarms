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

variable "serverless_database_capacity_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "serverless_database_capacity_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 10000
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

variable "volume_bytes_used_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "volume_bytes_used_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 10000
}

variable "volume_read_iops_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "volume_read_iops_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 10000
}

variable "volume_write_iops_evaluation_periods" {
  description = "The number of periods threshold must be breached to alarm."
  type        = number
  default     = 5
}

variable "volume_write_iops_threshold" {
  description = "The threshold value that will trigger an alert."
  type        = number
  default     = 10000
}
