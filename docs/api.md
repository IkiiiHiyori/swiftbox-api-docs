---
title: Partner API
description: Integrate SwiftBox delivery services into your application with our RESTful API.
tags: [api, integration, developers]
---

# Partner API

The SwiftBox Partner API provides programmatic access to delivery services, including order creation, tracking, webhook management, and account workflows. Build custom integrations that automate your shipping operations.

!!! note
    The current API version is `v1`. Breaking changes will be announced with a migration guide before a new version becomes required.

## Authentication

All API requests require authentication with an API key. Include your key in the `X-API-Key` header with each request.

!!! warning
    Never expose your API key in client-side code or public repositories. Rotate keys immediately if they are compromised.

### Obtaining Your API Key

1. Navigate to **Settings** > **API Keys** in your dashboard.
2. Click **Generate New Key**.
3. Copy the key and store it securely.
4. Keys are displayed only once. Save them immediately.

!!! note
    Business and Enterprise plans support multiple API keys with granular permissions for different applications or environments.

### Authentication Failure Example

Requests with a missing or invalid API key return `401 Unauthorized`.

```bash
curl -i -X GET https://api.swiftbox.com/api/v1/orders/SBX-789456123 \
  -H "Content-Type: application/json"
```

```json
{
  "error": {
    "code": "unauthorized",
    "message": "A valid API key is required.",
    "request_id": "req_01HZX7A4Q7Y3Z"
  }
}
```

## OpenAPI Specification

Download the full OpenAPI definition: [swiftbox-openapi.yaml](swiftbox-openapi.yaml).

Preview:

```yaml
openapi: 3.1.0
info:
  title: SwiftBox Partner API
  version: 1.0.0
servers:
  - url: https://api.swiftbox.com/api/v1
paths:
  /orders:
    post:
      summary: Create a new delivery order
      security:
        - ApiKeyAuth: []
      responses:
        "201":
          description: Order created
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/orders` | Create a new delivery order. |
| `GET` | `/api/v1/orders/{order_id}` | Retrieve order details. |
| `PATCH` | `/api/v1/orders/{order_id}` | Update order details. |
| `DELETE` | `/api/v1/orders/{order_id}` | Cancel an order. |
| `GET` | `/api/v1/orders/{order_id}/tracking` | Get real-time tracking status. |
| `GET` | `/api/v1/webhooks` | List configured webhooks. |
| `POST` | `/api/v1/webhooks` | Register a new webhook. |
| `DELETE` | `/api/v1/webhooks/{webhook_id}` | Remove a webhook. |

## Orders

### Create an Order

Creates a new delivery order and returns the assigned order ID and tracking number.

**cURL**

```bash
curl -i -X POST https://api.swiftbox.com/api/v1/orders \
  -H "X-API-Key: your_api_key_here" \
  -H "Content-Type: application/json" \
  -d '{
    "recipient": {
      "name": "Jane Smith",
      "address": "123 Main St",
      "city": "San Francisco",
      "state": "CA",
      "zip": "94102",
      "country": "US",
      "phone": "+14155551234"
    },
    "package": {
      "weight": 2.5,
      "dimensions": {
        "length": 12,
        "width": 8,
        "height": 4
      }
    },
    "service_level": "express"
  }'
```

**Python**

```python
import requests

url = "https://api.swiftbox.com/api/v1/orders"
headers = {
    "X-API-Key": "your_api_key_here",
    "Content-Type": "application/json",
}
payload = {
    "recipient": {
        "name": "Jane Smith",
        "address": "123 Main St",
        "city": "San Francisco",
        "state": "CA",
        "zip": "94102",
        "country": "US",
        "phone": "+14155551234",
    },
    "package": {
        "weight": 2.5,
        "dimensions": {
            "length": 12,
            "width": 8,
            "height": 4,
        },
    },
    "service_level": "express",
}

try:
    response = requests.post(url, json=payload, headers=headers, timeout=10)
    response.raise_for_status()
except requests.HTTPError as exc:
    print(f"SwiftBox API error: {exc.response.status_code} {exc.response.text}")
    raise
except requests.RequestException as exc:
    print(f"Network error calling SwiftBox: {exc}")
    raise

order = response.json()
print(f"Order created: {order['order_id']}")
```

