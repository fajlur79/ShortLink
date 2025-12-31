resource "aws_iam_role" "app_role" {
    name = "server_app_role"

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

resource "aws_iam_role_policy_attachment" "app_role_policy"{
    role = aws_iam_role.app_role.name
    policy_arn= "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app_profile" {
    name = "server_app_profile"
    role = aws_iam_role.app_role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy"{
  role        = aws_iam_role.app_role.name
  policy_arn  = "arn:aws:iam:policy/CloudWatchAgentServerPolicy"
}
