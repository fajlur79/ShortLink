data "cloudflare_zone" "main" {
  name = var.domain_name
}
resource "cloudflare_record" "root" {
  zone_id = data.cloudflare_zone.main.id
  name    = "@"
  content   = aws_lb.app_lb.dns_name
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zone.main.id
  name    = "www"
  content   = aws_lb.app_lb.dns_name
  type    = "CNAME"
  proxied = true
}

