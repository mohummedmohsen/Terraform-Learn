provider "aws" {
    region = "eu-central-1"
}

resource "aws_vpc" "DEV" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

module "DEV_subnet" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.DEV.id
  
}

module "DEV_web-server" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.DEV.id
    my_ip  = var.my_ip
    env_prefix = var.env_prefix
    public_key_file = var.public_key_file
    instance_type = var.instance_type
    subnet_id = module.DEV_subnet.subnet.id
    avail_zone = var.avail_zone
  
}