resource "aws_instance" "myEC2" {
  ami = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.medium"
  key_name =  "demoKeyPair"
  count = 1
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
  vpc_security_group_ids = [ aws_security_group.allow_tls.id ]
  tags = {
    Name = "myInstance ${count.index}"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http1" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_http2" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

