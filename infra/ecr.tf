resource "aws_ecr_repository" "app" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE" # "latest" is convenient for a sandbox; use IMMUTABLE + sha tags in prod
  force_delete         = true      # allow `terraform destroy` even with images inside

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Keep the last 10 images so the repository does not grow forever.
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}
