data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/${var.ubuntu_version}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical ID
}



resource "aws_security_group" "jenkins-master" {
  name        = "${var.name}-sg"
  description = "Jenkins Master Security Group"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    security_groups = ["${aws_security_group.jenkins-public-lb.id}"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.name}"
    Environment = "${var.env}"
  }
}

resource "aws_instance" "jenkins" {
  ami                   = "${data.aws_ami.ubuntu.id}"
  instance_type         = "${var.instance_type}"
  user_data             = "${file("${path.module}/user-data/jenkins-userdata.sh")}"
  ebs_optimized         = true
  key_name              = "aws-Simon"
  subnet_id             = "${element(var.subnet_ids, 0)}"
  security_groups       = ["${aws_security_group.jenkins-master.id}"]



  tags = {
    Name                = "${var.name}-master"
    Environment         = "${var.env}"
  }
}

resource "aws_ebs_volume" "jenkins-ebs" {
    availability_zone = "${var.region}a"
    size              = 20
    type            = "gp2"
    
    tags = {
        Name        = "${var.env}-${var.name}-ebs"
        Environment = "${var.env}"
    }
}

resource "aws_volume_attachment" "ebs-att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.jenkins-ebs.id}"
  instance_id = "${aws_instance.jenkins.id}"
}


resource "aws_lb" "jenkins-public-lb" {

    load_balancer_type          = "application"
    security_groups             = ["${aws_security_group.jenkins-public-lb.id}"]
    subnets                     = ["${var.subnet_ids}"]
    name                        = "${var.name}-public-lb"
    internal                    = "false"
    idle_timeout                = "3600"

}

resource "aws_security_group" "jenkins-public-lb" {
  name        = "${var.name}-public-lb"
  description = "Jenkins Load Balancer Security Group"
  vpc_id      = "${var.vpc}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.name}"
    Environment = "${var.env}"
  }
}


resource "aws_lb_target_group" "jenkins" {
  name              = "${var.name}-tg"
  port              = 8080
  protocol          = "HTTP"
  vpc_id            = "${var.vpc}"

}

resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = "${aws_lb_target_group.jenkins.arn}"
  target_id        = "${aws_instance.jenkins.id}"
  port             = 8080
}


resource "aws_lb_listener" "jenkins" {
  load_balancer_arn = "${aws_lb.jenkins-public-lb.arn}"
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.jenkins.arn}"
  }
}