**Example response**

```json
{
  "order_id": "SBX-789456123",
  "tracking_number": "1Z999AA10123456784",
  "status": "PENDING_PICKUP",
  "created_at": "2025-01-15T10:00:00Z"
}
```

### Retrieve an Order

```bash
curl -i -X GET https://api.swiftbox.com/api/v1/orders/SBX-789456123 \
  -H "X-API-Key: your_api_key_here"
```

```json
{
  "order_id": "SBX-789456123",
  "tracking_number": "1Z999AA10123456784",
  "status": "IN_TRANSIT",
  "service_level": "express",
  "recipient": {
    "name": "Jane Smith",
    "city": "San Francisco",
    "state": "CA",
    "country": "US"
  },
  "created_at": "2025-01-15T10:00:00Z",
  "updated_at": "2025-01-15T14:30:00Z"
}
```

### Update an Order

Use `PATCH` to update editable order fields before the shipment is picked up.

```bash
curl -i -X PATCH https://api.swiftbox.com/api/v1/orders/SBX-789456123 \
  -H "X-API-Key: your_api_key_here" \
  -H "Content-Type: application/json" \
  -d '{
    "recipient": {
      "phone": "+14155559876"
    },
    "delivery_instructions": "Leave with front desk."
  }'
```

```json
{
  "order_id": "SBX-789456123",
  "status": "PENDING_PICKUP",
  "updated_at": "2025-01-15T10:15:00Z"
}
```

### Cancel an Order

Use `DELETE` to cancel an order before it is picked up.

```bash
curl -i -X DELETE https://api.swiftbox.com/api/v1/orders/SBX-789456123 \
  -H "X-API-Key: your_api_key_here"
```

```json
{
  "order_id": "SBX-789456123",
  "status": "CANCELLED",
  "cancelled_at": "2025-01-15T10:20:00Z"
}
```

### Get Real-Time Tracking Status

```bash
curl -i -X GET https://api.swiftbox.com/api/v1/orders/SBX-789456123/tracking \
  -H "X-API-Key: your_api_key_here"
```

```python
import requests

order_id = "SBX-789456123"
url = f"https://api.swiftbox.com/api/v1/orders/{order_id}/tracking"
headers = {"X-API-Key": "your_api_key_here"}

try:
    response = requests.get(url, headers=headers, timeout=10)
    response.raise_for_status()
except requests.HTTPError as exc:
    print(f"SwiftBox API error: {exc.response.status_code} {exc.response.text}")
    raise
except requests.RequestException as exc:
    print(f"Network error calling SwiftBox: {exc}")
    raise

tracking = response.json()
print(f"Current status: {tracking['status']}")
```

```json
{
  "order_id": "SBX-789456123",
  "tracking_number": "1Z999AA10123456784",
  "status": "IN_TRANSIT",
  "events": [
    {
      "status": "PENDING_PICKUP",
      "timestamp": "2025-01-15T10:00:00Z",
      "location": null
    },
    {
      "status": "IN_TRANSIT",
      "timestamp": "2025-01-15T14:30:00Z",
      "location": {
        "city": "Chicago",
        "state": "IL",
        "country": "US"
      }
    }
  ]
}
```

