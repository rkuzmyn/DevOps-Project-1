#----------------------------------------------------------
# Test task from Yaroslav
#
# Create jenkins master/added ssh key
# Launch Configuration with Auto AMI Lookup
#
# Made by Roman Kuzmyn
#----------------------------------------------------------

provider "aws" {
  region = var.region
}
#----------------------------------------------------------
data "aws_availability_zones" "available" {} #прочитати зони в регіоні
data "aws_ami" "latest_amazon_linux" { # знайти останній образ amazon linux2
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
#----------------------------------------------------------
resource "aws_security_group" "jenkins" {
  name = "jenkins Security Group"

  dynamic "ingress" {
    for_each = var.allow_ports-jenkins
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} for jenkins" })

}

resource "aws_instance" "Jenkins_master" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = "jenkins_key"  #---------key--------------
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} Jenkins_master" })
  user_data              = file("install-jenkins-master.sh")
  
}


resource "aws_launch_configuration" "jenkins-worker" {
  //  name            = "WebServer-Highly-Available-LC"
  name_prefix     = "jenkins-worker-Highly-Available-LC-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.jenkins.id]
    lifecycle {
    create_before_destroy = true # вбивати старі інстанси після того як створяться нові
  }
}

resource "aws_autoscaling_group" "jenkins-worker" {
  name                 = "ASG-${aws_launch_configuration.jenkins-worker.name}"
  launch_configuration = aws_launch_configuration.jenkins-worker.name
  min_size             = 2
  max_size             = 4
 #min_elb_capacity     = 2 
 #health_check_type    = "EC2" # або ELB
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  #tags = merge(var.common_tags, { Name = "${var.common_tags["Environment"]} jenkins-worker" })
  
dynamic "tag" {
    for_each = {
      Name       = "ASG_jenkins_worker"
      Owner       = "Roman Kuzmyn"
      Project     = "DevOps-Project-1"
      Mentor      = "Yaroslav"
      Environment = "test"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true # вбивати старі інстанси після того як створяться нові
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}
/*
resource "aws_key_pair" "deployer" { #---------create key------------
  key_name   = "deployer-key"
  public_key = "ssh-rsa MsNZAlFKQXoARyIVWB1wAzE= root@key-server"
}
*/
/*
resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.jenkins_key.public_key_openssh}"
}
*/