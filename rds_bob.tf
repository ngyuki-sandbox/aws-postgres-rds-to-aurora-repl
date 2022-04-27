################################################################################
# RDS
################################################################################

resource "aws_rds_cluster" "bob" {
  cluster_identifier                  = "bob-db"
  engine                              = "aurora-postgresql"
  engine_version                      = "13.6"
  database_name                       = "bob"
  master_username                     = "postgres"
  master_password                     = "password"
  db_subnet_group_name                = aws_db_subnet_group.bob.id
  db_cluster_parameter_group_name     = aws_rds_cluster_parameter_group.bob.id
  vpc_security_group_ids              = [aws_security_group.rds_bob.id]
  iam_database_authentication_enabled = true
  apply_immediately                   = true
  skip_final_snapshot                 = true
  enabled_cloudwatch_logs_exports     = ["postgresql"]

  depends_on = [
    aws_cloudwatch_log_group.bob_db
  ]
}

resource "aws_rds_cluster_instance" "bob" {
  identifier                 = "bob-db-instance-1"
  engine                     = "aurora-postgresql"
  engine_version             = "13.6"
  cluster_identifier         = aws_rds_cluster.bob.id
  instance_class             = "db.t3.medium"
  db_subnet_group_name       = aws_db_subnet_group.bob.id
  db_parameter_group_name    = aws_db_parameter_group.bob.id
  auto_minor_version_upgrade = false
  publicly_accessible        = false
}

resource "aws_db_subnet_group" "bob" {
  name       = "bob-subnet"
  subnet_ids = [for x in data.aws_subnet.subnets : x.id]
}

resource "aws_rds_cluster_parameter_group" "bob" {
  name        = "bob-cluster1"
  description = "bob-cluster"
  family      = "aurora-postgresql13"

  # parameter {
  #   name         = "rds.logical_replication"
  #   value        = "1"
  #   apply_method = "pending-reboot"
  # }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements,pglogical"
    apply_method = "pending-reboot"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "bob" {
  name        = "bob-db"
  description = "bob-db"
  family      = "aurora-postgresql13"

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements,pglogical"
    apply_method = "pending-reboot"
  }
}

resource "aws_cloudwatch_log_group" "bob_db" {
  name              = "/aws/rds/cluster/bob-db/postgresql"
  retention_in_days = 1
}
