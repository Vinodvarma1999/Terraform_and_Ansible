# VPC for EC2 and RDS
resource "aws_vpc" "my-project" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-project-1"
  }
}


# Security group for EC2 instance
resource "aws_security_group" "ec2_sg" {
  name = "ec2_sg_"
  vpc_id = aws_vpc.my-project.id
  
  ingress  {
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

  tags = {
    Name = "ec2_sg"
  }
}

# Security group for RDS instance
resource "aws_security_group" "rds_sg" {
  name = "rds_sg_"
  vpc_id = aws_vpc.my-project.id

  tags = {
    Name = "rds_sg"
  }
}

# Security group rule for ec2_to_rds
resource "aws_security_group_rule" "ec2_to_rds" {
  type        = "ingress"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  security_group_id = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
}

# Security group rule for rds-to_ec2
resource "aws_security_group_rule" "rds_to_ec2" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  security_group_id = aws_security_group.ec2_sg.id
  source_security_group_id = aws_security_group.rds_sg.id
}

# subnet-1 for ec2 and rds 
resource "aws_subnet" "my-project-1" {
  vpc_id = aws_vpc.my-project.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "subnet-project-1"
  }  
}

# subnet-2 for ec2 and rds 
resource "aws_subnet" "my-project-2" {
  vpc_id = aws_vpc.my-project.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "subnet-project-1"
  }  
}

# Key-Pair present on AWS
data "aws_key_pair" "my-project" {    
  key_name = "my-project"
}

# Creating EC2 Instance
resource "aws_instance" "my-project" {
  ami = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  key_name = data.aws_key_pair.my-project.key_name
  subnet_id = aws_subnet.my-project-1.id
  
  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  tags = {
    Name = "myInstance-project-1"
  }
}

# RDS Instance
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name        = "my-db-subnet-group"
  subnet_ids  = [aws_subnet.my-project-1.id, aws_subnet.my-project-2.id]
}

resource "aws_db_instance" "rds" {
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_storage_size
  db_name              = "mydb"
  skip_final_snapshot = true
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  
  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]  
}
