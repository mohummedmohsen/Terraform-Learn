resource "aws_subnet" "DEV-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "DEV-IGW" {
    vpc_id = var.vpc_id
    tags = {
      Name = "${var.env_prefix}-igw"
    }
  
}

resource "aws_route_table" "DEV-route-table" {
    vpc_id = var.vpc_id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.DEV-IGW.id
    }
    tags = {
      Name = "${var.env_prefix}-RTB"
    }
  
}

resource "aws_route_table_association" "a-RTB-subnet" {
    subnet_id = aws_subnet.DEV-subnet-1.id
    route_table_id = aws_route_table.DEV-route-table.id
  
}