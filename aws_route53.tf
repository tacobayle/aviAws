data "aws_route53_zone" "awsAviDemo" {
  name         = var.aws.domains[0].name
}

resource "aws_route53_record" "jump" {
  zone_id = data.aws_route53_zone.awsAviDemo.zone_id
  name    = "${var.jump["hostname"]}.${var.aws.domains[0].name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.jump.public_ip]
}

  resource "aws_route53_record" "aviCtrl" {
    zone_id = data.aws_route53_zone.awsAviDemo.zone_id
    name    = "${var.controller["hostname"]}.${var.aws.domains[0].name}"
    type    = "A"
    ttl     = "300"
    records = [aws_instance.aviCtrl[0].public_ip]
}
