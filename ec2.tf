################################################################################
# EC2
################################################################################

resource "aws_instance" "server" {
  ami                         = "ami-0afe0424c9fd49524" # Oracle Linux 8.5
  instance_type               = "t2.nano"
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.subnets[keys(data.aws_subnet.subnets)[0]].id
  vpc_security_group_ids      = [aws_security_group.server.id]
  associate_public_ip_address = true

  user_data = <<-EOS
    #cloud-config
    timezone: "Asia/Tokyo"
    hostname: "alice-server"
    runcmd:
      - dnf -y module install postgresql:13/client
  EOS

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags = {
    Name = "alice-server"
  }
}
