output "instance_public_ip" {
    value = aws_instance.this.public_ip
    sensitive = false
}

output "grafana_url" {
    value = "http://${aws_instance.this.public_ip}:3000/"
    sensitive = false
}

output "grafana_iam_role_arn" {
    value = aws_iam_role.grafana_role.arn
    sensitive = false
}
