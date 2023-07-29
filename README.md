# terraform-aws-aurora-serverless-postgres-alarms

This repo defines alarms specific to Postgresql on RDS Aurora Serverless v2.

One parameter controls if notifications are forwarded upon breach: actions_enabled.

This repo only includes threshold alarms. No anomaly alarms are included. The following metrics are observed for breach of threshold.
 
- acu_utilization 
- backup_retention_period_storage_used 
- cluster_cpu_utilization 
- cluster_freeable_memory 
- cluster_temp_storage_iops 
- cluster_volume_read_iops 
- cluster_volume_write_iops 
- database_connections 
- instance_disk_queue_depth
- instance_freeable_memory 
- instance_read_iops 
- instance_temp_storage_iops
- instance_write_iops 
- replica_lag 
- serverless_database_capacity 
- total_backup_storage_billed 

**Reference**

[Instance level metrics for Amazon Aurora](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraMonitoring.Metrics.html)

TODO:
Deadlocks - how to monitor for a large jump in the number of deadlocks?

Example implementation

```
module "db" {
  source             = "truemark/rds-aurora-postgres-serverless-v2/aws"
  version            = "0.0.3"    
}

module "alarms" {
  source             = "truemark/aurora-serverless-postgres-alarms/aws"
  version            = "0.0.3" 
  actions_enabled    = false
  cluster_identifier = module.db.cluster_identifier
  sns_topic_name     = "CenterGaugeAlerts"
  tags               = local.tags
}
```