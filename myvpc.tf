resource "aws_vpc" "vpc_yatin" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my_vpc"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.vpc_yatin.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private_subnet_2"
  }
}
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.vpc_yatin.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "public_subnet_1"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.vpc_yatin.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_internet_gateway" "igw_yatin" {
  vpc_id = aws_vpc.vpc_yatin.id

  tags = {
    Name = "igw_yatin"
  }
}
resource "aws_eip" "eip_yatin" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway_yatin" {
  allocation_id = aws_eip.eip_yatin.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw_yatin]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc_yatin.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_yatin.id
  }


  tags = {
    Name = "public rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc_yatin.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway_yatin.id
  }


  tags = {
    Name = "private rt"
  }
}


resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private.id
}


resource "aws_key_pair" "my_key1" {
  key_name   = "my_key1"
  public_key ="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCoZ50n1GrQByDkbCwS7qbkH9Hc4RY66h2pZuYCYmwbFZx/8q+xZ17x5jPciPNzRsf4hksDqANJwHIThzZtkPbz08jdKxSkJObA96zBVEyNkNPduRbRACdYNLPHIVXFauBrghf2K/VIEbj4K0qyJOdCOxtXB0C07bkGOVSJA6tgT1ROApxJhbQOvnEy4aC1Y1825L4ouqk0ED47MYqS6FW5qjXpuNZ1W0WhgDTMEGAZVU05qTQOJyfJPxg9HRbpdXZyMBipQjrtHrrX9iXCiFZIxqvoEuoBUMfJ5Pv/o6OzbeyHj9TYCRBmZDPAJdRahpxA+C8xcCL5rqLNvd2aNZlKoSisiZUzqDD7i7G35tYBpXMXiZUx7coZZ3t1UrJiIFKiQy7HXaLCADcms4WHgC5DQZk34s7Or32+bfHfPb+FWdxOg0K1ydjM8kHov2Rx3N1c/mKPoL7orZkhLtxujMGq2X4bp9kGIbov6bV+lOizvb4fIMjP5X3xdZoMQbpm+is= ubuntu@ip-172-31-0-99"
}

resource "aws_security_group" "my_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_yatin.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my_sg"
  }
}




resource "aws_instance" "my_instance" {
  ami                         = "ami-0312223719bcda82b" # us-east-1
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_1.id
  key_name                    = aws_key_pair.my_key1.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.my_sg.id]

}

output "ec2_ip" {

value = aws_instance.my_instance.public_ip
}
