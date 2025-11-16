########################################
# Namespace
########################################

resource "kubernetes_namespace" "tasky" {
  metadata {
    name = var.app_namespace

    labels = {
      project     = var.project
      environment = var.environment_name
    }
  }
}

########################################
# Deployment
########################################

resource "kubernetes_deployment" "tasky" {
  metadata {
    name      = "${local.name_prefix}-tasky"
    namespace = kubernetes_namespace.tasky.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.common_labels
    }

    template {
      metadata {
        labels = local.common_labels
      }

      spec {
        container {
          name  = "tasky"
          image = local.image

          port {
            container_port = var.app_port
          }

          # Add env vars here if needed, e.g. Mongo URI
          # env {
          #   name  = "MONGO_URI"
          #   value = var.mongo_uri
          # }
        }
      }
    }
  }
}

########################################
# Service
########################################

resource "kubernetes_service" "tasky" {
  metadata {
    name      = "${local.name_prefix}-tasky-svc"
    namespace = kubernetes_namespace.tasky.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    selector = local.common_labels

    port {
      port        = 80
      target_port = var.app_port
      protocol    = "TCP"
    }
  }
}

########################################
# Ingress (ALB)
########################################

resource "kubernetes_ingress_v1" "tasky" {
  metadata {
    name      = "${local.name_prefix}-tasky-ingress"
    namespace = kubernetes_namespace.tasky.metadata[0].name
    labels    = local.common_labels

    annotations = {
      "kubernetes.io/ingress.class"                  = "alb"
      "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"        = "ip"
      "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTP\":80}]"
      # Add external-dns annotations here if you're using it
    }
  }

  spec {
    rule {
      http {
        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.tasky.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
