terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

provider "aws" {
  region     = "us-east-2"
  access_key = ""
  secret_key = ""
  
}

#Aqui defino la vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}

#Aqui defino la subnet publica
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
     name= "MySubnetPublica"
   }
}

#Aqui defino la subnet privada
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  tags = {
     name= "MySubnetPrivada"
   }
}

# Define una tabla de ruta  publica
resource "aws_route_table" "my_route_table_public" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    name="mi_tabla_de_ruta_publica"
  }
}


# Asocia la tabla de ruta a la subred pública
resource "aws_route_table_association" "public_subnet_association_public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.my_route_table_public.id
}


# Define una tabla de ruta  privada
resource "aws_route_table" "my_route_table_private" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    name="mi_tabla_de_ruta_private"
  }
}


# Asocia la tabla de ruta a la subred pública
resource "aws_route_table_association" "public_subnet_association_private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.my_route_table_private.id
}  


# Define un Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}


resource "aws_route" "route_to_internet_gateway_public" {
  route_table_id         = aws_route_table.my_route_table_public.id    
  destination_cidr_block = "0.0.0.0/0"                 
  gateway_id             = aws_internet_gateway.my_igw.id 
}

resource "aws_route" "route_to_internet_gateway_private" {
  route_table_id         = aws_route_table.my_route_table_private.id    
  destination_cidr_block = "0.0.0.0/0"                 
  gateway_id             = aws_internet_gateway.my_igw.id 
}




# Define la primera instancia EC2
resource "aws_instance" "my_instance1" {
  ami                    = "ami-0ddda618e961f2270"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "MyInstance1"
  }
}

# Define la primera instancia EC2
resource "aws_instance" "my_instance2" {
  ami                    = "ami-0ddda618e961f2270"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "MyInstance2"
  }
}
