provider "aws" {
  region = "us-east-1"
}


resource "aws_security_group" "instance"{
name            =       "terraform-example-instance"

ingress{
        from_port =  "${var.port_number}"
        to_port = "${var.port_number}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
}

lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_group" "example"{
image_id	=	"ami-40d28157"
instance_type   =       "t2.micro"
security_group  =	["${aws_security_group.instance.id}"]

user_data = <<-EOF
     #!/bin/bash
     echo "Hello World" > index.html
     nohup busybox httpd -f -p "${var.port_number}" &
     EOF


lifecycle {
    create_before_destroy = true
  }
}

resource "auto_scaling_group" "example"{
launch_configuration	=	"${aws_launch_group.example.id}"
availability_zones	=	["${data.aws_availability_zones.al.names}"]
min_size		=	2
max_size		=	3

tag {
key	=	"Name"
value	=	"terraform-asg-example"
propogate_at_launch	=	"true"
}
}

data "aws_availability_zones" "al" {}

variable "port_number" {
description     =       "HTTP port number on which server will listen"
default         =       "8080"
}


