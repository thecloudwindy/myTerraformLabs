locals {
  common_tags = {
    Author  = "Tam Nguyen"
    Project = "Create VPC"
  }
}

# Tạo Custom VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  # tags = local.common_tags
  tags = merge(local.common_tags, {
    Name = "myVPC"
  })
}

# Tạo Subnets
resource "aws_subnet" "public-subnet-01" {
  vpc_id                                      = aws_vpc.main.id
  cidr_block                                  = "10.0.1.0/24"
  availability_zone                           = "us-east-1a"
  enable_resource_name_dns_a_record_on_launch = true
  map_public_ip_on_launch                     = true
  tags = merge(local.common_tags, {
    Name = "my-Public-Subnet-01"
  })
}

resource "aws_subnet" "private-subnet-01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = merge(local.common_tags, {
    Name = "my-Private-Subnet-01"
  })
}

resource "aws_subnet" "public-subnet-02" {
  vpc_id                                      = aws_vpc.main.id
  cidr_block                                  = "10.0.3.0/24"
  availability_zone                           = "us-east-1b"
  enable_resource_name_dns_a_record_on_launch = true
  map_public_ip_on_launch                     = true
  tags = merge(local.common_tags, {
    Name = "my-Public-Subnet-02"
  })
}

resource "aws_subnet" "private-subnet-02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = merge(local.common_tags, {
    Name = "my-Private-Subnet-02"
  })
}

# Tạo Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.common_tags, {
    Name = "my-Internet-Gateway"
  })
}

# Gán IGW vào VPC => không cần vì khi tạo IGW đã tự khai báo VPC ID rồi
# resource "aws_internet_gateway_attachment" "igw-attachment" {
#   internet_gateway_id = aws_internet_gateway.igw.id
#   vpc_id              = aws_vpc.main.id
# }

# Tạo EIP
resource "aws_eip" "Elastic-IP" {
  tags = merge(local.common_tags, {
    Name = "my-EIP"
  })
}

# Tạo NAT Gateway
resource "aws_nat_gateway" "NAT-GW" {
  allocation_id = aws_eip.Elastic-IP.id
  subnet_id     = aws_subnet.private-subnet-01.id
  tags = merge(local.common_tags, {
    Name = "my-NAT-Gateway"
  })
  depends_on = [aws_internet_gateway.igw]
}

# Tạo Route Tables
resource "aws_route_table" "Public-Route-Table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.common_tags, {
    Name = "my-Public-Route-Table"
  })
}

resource "aws_route_table" "Private-Route-Table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT-GW.id
  }
  tags = merge(local.common_tags, {
    Name = "my-Private-Route-Table"
  })
}

# Tạo liên kết Subnets vào các Route Tables tương úng
resource "aws_route_table_association" "Public-RT01" {
  subnet_id      = aws_subnet.public-subnet-01.id
  route_table_id = aws_route_table.Public-Route-Table.id
}

resource "aws_route_table_association" "Public-RT02" {
  subnet_id      = aws_subnet.public-subnet-02.id
  route_table_id = aws_route_table.Public-Route-Table.id
}

resource "aws_route_table_association" "Private-RT01" {
  subnet_id      = aws_subnet.private-subnet-01.id
  route_table_id = aws_route_table.Private-Route-Table.id
}

resource "aws_route_table_association" "Private-RT02" {
  subnet_id      = aws_subnet.private-subnet-02.id
  route_table_id = aws_route_table.Private-Route-Table.id
}


