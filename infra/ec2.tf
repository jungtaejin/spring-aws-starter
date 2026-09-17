# Latest Amazon Linux 2023 AMI, resolved at apply time through the public SSM
# parameter so the launch template never hard-codes an AMI id.
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.instance.name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  # IMDSv2 only
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2 # the container needs one extra hop to reach IMDS
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    region         = var.region
    ssm_prefix     = local.ssm_prefix
    ecr_url        = aws_ecr_repository.app.repository_url
    container_port = var.container_port
  }))

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-app" }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "${var.project_name}-asg"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_min_size
  vpc_zone_identifier       = aws_subnet.public[*].id
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Deploy = replace instances one at a time while the ALB keeps at least 50%
  # of capacity healthy.  The deploy workflow triggers this after pushing an image.
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 90
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app"
    propagate_at_launch = true
  }
}
