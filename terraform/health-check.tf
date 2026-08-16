data "aws_lb" "application" {
  tags = {
    "ingress.k8s.aws/stack" = "demo/demo-app"
  }

  depends_on = [
    helm_release.application
  ]
}

resource "aws_route53_health_check" "application" {
  fqdn = data.aws_lb.application.dns_name

  port = 80
  type = "HTTP"

  resource_path = "/"

  request_interval  = 30
  failure_threshold = 3

  tags = {
    Name = "devops-test-application-health-check"
  }
}