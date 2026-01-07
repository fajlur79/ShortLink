resource "aws_security_group" "redis_sg"{
    name        = "redis_sg"
    description = "Security grop for ElastiCache Redis"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description     = "Allow Redis traffic from App servers"
        from_port       = 6379
        to_port         = 6379
        protocol        = "tcp"
        security_groups = [aws_security_group.app_sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "random_id" "redis_suffix" {
  byte_length = 4
  
  keepers = {
    vpc_id = module.vpc.vpc_id
  }

}

resource "aws_elasticache_subnet_group" "app_redis_subnet_group" {
    name        = "ShortLink-redis-subnet-group"
    subnet_ids   = module.vpc.private_subnets
}

resource "aws_elasticache_replication_group" "app_redis" {
    replication_group_id    = "app-redis-${random_id.redis_suffix.hex}"
    description             = "Redis for ShortLink App"
    node_type               = "cache.t3.micro"
    port                    = 6379

    num_cache_clusters      = 1

    security_group_ids      = [aws_security_group.redis_sg.id]
    subnet_group_name        = aws_elasticache_subnet_group.app_redis_subnet_group.name

    lifecycle{
        create_before_destroy = true
    }
}

output "redis_replication_group_id" {
  description = "The ID of the ElastiCache Replication Group"
  value       = aws_elasticache_replication_group.app_redis.primary_endpoint_address
}