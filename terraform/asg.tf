resource "aws_autoscaling_group" "app_asg" {
    name                = "ShortLink-asg"
    vpc_zone_identifier = data.aws_subnets.default.ids

    min_size            = 1
    max_size            = 1
    desired_capacity    = 1

    launch_template {
        id      = aws_launch_template.app_lt.id
        version = "$Latest"
    }
    target_group_arns    = [aws_lb_target_group.app_tg.arn]

    tag {
        key                 = "Role"
        value               = "AppServer"
        propagate_at_launch = true
    }

}