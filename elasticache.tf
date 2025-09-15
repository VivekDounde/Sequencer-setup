resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.cluster_name}-redis-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${var.cluster_name}-redis"
  replication_group_description = "Arbitrum sequencer redis"
  engine                        = "redis"
  engine_version                = "7.0"
  node_type                     = "cache.m6g.large"
  number_cache_clusters         = 3
  automatic_failover_enabled    = true
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  transit_encryption_enabled    = true
  at_rest_encryption_enabled    = true

  tags = {
    Name = "${var.cluster_name}-redis"
  }
}
