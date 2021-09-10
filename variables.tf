variable "region" {
  description = "Please Enter AWS Region to deploy Server"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "t2.micro"
}


variable "common_tags" {
  description = "Common Tags to apply to all resources"
  type        = map
  default = {
    Owner       = "Roman Kuzmyn"
    Project     = "DevOps-Project-1"
    Mentor      = "Yaroslav"
    Environment = "test"
  }
}
variable "allow_ports-jenkins" {
  description = "List of Ports to open for Jenkins"
  type        = list
  default     = ["22", "8080"]
}
/*
variable "key_name" {  #---------create key------------
default     = "jenkins_key"
}

resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
*/