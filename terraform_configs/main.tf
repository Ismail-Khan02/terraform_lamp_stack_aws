# Create an EC2 instance for the LAMP stack
resource "aws_instance" "lamp_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer_key.key_name
  security_groups        = [aws_security_group.web_sg.name]
  subnet_id              = aws_subnet.main.id

  user_data              = file("install_lamp.sh")

  tags = {
    Name = "LAMP_Server"
  }
}