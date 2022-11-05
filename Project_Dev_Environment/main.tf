resource "aws_vpc" "dev_vpc" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "dev_vpc"
  }
}
resource "aws_subnet" "dev_subnet" {
  vpc_id     = aws_vpc.dev_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "dev_subnet"
  }
}
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev_igw"
  }
}

resource "aws_route_table" "dev_public_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

    tags = {
    Name = "dev_public_route_table"
  }
}
resource "aws_route" "default_rte"{
    route_table_id = aws_route_table.dev_public_route_table.id
    destination_cidr_block= "0.0.0.0/0"
    gateway_id= aws_internet_gateway.dev_igw.id
}
resource "aws_route_table_association" "dev_public_rt_asso"{
    subnet_id = aws_subnet.dev_subnet.id
    route_table_id = aws_route_table.dev_public_route_table.id
}
resource "aws_security_group" "dev_security_group" {
  name        = "dev_security_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev_security_group"
  }
}
resource "aws_key_pair" "dev_key" {
  key_name   = "dev_key"
  public_key = file("~/.ssh/mtckey.pub")
}

resource "aws_instance" "dev_node_1" {
  instance_type = "t2.micro"
  ami = "ami-09d3b3274b6c5d4aa"
  
  tags= { 
    Name= "dev_node_1"
  }
  key_name = aws_key_pair.dev_key.id
  vpc_security_group_ids = [aws_security_group.dev_security_group.id]
  subnet_id = aws_subnet.dev_subnet.id
  user_data = file("userdata2.tpl")

  root_block_device {
    volume_size=10
  }
}
