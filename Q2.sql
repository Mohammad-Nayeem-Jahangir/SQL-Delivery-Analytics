/* 
Q2 — Multiple Deliveries to the Same Customer (last 7 days)

Question (assessment page 2):
"Find the number of customers who received more than one order in the last 7 days."

Assumption:
- “received” date = order_delivery_date (the order is closed and has a final status)
- "last 7 days" is calculated relative to the latest delivery timestamp in the dataset
  (you found MAX(order_delivery_date) = 2026-04-21 05:16:38 UTC)

Window logic:
- Include orders with order_delivery_date in:
  [max_delivery_ts - 7 days, max_delivery_ts]
*/

WITH params AS (
  SELECT MAX(order_delivery_date) AS max_delivery_ts
  FROM `carrybee.orders`
),
last_7_days_orders AS (
  SELECT
    o.customer_id,
    o.order_id,
    o.order_delivery_date
  FROM `carrybee.orders` o
  CROSS JOIN params p
  WHERE o.order_delivery_date >= TIMESTAMP_SUB(p.max_delivery_ts, INTERVAL 7 DAY)
    AND o.order_delivery_date <= p.max_delivery_ts
),
customers_with_order_counts AS (
  SELECT
    customer_id,
    COUNT(*) AS orders_received_last_7_days
  FROM last_7_days_orders
  GROUP BY customer_id
)
SELECT
  COUNT(*) AS customers_received_more_than_one_order_last_7_days
FROM customers_with_order_counts
WHERE orders_received_last_7_days > 1;