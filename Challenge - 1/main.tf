resource "aws_vpc" "my-project" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-project-1"
  }
}

resource "aws_internet_gateway" "my-project" {
  vpc_id = aws_vpc.my-project.id
  tags = {
    Name = "IGW-project-1"
  } 
}

resource "aws_route_table" "my-project" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-project.id
  }
  vpc_id = aws_vpc.my-project.id
  tags = {
    Name = "public-RT-project-1"
  } 
}

resource "aws_security_group" "my-project" {
  name = "SG-project-1"
  description = "Allow SSH and HTTP Connection"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.my-project.id
  tags = {
    Name = "SG-project-1"
  }
}

resource "aws_subnet" "my-project" {
  vpc_id = aws_vpc.my-project.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-project-1"
  }  
}

resource "aws_route_table_association" "my-project" {
  subnet_id = aws_subnet.my-project.id
  route_table_id = aws_route_table.my-project.id  
}

data "aws_key_pair" "my-project" {     #Create a key-pair name with my-project in AWS Console
  key_name = "my-project"
}

resource "aws_instance" "my-project" {
  ami = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  count = var.ec2_num
  key_name = data.aws_key_pair.my-project.key_name
  subnet_id = aws_subnet.my-project.id

  vpc_security_group_ids = [ 
    aws_security_group.my-project.id
  ]

  tags = {
    Name = "myInstance-project-1"
  }
}

output "instance_ips" {
  value = aws_instance.my-project.*.public_ip
}
