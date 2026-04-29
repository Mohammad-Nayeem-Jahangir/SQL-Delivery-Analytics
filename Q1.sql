/* 
Q1 Supporting Table — Daily performance

This helps you validate:
- daily return ratio
- daily SLA breached orders
*/

WITH base AS (
  SELECT
    order_id,
    order_status,
    pickup_city,
    delivery_city,
    order_pickup_date,
    order_delivery_date,

    TIMESTAMP_DIFF(order_delivery_date, order_pickup_date, HOUR) AS aging_hours,

    CASE
      WHEN pickup_city = delivery_city THEN 24
      ELSE 48
    END AS sla_hours,

    CASE
      WHEN TIMESTAMP_DIFF(order_delivery_date, order_pickup_date, HOUR) >
           CASE WHEN pickup_city = delivery_city THEN 24 ELSE 48 END
      THEN 1 ELSE 0
    END AS sla_breached
  FROM `carrybee.orders`
)

SELECT
  DATE(order_delivery_date) AS delivery_day,
  COUNT(*) AS total_orders,
  SUM(CASE WHEN order_status = 'Delivery' THEN 1 ELSE 0 END) AS delivered_orders,
  SUM(CASE WHEN order_status = 'Return' THEN 1 ELSE 0 END) AS returned_orders,
  SUM(CASE WHEN order_status = 'Lost' THEN 1 ELSE 0 END) AS lost_orders,
  SAFE_DIVIDE(SUM(CASE WHEN order_status = 'Return' THEN 1 ELSE 0 END), COUNT(*)) AS return_ratio,
  SUM(sla_breached) AS sla_breached_orders,
  SAFE_DIVIDE(SUM(sla_breached), COUNT(*)) AS sla_breached_rate
FROM base
GROUP BY delivery_day
ORDER BY delivery_day;

