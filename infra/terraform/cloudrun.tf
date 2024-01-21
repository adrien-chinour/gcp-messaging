resource "google_cloud_run_v2_service" "order_api_public" {
  name     = "order-api-public"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    timeout                          = "10s"
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN1"
    max_instance_request_concurrency = 4
    scaling {
      min_instance_count = 0
      max_instance_count = 300
    }
    containers {
      image = var.order_api_image
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        cpu_idle          = true
        startup_cpu_boost = true
      }
      ports {
        name           = "http1"
        container_port = 80
      }
      env {
        name  = "SERVER_NAME"
        value = ":80, php:80"
      }
      env {
        name  = "FRANKENPHP_CONFIG"
        value = "worker ./public/index.php 5"
      }
      env {
        name  = "APP_RUNTIME"
        value = "Runtime\\FrankenPhpSymfony\\Runtime"
      }
      env {
        name  = "LOG_ACTION_LEVEL"
        value = "error"
      }
      env {
        name  = "ORDER_QUEUE"
        value = var.order_queue
      }
      env {
        name  = "ALLOW_INTERNAL"
        value = 0
      }
      env {
        name  = "INTERNAL_HOST"
        value = "https://order-api-internal-ihp7ikzfkq-ew.a.run.app"
      }
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}

resource "google_cloud_run_v2_service" "order_api_internal" {
  name     = "order-api-internal"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    timeout                          = "10s"
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN1"
    max_instance_request_concurrency = 4
    scaling {
      min_instance_count = 0
      max_instance_count = 100
    }
    containers {
      image = var.order_api_image
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        startup_cpu_boost = true
      }
      ports {
        name           = "http1"
        container_port = 80
      }
      env {
        name  = "ORDER_QUEUE"
        value = var.order_queue
      }
      env {
        name  = "SERVER_NAME"
        value = ":80, php:80"
      }
      env {
        name  = "FRANKENPHP_CONFIG"
        value = "worker ./public/index.php 5"
      }
      env {
        name  = "APP_RUNTIME"
        value = "Runtime\\FrankenPhpSymfony\\Runtime"
      }
      env {
        name  = "LOG_ACTION_LEVEL"
        value = "error"
      }
      env {
        name  = "ALLOW_INTERNAL"
        value = 1
      }
      env {
        name  = "INTERNAL_HOST"
        value = "https://order-api-internal-ihp7ikzfkq-ew.a.run.app"
      }
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}

resource "google_cloud_run_v2_service" "order_api_legacy" {
  name     = "order-api-legacy"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    timeout                          = "10s"
    execution_environment            = "EXECUTION_ENVIRONMENT_GEN1"
    max_instance_request_concurrency = 2
    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }
    containers {
      image = var.order_api_image
      resources {
        limits = {
          cpu    = "1000m"
          memory = "1Gi"
        }
        startup_cpu_boost = true
      }
      ports {
        name           = "http1"
        container_port = 80
      }
      env {
        name  = "ORDER_QUEUE"
        value = var.order_queue
      }
      env {
        name  = "SERVER_NAME"
        value = ":80, php:80"
      }
      env {
        name  = "FRANKENPHP_CONFIG"
        value = "worker ./public/index.php 4"
      }
      env {
        name  = "APP_RUNTIME"
        value = "Runtime\\FrankenPhpSymfony\\Runtime"
      }
      env {
        name  = "LOG_ACTION_LEVEL"
        value = "error"
      }
      env {
        name  = "ALLOW_INTERNAL"
        value = 1
      }
      env {
        name  = "INTERNAL_HOST"
        value = "https://order-api-internal-ihp7ikzfkq-ew.a.run.app"
      }
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}
