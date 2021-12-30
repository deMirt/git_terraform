provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}
data "aws_region" "my_region" {}
data "aws_vpcs" "my_vpcs" {}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


#-----------------------------------------------------------------

resource "aws_security_group" "my_webserver" {
  //  name = "WebServer-SG"
  name_prefix = "WebServer-SG"
  lifecycle {
    create_before_destroy = true
  }
  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow 80 443 22"
  }
}

resource "aws_launch_configuration" "web" {
  name_prefix     = "WebServer"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.my_webserver.id]
  user_data = templatefile("user_data.sh.tpl", {
    region = data.aws_region.my_region.name,
    info   = data.aws_region.my_region.description,
    digits = ["1", "2", "3", "4", "5"]
  })

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "web" {

  name                 = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_elb.WebServer_ELB.id]

  dynamic "tag" {

    for_each = {
      Name    = "WebServer in asg"
      Owner   = "Mikalayenka Dzmitry"
      tag_key = "tagvalue"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "WebServer_ELB" {

  name               = "WebServer-elb"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.my_webserver.id]



  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }



  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  tags = {
    Name = "WebServer-Available-EBL"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "Default subnet"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "Default subnet"
  }
}



#---------------------------------------------------------------

output "web_loadbalancer_url" {
  value = aws_elb.WebServer_ELB.dns_name
}
