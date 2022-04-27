################################################################################
# Security Group
################################################################################

################################################################################
# server

resource "aws_security_group" "server" {
  name        = "bob-server"
  description = "bob-server"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    "Name" = "bob-server"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["211.5.105.208/28"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################################################################
# RDS

resource "aws_security_group" "rds_bob" {
  name        = "bob-rds"
  description = "bob-rds"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    "Name" = "bob-rds"
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.server.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_alice" {
  name        = "alice-rds"
  description = "alice-rds"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    "Name" = "alice-rds"
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.server.id,
      aws_security_group.rds_bob.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}
