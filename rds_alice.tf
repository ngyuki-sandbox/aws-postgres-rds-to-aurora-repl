################################################################################
# RDS
################################################################################

resource "aws_db_instance" "alice" {
  identifier                          = "alice-db"
  engine                              = "postgres"
  engine_version                      = "14.2"
  instance_class                      = "db.t3.micro"
  allocated_storage                   = 20
  db_subnet_group_name                = aws_db_subnet_group.alice.id
  parameter_group_name                = aws_db_parameter_group.alice.id
  vpc_security_group_ids              = [aws_security_group.rds_alice.id]
  db_name                             = "alice"
  username                            = "postgres"
  password                            = "password"
  multi_az                            = false
  auto_minor_version_upgrade          = false
  publicly_accessible                 = false
  iam_database_authentication_enabled = true
  skip_final_snapshot                 = true
}

resource "aws_db_subnet_group" "alice" {
  name       = "alice-subnet"
  subnet_ids = [for x in data.aws_subnet.subnets : x.id]
}

resource "aws_db_parameter_group" "alice" {
  name        = "alice-db"
  description = "alice-db"
  family      = "postgres14"

  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements,pglogical"
    apply_method = "pending-reboot"
  }
}
