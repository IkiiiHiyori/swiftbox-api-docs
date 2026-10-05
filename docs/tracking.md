---
title: Order Tracking
description: Track your SwiftBox shipments in real time and set up webhook notifications for status updates.
tags: [tracking, webhooks, notifications]
---

# Order Tracking

Monitor shipments through the SwiftBox dashboard or integrate webhook notifications for automated status updates.

!!! note
    All timestamps in tracking responses and webhook payloads use UTC in ISO 8601 format.

## Order Status Lifecycle

Every shipment progresses through a standard set of statuses during delivery.

| Status | Description | Typical Duration |
|--------|-------------|------------------|
| `PENDING_PICKUP` | Order is confirmed and waiting for pickup scheduling or drop-off. | Immediate to 1 business day |
| `PICKUP_SCHEDULED` | Carrier is assigned and pickup time is confirmed. | 1-2 hours |
| `IN_TRANSIT` | Shipment is moving through the SwiftBox network. | 1-5 business days |
| `OUT_FOR_DELIVERY` | Shipment is with the local carrier for final delivery. | Same day |
| `DELIVERED` | Shipment was successfully delivered. | Final |
| `DELIVERY_ATTEMPTED` | Recipient was unavailable or delivery could not be completed. | 1 business day |
| `EXCEPTION` | Shipment is delayed due to weather, address issues, customs, or other external factors. | Variable |
| `RETURNED` | Shipment is being returned to the sender. | 1-5 business days |
| `CANCELLED` | Order was cancelled before delivery completion. | Final |

!!! note
    Status updates may vary based on service level, destination, and external factors such as weather, holidays, or customs processing.

## Webhook Notifications

Configure webhooks to receive real-time status updates for your orders. Webhooks are sent as HTTP `POST` requests to your configured endpoint.

You can also manage webhook subscriptions with the [Partner API](api.md#webhooks).

### Setting Up Webhooks

1. Navigate to **Settings** > **Webhooks** in your dashboard.
2. Enter your webhook URL.
3. Select the events you want to subscribe to.
4. Add or generate a webhook secret.
5. Save your configuration.

### Webhook Payload Example

```json
{
  "event": "order.status_updated",
  "timestamp": "2025-01-15T10:30:00Z",
  "order_id": "SBX-789456123",
  "tracking_number": "1Z999AA10123456784",
  "status": "IN_TRANSIT",
  "location": {
    "city": "Chicago",
    "state": "IL",
    "country": "US"
  },
  "estimated_delivery": "2025-01-18T17:00:00Z",
  "metadata": {
    "carrier": "SwiftBox Express",
    "service_level": "standard"
  }
}
```

!!! tip
    Store the raw request body before parsing JSON. Signature verification must use the exact bytes SwiftBox sent.

### Webhook Security

SwiftBox signs each webhook request with an HMAC-SHA256 signature in the `X-SwiftBox-Signature` header. Verify the signature before processing the event.

```javascript
const crypto = require("crypto");

function verifySwiftBoxSignature(rawBody, signatureHeader, secret) {
  if (!signatureHeader || !secret) {
    return false;
  }

  const expectedSignature = crypto
    .createHmac("sha256", secret)
    .update(rawBody)
    .digest("hex");

  const expected = Buffer.from(expectedSignature, "hex");
  const received = Buffer.from(signatureHeader, "hex");

  return (
    expected.length === received.length &&
    crypto.timingSafeEqual(expected, received)
  );
}
```

!!! warning
    Reject webhook requests that are missing a signature or fail verification. Do not process the payload until the signature is valid.

### Retry Policy

Your endpoint must respond with `200 OK` within 5 seconds. SwiftBox retries failed deliveries with exponential backoff.

| Retry Attempt | Delay Before Retry | Trigger |
|---------------|--------------------|---------|
| 1 | 1 second | Non-2xx response or timeout |
| 2 | 2 seconds | Non-2xx response or timeout |
| 3 | 4 seconds | Final retry after repeated failure |

SwiftBox stops after 3 retry attempts. Repeated failures may disable the webhook endpoint until it is updated and re-enabled.

### Example Webhook Receiver

This Flask example verifies the signature, parses the event, and returns quickly. Move long-running work to a background queue.

```python
import hashlib
import hmac
import os

from flask import Flask, abort, request

app = Flask(__name__)
WEBHOOK_SECRET = os.environ["SWIFTBOX_WEBHOOK_SECRET"]


def verify_signature(raw_body: bytes, signature: str, secret: str) -> bool:
    if not signature:
        return False

    expected = hmac.new(
        secret.encode("utf-8"),
        raw_body,
        hashlib.sha256,
    ).hexdigest()
    return hmac.compare_digest(expected, signature)


@app.post("/webhooks/swiftbox")
def receive_swiftbox_webhook():
    raw_body = request.get_data()
    signature = request.headers.get("X-SwiftBox-Signature", "")

    if not verify_signature(raw_body, signature, WEBHOOK_SECRET):
        abort(401)

    event = request.get_json(silent=True)
    if event is None:
        abort(400)

    # Store the event ID or order ID before processing to avoid duplicates.
    print(f"Received {event['event']} for order {event['order_id']}")
    return {"received": True}, 200
```

### Response Requirements

Your webhook endpoint must respond with a `200 OK` status code within 5 seconds. Return a non-2xx status only when SwiftBox should retry the event.

!!! warning
    If your webhook endpoint returns errors or times out repeatedly, notifications for that endpoint may be automatically disabled.
