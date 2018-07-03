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
}

resource "aws_instance" "example" {
ami		=	"ami-40d28157"
instance_type	=	"t2.micro"
vpc_security_group_ids = ["${aws_security_group.instance.id}"]

user_data = <<-EOF
     #!/bin/bash
     echo "Hello World" > index.html
     nohup busybox httpd -f -p "${var.port_number}" &
     EOF


tags {
    Name = "terraform-example"
  }
}

variable "port_number" {
description     =       "HTTP port number on which server will listen"
default         =       "8080"
}

output "public_ip"  {
value 	=	"${aws_instance.example.public_ip}"
}

