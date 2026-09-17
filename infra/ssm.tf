# Runtime configuration lives in SSM Parameter Store, not in user-data or the AMI.
# Instances read these at boot (see user_data.sh.tpl); the deploy workflow only has
# to update image_tag and start an instance refresh.

locals {
  ssm_prefix = "/${var.project_name}"
}

resource "aws_ssm_parameter" "db_url" {
  name  = "${local.ssm_prefix}/db/url"
  type  = "String"
  value = "jdbc:postgresql://${aws_db_instance.main.address}:${aws_db_instance.main.port}/${var.db_name}"
}

resource "aws_ssm_parameter" "db_user" {
  name  = "${local.ssm_prefix}/db/user"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  name  = "${local.ssm_prefix}/db/password"
  type  = "SecureString"
  value = var.db_password
}

resource "aws_ssm_parameter" "image_tag" {
  name  = "${local.ssm_prefix}/app/image_tag"
  type  = "String"
  value = var.image_tag

  # The deploy workflow owns this value after the first apply.
  lifecycle {
    ignore_changes = [value]
  }
}
