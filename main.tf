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