# --- VPC section ---

# VPC

resource "aws_vpc" "vpc" {
  count = length(var.cidrVpc)
  cidr_block = element(var.cidrVpc, count.index)
  enable_dns_hostnames = true
  enable_dns_support = true
}

# Internet gateway

resource "aws_internet_gateway" "internetGateway" {
  count = length(var.cidrVpc)
  vpc_id = aws_vpc.vpc[count.index].id
}

# Route table

resource "aws_route_table" "rt" {
  count = length(var.cidrVpc)
  vpc_id = aws_vpc.vpc[count.index].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetGateway[count.index].id
  }
}

# Subnets

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "subnetMgt" {
  vpc_id = aws_vpc.vpc[0].id
  cidr_block = var.cidrSubnetMgt
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnetMysql" {
  vpc_id = aws_vpc.vpc[0].id
  cidr_block = var.cidrSubnetMySql
  map_public_ip_on_launch = false
}

resource "aws_subnet" "subnetAviVs" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.vpc[0].id
  cidr_block = element(var.cidrSubnetAviVs, count.index)
  map_public_ip_on_launch = true
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "aviVs-${count.index + 1 }"
  }
}

resource "aws_subnet" "subnetBackend" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.vpc[0].id
  cidr_block = element(var.cidrSubnetBackend, count.index)
  map_public_ip_on_launch = false
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "backend-${count.index + 1 }"
  }
}

resource "aws_subnet" "subnetAviSeMgt" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.vpc[0].id
  cidr_block = element(var.cidrSubnetAviSeMgt, count.index)
  map_public_ip_on_launch = false
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "aviSeMgt-${count.index + 1 }"
  }
}

# Elastic IP for NAT natGw

resource "aws_eip" "eipForNatGw" {
  vpc = true
  depends_on = [aws_internet_gateway.internetGateway]
}

# NAT gateway

resource "aws_nat_gateway" "natGw" {
  allocation_id = aws_eip.eipForNatGw.id
  subnet_id     = aws_subnet.subnetMgt.id
}

resource "aws_route_table" "rtPrivate" {
  count = length(var.cidrVpc)
  vpc_id = aws_vpc.vpc[count.index].id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natGw.id
  }
}

# Subnet associations

resource "aws_route_table_association" "subnetAssociationMgt" {
  subnet_id = aws_subnet.subnetMgt.id
  route_table_id = aws_route_table.rt[0].id
}

resource "aws_route_table_association" "subnetAssociationMysql" {
  subnet_id = aws_subnet.subnetMysql.id
  route_table_id =aws_route_table.rtPrivate[0].id
}

resource "aws_route_table_association" "subnetAssociationBackend" {
  count = length(data.aws_availability_zones.available.names)
  subnet_id = aws_subnet.subnetBackend[count.index].id
  route_table_id = aws_route_table.rtPrivate[0].id
}

resource "aws_route_table_association" "subnetAssociationAviSeMgt" {
  count = length(data.aws_availability_zones.available.names)
  subnet_id = aws_subnet.subnetAviSeMgt[count.index].id
  route_table_id = aws_route_table.rt[0].id
}

resource "aws_route_table_association" "subnetAssociationAviVs" {
  count = length(data.aws_availability_zones.available.names)
  subnet_id = aws_subnet.subnetAviVs[count.index].id
  route_table_id = aws_route_table.rt[0].id
}
