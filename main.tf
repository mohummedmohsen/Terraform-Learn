provider "aws" {
    region = "eu-central-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {} 
variable instance_type {} 
variable public_key_file {} 

resource "aws_vpc" "DEV" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "DEV-subnet-1" {
    vpc_id = aws_vpc.DEV.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "DEV-IGW" {
    vpc_id = aws_vpc.DEV.id
    tags = {
      Name = "${var.env_prefix}-igw"
    }
  
}

resource "aws_route_table" "DEV-route-table" {
    vpc_id = aws_vpc.DEV.id
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

resource "aws_security_group" "DEV-SG" {
    name = "DEV-SG"
    vpc_id = aws_vpc.DEV.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
     ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
  
    tags = {
        Name = "${var.env_prefix}-sg"
    } 
}

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image
  
}



data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
      name = "name"
      values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
}
resource "aws_key_pair" "ssh-keypair" {
    key_name = "keypair"
    public_key = file(var.public_key_file)
}



resource "aws_instance" "DEV-SERVER" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.DEV-subnet-1.id
    vpc_security_group_ids = [aws_security_group.DEV-SG.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-keypair.key_name

    user_data = file("entry-script.sh")
    
    tags = {
        Name = "${var.env_prefix}-server"

    }
}

output "ec2_publi_ip" {
    value = aws_instance.DEV-SERVER.public_ip
  
}







