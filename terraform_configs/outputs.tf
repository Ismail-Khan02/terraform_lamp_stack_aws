# Outputs for important information
output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.lamp_instance.public_ip
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.lamp_instance.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.web_sg.id
}

output "webserver_url" {
  description = "The URL to access the web server"
  value       = "http://${aws_instance.lamp_instance.public_ip}/my-app.php"
}

