resource "aws_route53_zone" "main" {
  name = "shorts.codes"
}

output "route53_nameservers" {
  value = aws_route53_zone.main.name_servers
}


resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "shorts.codes"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}


resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.shorts.codes"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}