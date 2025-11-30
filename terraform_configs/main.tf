# main.tf
resource "aws_instance" "lamp_instance" {
  ami                    = data.aws_ami.amazon_linux_2023.id 
  instance_type          = "t2.micro"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public-subnet-1.id
  user_data              = file("install_lamp.sh")

  tags = {
    Name = "LAMP_Server"
  }
}