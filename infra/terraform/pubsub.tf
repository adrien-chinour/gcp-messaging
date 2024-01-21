resource "google_pubsub_topic" "order_events" {
  name = "order-events"

  message_retention_duration = "86600s"
}

resource "google_pubsub_subscription" "order_validated_email" {
  name  = "order_validated_email"
  topic = google_pubsub_topic.order_events.name

  ack_deadline_seconds = 20

  push_config {
    push_endpoint = "https://order-api-internal-ihp7ikzfkq-ew.a.run.app/webhook/order_validated_email"
  }

  filter = "attributes.message = \"order_transaction:succeed\""
}

resource "google_pubsub_subscription" "order_send_to_delivery_api" {
  name  = "order_send_to_delivery_api"
  topic = google_pubsub_topic.order_events.name

  ack_deadline_seconds = 20

  push_config {
    push_endpoint = "https://order-api-legacy-ihp7ikzfkq-ew.a.run.app/webhook/order_send_to_delivery_api"
  }

  filter = "attributes.message = \"order_transaction:succeed\""
}

resource "google_pubsub_subscription" "order_failed_email" {
  name  = "order_failed_email"
  topic = google_pubsub_topic.order_events.name

  ack_deadline_seconds = 20

  push_config {
    push_endpoint = "https://order-api-internal-ihp7ikzfkq-ew.a.run.app/webhook/order_failed_email"
  }

  filter = "attributes.message = \"order_transaction:failed\""
}
