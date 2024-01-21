resource "google_cloud_tasks_queue" "order_transactions" {
  name     = "order-transaction"
  location = var.region

  rate_limits {
    max_dispatches_per_second = 200
    max_concurrent_dispatches = 50
  }

  retry_config {
    max_attempts       = 5
    max_retry_duration = "4s"
    max_backoff        = "3s"
    min_backoff        = "2s"
    max_doublings      = 1
  }

  stackdriver_logging_config {
    sampling_ratio = 0.1
  }
}
