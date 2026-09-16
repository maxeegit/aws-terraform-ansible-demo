resource "aws_s3_bucket" "ansible_ssm" {
  bucket = "${var.project_name}-ansible-ssm"

  tags = {
    Name    = "${var.project_name}-ansible-ssm"
    Project = var.project_name
  }
}
