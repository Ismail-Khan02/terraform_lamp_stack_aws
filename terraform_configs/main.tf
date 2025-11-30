# Create an EC2 instance for the LAMP stack
resource "aws_instance" "lamp_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  security_groups        = [aws_security_group.web_sg.name]
  subnet_id              = aws_subnet.public-subnet-1.id

  user_data              = file("install_lamp.sh")

  tags = {
    Name = "LAMP_Server"
  }
}