# terraform-aws-aurora-serverless-postgres-alarms

This repo defines alarms specific to Postgresql on RDS Aurora Serverless v2.

Each alarm listed below is created by default. Creation can be disabled by setting the associated alarm create parameter to false. For example, to not create the alarm volume_read_iops, set the parameter create_volume_read_iops_alarm to false.

This repo only includes threshold alarms. No anomaly alarms are included.

- backup_retention_period_storage_used
- serverless_database_capacity
- total_backup_storage_billed
- volume_bytes_used
- volume_read_iops
- volume_write_iops

Reference
[Instance level metrics for Amazon Aurora](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraMonitoring.Metrics.html#Aurora.AuroraMySQL.Monitoring.Metrics.instances)

[max_connections parameter](
https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html#aurora-serverless-v2.parameter-groups:~:text=The%20following%20table%20shows%20the%20default%20values%20for%20max_connections%20for%20Aurora%20Serverless%20v2%20based%20on%20the%20maximum%20ACU%20value.)


ConnectionAttempts
Deadlocks - how to monitor for a large jump in the number of deadlocks?

