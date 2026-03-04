# main.tf
resource "aws_instance" "lamp_instance" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = aws_subnet.public-subnet-1.id
  user_data              = file("install_lamp.sh")
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name



  tags = {
    Name = "LAMP_Server"
  }
}

resource "aws_eip" "lamp_eip" {
  instance = aws_instance.lamp_instance.id
  domain   = "vpc"

  tags = {
    Name        = "LAMP_EIP"
    Environment = var.environment
  }

}