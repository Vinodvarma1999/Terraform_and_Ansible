# VPC 
resource "aws_vpc" "c3" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC-Cha-3"
  }  
}

# Security group for EC2 instance
resource "aws_security_group" "c3" {
  name = "SG-challenge-3" 
  description = "Allow SSH and HTTP Connection"
  
  ingress {
    to_port = 22
    from_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    to_port = 80
    from_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    to_port = 0
    from_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.c3.id

  tags = {
    Name = "SG-Cha-3"
  }
}

# subnet for ec2 
resource "aws_subnet" "c3" {
  vpc_id = "${aws_vpc.c3.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-Cha-3"
  }  
}

#Create a key-pair name with my-project in AWS Console
data "aws_key_pair" "c3" {    
  key_name = "my-project"
}

# Creating EC2 Instance
resource "aws_instance" "c3" {
  ami = var.ami_id
  instance_type = var.instance_type
  key_name = data.aws_key_pair.c3.key_name
  subnet_id = aws_subnet.c3.id
  vpc_security_group_ids = [ 
    aws_security_group.c3.id
  ]

  tags = {
    Name = "EC2-Cha-3"
  }
}

# Create ami from existing ec2
resource "aws_ami_from_instance" "c3" {
  name               = "ami-Cha-3"
  source_instance_id = "${aws_instance.c3.id}"
}


# Create a launch Configuration
resource "aws_launch_configuration" "c3" {
  image_id        = aws_ami_from_instance.c3.id
  instance_type   = var.instance_type
  security_groups = ["${aws_security_group.c3.id}"]

}

# Create a Auto-Scaling Group
resource "aws_autoscaling_group" "c3" {
  name                 = "Auto-Scale-Cha-3"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.c3.name}"
  vpc_zone_identifier  = ["${aws_subnet.c3.id}"]
}

# Scaling Policy for maximumn
resource "aws_autoscaling_policy" "cpu_utilization_scale_up" {
  name                   = "CPUUtilizationScaleUpPolicy"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.c3.name

  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 1
}

# CloudWatch alarm for scale-Up
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_scale_up" {
  alarm_name          = "CPUUtilizationAlarmUp"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.cpu_utilization_scale_up.arn]
}

# Scaling Policy for minimum
resource "aws_autoscaling_policy" "cpu_utilization_scale_down" {
  name                   = "CPUUtilizationScaleDownPolicy"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.c3.name

  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = -1
}

# CloudWatch alarm for scale-Down
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm_scale_down" {
  alarm_name          = "CPUUtilizationAlarmDown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.cpu_utilization_scale_down.arn]
}

