provider "aws" {
  region = "us-east-1"
}

# Create Key Pair
resource "aws_key_pair" "cloud9_key_pair" {
  key_name   = "final"
  public_key = file("final.pub")
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "ACS730_Final_Project_VPC"
  }
}

# Create Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public-Subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public-Subnet-2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Public-Subnet-3"
  }
}

resource "aws_subnet" "public_subnet_4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.4.0/24"
  availability_zone = "us-east-1d"

  tags = {
    Name = "Public-Subnet-4"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.5.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private-Subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.1.6.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private-Subnet-2"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet-Gateway"
  }
}

# Create Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_3_association" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_4_association" {
  subnet_id      = aws_subnet.public_subnet_4.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "NAT-Gateway"
  }
}

resource "aws_eip" "nat_gateway" {
  domain = "vpc"
}


# Create Route Table for Private Subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "Private-Route-Table"
  }
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Associate Route Table with Private Subnets
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Create Security Groups
resource "aws_security_group" "webserver_sg" {
  name   = "ACS730_Final_Project_Webserver_SG"
  vpc_id = aws_vpc.main.id

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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Webserver-SG"
  }
}

resource "aws_security_group" "bastion_sg" {
  name   = "ACS730_Final_Project_Bastion_SG"
  vpc_id = aws_vpc.main.id

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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion-SG"
  }
}

resource "aws_security_group" "private_subnet_sg" {
  name   = "ACS730_Final_Project_Private_Subnet_SG"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "Private-Subnet-SG"
  }
}

# Launch EC2 Instances
resource "aws_instance" "webserver_1" {
  ami                         = "ami-007868005aea67c54" # Updated AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_1.id
  key_name                    = aws_key_pair.cloud9_key_pair.key_name # Corrected reference to key pair name
  vpc_security_group_ids      = [aws_security_group.webserver_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Webserver-1"
  }
}

resource "aws_instance" "webserver_2" {
  ami                         = "ami-007868005aea67c54" # Updated AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_2.id
  key_name                    = aws_key_pair.cloud9_key_pair.key_name # Corrected reference to key pair name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "Bastion-Host"
  }
}

resource "aws_instance" "webserver_3" {
  ami                         = "ami-007868005aea67c54" # Updated AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_3.id
  key_name                    = aws_key_pair.cloud9_key_pair.key_name # Corrected reference to key pair name
  vpc_security_group_ids      = [aws_security_group.webserver_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "Webserver-3"
  }
}

resource "aws_instance" "webserver_4" {
  ami                         = "ami-007868005aea67c54" # Updated AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_4.id
  key_name                    = aws_key_pair.cloud9_key_pair.key_name # Corrected reference to key pair name
  vpc_security_group_ids      = [aws_security_group.webserver_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "Webserver-4"
  }
}

resource "aws_instance" "webserver_5" {
  ami                    = "ami-007868005aea67c54" # Updated AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_1.id
  key_name               = aws_key_pair.cloud9_key_pair.key_name # Corrected reference to key pair name
  vpc_security_group_ids = [aws_security_group.private_subnet_sg.id]
  tags = {
    Name = "Webserver-5"
  }
}

resource "aws_instance" "webserver_6" {
  ami                    = "ami-007868005aea67c54" # Updated AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet_2.id
  key_name               = aws_key_pair.cloud9_key_pair.key_name # Corrected reference to key pair name
  vpc_security_group_ids = [aws_security_group.private_subnet_sg.id]

  tags = {
    Name = "VM-6"
  }
}

# Create Load Balancer
resource "aws_lb" "main" {
  name               = "acs730-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webserver_sg.id]
  subnets            = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
    aws_subnet.public_subnet_3.id,
    aws_subnet.public_subnet_4.id,
  ]

  tags = {
    Name = "ACS730_Load_Balancer"
  }
}

# Create Target Group
resource "aws_lb_target_group" "main" {
  name        = "acs730-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ACS730_Target_Group"
  }
}

# Create Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Attach EC2 Instances to the Target Group
resource "aws_lb_target_group_attachment" "webserver_1_attachment" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.webserver_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "webserver_3_attachment" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.webserver_3.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "webserver_4_attachment" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.webserver_4.id
  port             = 80
}

# Outputs
output "load_balancer_dns_name" {
  value = aws_lb.main.dns_name
}
