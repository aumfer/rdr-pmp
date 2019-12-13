resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = "${var.repo_name}-${var.branch_name}"
  subnet_ids = data.aws_subnet_ids.subnets.ids
}

resource "aws_elasticache_parameter_group" "default" {
  name   = "${var.repo_name}-${var.branch_name}"
  family = "redis5.0"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.repo_name}-${var.branch_name}"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = aws_elasticache_parameter_group.default.id
  apply_immediately    = true

  security_group_ids = [aws_security_group.redis_security_group.id]
  subnet_group_name = aws_elasticache_subnet_group.subnet_group.name
}

resource "aws_security_group_rule" "allow_all_egress_redis" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redis_security_group.id
}

resource "aws_security_group_rule" "allow_redis_ingress_redis" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redis_security_group.id
}
