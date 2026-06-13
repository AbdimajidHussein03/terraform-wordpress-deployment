output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.cloud_init_ec2.public_ip
}

output "website_url" {
  description = "URL to access the cloud-init web page"
  value       = "http://${aws_instance.cloud_init_ec2.public_ip}"
}