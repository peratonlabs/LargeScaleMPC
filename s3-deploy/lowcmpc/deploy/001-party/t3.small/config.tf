data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
    default = "us-east-2"
}

provider "aws" {
    region = "us-east-2"
    alias = "us-east-2"
}

data "aws_ami" "us-east-2" {
  provider = aws.us-east-2

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "us-east-2" {
    provider = aws.us-east-2
    name = "us-east-2-sg"
    description = "Allow all"

    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
   }

    tags = {
        Name = "us-east-2-sg"
    }
}

resource "aws_eip" "mpc001" {
  provider = aws.us-east-2
  instance = aws_instance.mpc001.id
  vpc = true
}

resource "aws_instance" "mpc001" {
  provider = aws.us-east-2
  availability_zone = "us-east-2a"
  ami           = "${data.aws_ami.us-east-2.id}"
  instance_type = "t3.small"
  key_name = "dstarin_aws"
  user_data = file("userdata.sh")

#  root_block_device {
#      volume_type = "gp2"
#      volume_size = "100"
#      delete_on_termination = "true"
#  }

  tags = {
    Name = "mpc001"
  }

  security_groups = ["${aws_security_group.us-east-2.name}"]
}