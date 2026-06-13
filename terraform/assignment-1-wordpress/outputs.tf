output "wordpress_public_ip" {
  description = "Public IP address of the WordPress instance"
  value       = aws_instance.wordpress.public_ip
}

output "wordpress_url" {
  description = "WordPress site URL"
  value       = "http://${aws_instance.wordpress.public_ip}"
}