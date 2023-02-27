provider "aws" {
    region = "eu-central-1"
}


resource "aws_vpc" "DEV" {
    cidr_block = "10.0.0.0/16" 
    tags = {
        Name = "DEV"
    }
}

resource "aws_subnet" "DEV-subnet-1" {
    vpc_id = aws_vpc.DEV.id
    cidr_block = "10.0.20.0/24"
    availability_zone = "eu-central-1a"
    tags = {
        Name = "DEV-subnet"
    }
}