!!! note
    Tracking statuses match the lifecycle documented in [Order Tracking](tracking.md#order-status-lifecycle).

## Webhooks

### List Webhooks

Use `limit` and `offset` to paginate webhook subscriptions. The default limit is `10`; the maximum limit is `100`.

```bash
curl -i -X GET "https://api.swiftbox.com/api/v1/webhooks?limit=10&offset=0" \
  -H "X-API-Key: your_api_key_here"
```

```json
{
  "data": [
    {
      "webhook_id": "wh_01HZX6VC8R9K",
      "url": "https://example.com/webhooks/swiftbox",
      "events": ["order.created", "order.status_updated"],
      "active": true,
      "created_at": "2025-01-10T09:00:00Z"
    }
  ],
  "pagination": {
    "limit": 10,
    "offset": 0,
    "total": 1,
    "next": null
  }
}
```

### Register a Webhook

Register a webhook endpoint and secret. SwiftBox uses the secret to sign webhook requests.

```bash
curl -i -X POST https://api.swiftbox.com/api/v1/webhooks \
  -H "X-API-Key: your_api_key_here" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://example.com/webhooks/swiftbox",
    "events": [
      "order.created",
      "order.status_updated",
      "order.cancelled"
    ],
    "secret": "replace_with_a_strong_random_secret"
  }'
```

```json
{
  "webhook_id": "wh_01HZX6VC8R9K",
  "url": "https://example.com/webhooks/swiftbox",
  "events": [
    "order.created",
    "order.status_updated",
    "order.cancelled"
  ],
  "active": true,
  "created_at": "2025-01-15T10:25:00Z"
}
```

See [Webhook Security](tracking.md#webhook-security) for HMAC verification guidance.

### Delete a Webhook

```bash
curl -i -X DELETE https://api.swiftbox.com/api/v1/webhooks/wh_01HZX6VC8R9K \
  -H "X-API-Key: your_api_key_here"
```

```json
{
  "webhook_id": "wh_01HZX6VC8R9K",
  "deleted": true
}
```

## Error Responses

Errors use a consistent JSON envelope.

| HTTP Status | Code | Meaning |
|-------------|------|---------|
| `400` | `bad_request` | The request body, query parameter, or path parameter is invalid. |
| `401` | `unauthorized` | The API key is missing, invalid, or expired. |
| `403` | `forbidden` | The API key does not have permission for the requested resource. |
| `404` | `not_found` | The requested order, shipment, or webhook was not found. |
| `429` | `rate_limited` | The account exceeded the allowed request rate. |
| `500` | `internal_error` | SwiftBox could not process the request due to an internal error. |

### Example Error Bodies

```json
{
  "error": {
    "code": "bad_request",
    "message": "The recipient.zip field is required.",
    "request_id": "req_01HZX7A4Q7Y3A"
  }
}
```

```json
{
  "error": {
    "code": "unauthorized",
    "message": "A valid API key is required.",
    "request_id": "req_01HZX7A4Q7Y3B"
  }
}
```

```json
{
  "error": {
    "code": "forbidden",
    "message": "This API key cannot manage webhooks.",
    "request_id": "req_01HZX7A4Q7Y3C"
  }
}
```

```json
{
  "error": {
    "code": "not_found",
    "message": "Order SBX-789456123 was not found.",
    "request_id": "req_01HZX7A4Q7Y3D"
  }
}
```

```json
{
  "error": {
    "code": "rate_limited",
    "message": "Rate limit exceeded. Retry after 30 seconds.",
    "request_id": "req_01HZX7A4Q7Y3E"
  }
}
```

```json
{
  "error": {
    "code": "internal_error",
    "message": "An unexpected error occurred. Try again later.",
    "request_id": "req_01HZX7A4Q7Y3F"
  }
}
```

## Rate Limits

API requests are rate-limited to ensure fair usage:

- **Starter**: 100 requests per minute
- **Business**: 1,000 requests per minute
- **Enterprise**: 10,000 requests per minute

Rate limit headers are included in every API response:

- `X-RateLimit-Limit`: Maximum requests allowed in the current window.
- `X-RateLimit-Remaining`: Requests remaining in the current window.
- `X-RateLimit-Reset`: Unix timestamp when the current window resets.
- `Retry-After`: Seconds to wait before retrying, included with `429` responses.

Example `429 Too Many Requests` response:

```http
HTTP/1.1 429 Too Many Requests
Content-Type: application/json
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1736953200
Retry-After: 30
```

```json
{
  "error": {
    "code": "rate_limited",
    "message": "Rate limit exceeded. Retry after 30 seconds.",
    "request_id": "req_01HZX7A4Q7Y3E"
  }
}
```

!!! tip
    Implement exponential backoff when receiving `429 Too Many Requests` responses, and use the `Retry-After` header when it is present.
