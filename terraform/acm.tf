resource "aws_acm_certificate" "main" {
  domain_name       = "shorts.codes"
  validation_method = "DNS"
  subject_alternative_names = ["www.shorts.codes"]

  lifecycle {
    create_before_destroy = true
  }
}


resource "cloudflare_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.cloudflare_zone.main.id 
  name    = each.value.name
  content   = each.value.record
  type    = each.value.type
  
  proxied = false 
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  
  validation_record_fqdns = [for record in cloudflare_record.acm_validation : record.hostname]
}

output "certificate_arn" {
  value       = aws_acm_certificate.main.arn
  description = "The ARN of the ACM certificate"
}