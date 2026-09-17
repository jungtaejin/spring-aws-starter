output "alb_dns_name" {
  description = "Open http://<this>/actuator/health after the first deploy."
  value       = aws_lb.app.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "asg_name" {
  value = aws_autoscaling_group.app.name
}

output "github_actions_role_arn" {
  description = "Put this in the GitHub repository secret AWS_ROLE_ARN."
  value       = aws_iam_role.github_deploy.arn
}

output "rds_endpoint" {
  value     = aws_db_instance.main.address
  sensitive = true
}
