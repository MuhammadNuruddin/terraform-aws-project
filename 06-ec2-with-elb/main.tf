variable "aws_key_par" {
  default = "../default-ec2.pem"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default" {
  
}

data "aws_subnets" "default_subnets" {
  filter {
    name = "vpc-id"
    values = [ aws_default_vpc.default.id ]
  }
}

// Security Group
// HTTP -> 80 TCP, 22 TCP, CIDR(range of ips to allow) ["0.0.0.0/0"]

resource "aws_security_group" "http_server_sg" {
  name   = "http_server_sg"
  # vpc_id = "vpc-014230ec5c5b6444c"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name   = "http_server_sg"
  }
}

// Security Group for load balancers - ELB
// HTTP -> 80 TCP, 22 TCP, CIDR(range of ips to allow) ["0.0.0.0/0"]

resource "aws_security_group" "elb_sg" {
  name   = "elb_sg"
  # vpc_id = "vpc-014230ec5c5b6444c"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "elb" {
  name = "elb"
  subnets = data.aws_subnets.default_subnets.ids
  security_groups = [aws_security_group.elb_sg.id]
  instances = values(aws_instance.http_servers).*.id

  listener {
    instance_port = 80
    instance_protocol = "http" 
    lb_port = 80
    lb_protocol = "http"
  }
}

resource "aws_instance" "http_servers" {
    ami = "ami-0ae8f15ae66fe8cda"
    key_name = "default-ec2"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.http_server_sg.id]
    for_each = toset(data.aws_subnets.default_subnets.ids)
    subnet_id = each.value

    tags = {
      name: "http_servers_${each.value}"
    }

    connection {
      type = "ssh"
      host = self.public_ip
      user = "ec2-user"
      private_key = file(var.aws_key_par)
    }

    provisioner "remote-exec" {
      inline = [
        # install httpd
        "sudo yum install httpd -y",
        # start server
        "sudo service httpd start",
        # copy a file
        "echo Welcome to AWS Virtual server ${self.public_dns} | sudo tee /var/www/html/index.html"
      ]
    }
}