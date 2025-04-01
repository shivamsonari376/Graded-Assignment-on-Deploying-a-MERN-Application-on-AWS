# Create a VPC
resource "aws_vpc" "mern_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "Yogesh-MERN-VPC"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.mern_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Yogesh-Public-Subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.mern_vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "Yogesh-Private-Subnet"
  }
}

# Internet Gateway for public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mern_vpc.id

  tags = {
    Name = "Yogesh-Internet-Gateway"
  }
}

# Route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.mern_vpc.id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for Web Server
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.mern_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebServer Security Group"
  }
}

# Security Group for Database Server
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.mern_vpc.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database Security Group"
  }
}

# Launch Web Server in Public Subnet
resource "aws_instance" "web_server_frontend" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.web_sg.name]
  key_name        = var.key_name

  tags = {
    Name = "Yogesh-WebServer-FrontEnd"
  }
}

# Launch Web Server in Public Subnet
resource "aws_instance" "web_server_backend" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.web_sg.name]
  key_name        = var.key_name

  tags = {
    Name = "Yogesh-WebServer-Backend"
  }
}

# Launch Database Server in Private Subnet
resource "aws_instance" "db_server" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.db_sg.name]

  tags = {
    Name = "Yogesh-DatabaseServer"
  }
}
