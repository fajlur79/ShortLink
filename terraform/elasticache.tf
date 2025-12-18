resource "aws_security_group" "redis_sg"{
    name        = "redis_sg"
    description = "Security grop for ElastiCache Redis"
    vpc_id      = data.aws_vpc.default.id 

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

resource "aws_elasticache_replication_group" "app-redis" {
    replication_group_id    = "app-redis"
    description             = "Redis for ShortLink App"
    node_type               = "cache.t3.micro"
    port                    = 6379

    num_cache_clusters      = 1

    security_group_ids      = [aws_security_group.redis_sg.id]
}