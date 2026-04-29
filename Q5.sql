/* 
Q5 — Delivery Man with Tenure > 30 Days and Return Ratio > 20%

Question (assessment page 2):
"Find the delivery men whose joining tenure is more than 30 days and whose
return ratio is above 20%.
- Tenure should be calculated relative to the maximum order_delivery_date in the dataset.
- Output: delivery_man_id, delivery_man_name, working_area, tenure_days,
          total_orders, returned_orders, return_ratio."

Assumptions:
- Returned orders are those with order_status = 'Return'
- Tenure reference date = MAX(orders.order_delivery_date)
- Return ratio = returned_orders / total_orders (all statuses included)
*/

WITH params AS (
  -- Reference point for tenure calculation
  SELECT MAX(order_delivery_date) AS max_delivery_ts
  FROM `carrybee.orders`
),

dm_order_stats AS (
  -- Total orders and returned orders per delivery man
  SELECT
    o.delivery_man_id,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.order_status = 'Return' THEN 1 ELSE 0 END) AS returned_orders
  FROM `carrybee.orders` o
  GROUP BY o.delivery_man_id
),

dm_tenure AS (
  SELECT
    dm.id AS delivery_man_id,
    dm.name AS delivery_man_name,
    dm.working_area,
    dm.joining_date,

    -- Tenure in days relative to the max delivery timestamp in the orders table
    DATE_DIFF(DATE(p.max_delivery_ts), DATE(dm.joining_date), DAY) AS tenure_days
  FROM `carrybee.delivery_men` dm
  CROSS JOIN params p
)

SELECT
  t.delivery_man_id,
  t.delivery_man_name,
  t.working_area,
  t.tenure_days,
  s.total_orders,
  s.returned_orders,

  -- Return ratio: returned / total
  SAFE_DIVIDE(s.returned_orders, s.total_orders) AS return_ratio

FROM dm_tenure t
JOIN dm_order_stats s
  ON t.delivery_man_id = s.delivery_man_id

WHERE t.tenure_days > 30
  AND SAFE_DIVIDE(s.returned_orders, s.total_orders) > 0.20

ORDER BY return_ratio DESC, tenure_days DESC;