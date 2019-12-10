resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = "${var.repo_name}-${var.branch_name}"
  subnet_ids = data.aws_subnet_ids.subnets.ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.repo_name}-${var.branch_name}"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1

  security_group_ids = [data.aws_security_group.security_group.arn]
  subnet_group_name = aws_elasticache_subnet_group.subnet_group.name
}
