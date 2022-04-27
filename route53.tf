################################################################################
# Route53
################################################################################

################################################################################
# public

data "aws_route53_zone" "public" {
  name = "${var.public_domain}."
}

resource "aws_route53_record" "server" {
  zone_id = data.aws_route53_zone.public.id
  name    = "bob-server.${var.public_domain}."
  type    = "A"
  ttl     = 60
  records = [aws_instance.server.public_ip]
}

################################################################################
# private

resource "aws_route53_zone" "private" {
  name = "${var.private_domain}."
  vpc {
    vpc_id = data.aws_vpc.vpc.id
  }
}

resource "aws_route53_record" "bob_db" {
  zone_id = aws_route53_zone.private.id
  name    = "bob-db.${var.private_domain}."
  type    = "CNAME"
  ttl     = 60

  records = [aws_rds_cluster.bob.endpoint]
}

resource "aws_route53_record" "alice_db" {
  zone_id = aws_route53_zone.private.id
  name    = "alice-db.${var.private_domain}."
  type    = "CNAME"
  ttl     = 60

  records = [aws_db_instance.alice.address]
}
