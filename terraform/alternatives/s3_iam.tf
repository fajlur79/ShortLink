resource "aws_s3_bucket" "cert_bucket" {
  bucket_prefix = "shortlink-certs-"
  force_destroy = true
}

resource "aws_iam_role" "lb_role" {
  name = "nginx_lb_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}


resource "aws_iam_role_policy" "lb_s3_policy" {
  name = "nginx_lb_s3_policy"
  role = aws_iam_role.lb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.cert_bucket.arn,
        "${aws_s3_bucket.cert_bucket.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "lb_profile" {
  name = "nginx_lb_profile"
  role = aws_iam_role.lb_role.name
}


output "s3_bucket_name" {
  value = aws_s3_bucket.cert_bucket.id
}