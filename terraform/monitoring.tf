resource "helm_release" "kube_prometheus_stack" {
  name      = "kube-prometheus-stack"
  namespace = "monitoring"

  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "88.3.0"

  values = [
    file("${path.module}/../monitoring/values/kube-prometheus-stack.yaml")
  ]

  wait    = true
  timeout = 900

  depends_on = [
    module.eks
  ]
}

resource "helm_release" "loki" {
  name      = "loki"
  namespace = "monitoring"

  repository = "https://grafana-community.github.io/helm-charts"
  chart      = "loki"
  version    = "18.7.6"

  values = [
    file("${path.module}/../monitoring/values/loki.yaml")
  ]

  wait    = true
  timeout = 600

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}

resource "helm_release" "alloy" {
  name      = "alloy"
  namespace = "monitoring"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  version    = "1.11.1"

  values = [
    file("${path.module}/../monitoring/values/alloy.yaml")
  ]

  wait    = true
  timeout = 600

  depends_on = [
    helm_release.loki
  ]
}

resource "kubernetes_config_map_v1" "grafana_demo_dashboard" {
  metadata {
    name      = "grafana-demo-app-dashboard"
    namespace = "monitoring"

    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "demo-app.json" = file("${path.module}/../monitoring/grafana/dashboards/demo-app.json")
  }

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}

resource "kubernetes_config_map_v1" "grafana_demo_alerts" {
  metadata {
    name      = "grafana-demo-app-alerts"
    namespace = "monitoring"

    labels = {
      grafana_alert = "1"
    }
  }

  data = {
    "demo-app-alerts.yaml" = file(
      "${path.module}/../monitoring/grafana/alerting/demo-app-alerts.yaml"
    )
  }

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}

resource "kubernetes_config_map_v1" "grafana_slack_alerting" {
  metadata {
    name      = "grafana-slack-alerting"
    namespace = "monitoring"

    labels = {
      grafana_alert = "1"
    }
  }

  data = {
    "slack.yaml" = file(
      "${path.module}/../monitoring/grafana/alerting/slack.yaml"
    )
  }

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}