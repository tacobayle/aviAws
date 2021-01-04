data "aws_route53_zone" "awsAviDemo" {
  name         = var.domain["name"]
}

resource "aws_route53_record" "jump" {
  zone_id = data.aws_route53_zone.awsAviDemo.zone_id
  name    = "${var.jump["hostname"]}.${var.domain["name"]}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.jump.public_ip]
}

  resource "aws_route53_record" "aviCtrl" {
    zone_id = data.aws_route53_zone.awsAviDemo.zone_id
    name    = "${var.controller["hostname"]}.${var.domain["name"]}"
    type    = "A"
    ttl     = "300"
    records = [aws_instance.aviCtrl[0].public_ip]
}
