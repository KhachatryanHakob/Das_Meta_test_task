resource "time_sleep" "wait_for_alb_controller" {
  depends_on = [
    helm_release.aws_load_balancer_controller
  ]

  create_duration  = "30s"
  destroy_duration = "180s"
}

resource "helm_release" "application" {
  name      = "demo-app"
  namespace = "demo"

  create_namespace = true

  chart = "${path.module}/../helm/demo-app"

  values = [
    file("${path.module}/../helm/demo-app/values.yaml")
  ]

  wait    = true
  timeout = 300

  depends_on = [
    time_sleep.wait_for_alb_controller
  ]
}