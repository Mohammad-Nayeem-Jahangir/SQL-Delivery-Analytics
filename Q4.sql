/* 
Q4 — Top 3 Delivery Man per Delivery City (by delivered order count)

Question (assessment page 2):
"Find the top 3 performing delivery man in each delivery_city, along with their
total delivered order count."

Assumptions based on your status values:
- Delivered orders are those with order_status = 'Delivery'

Tables/columns:
- orders: delivery_city, delivery_man_id, order_status
- delivery_men: id, name, working_area, joining_date

Approach:
1) Count delivered orders per (delivery_city, delivery_man_id)
2) Rank delivery men within each city by delivered_orders (descending)
3) Keep rank <= 3
*/

WITH delivered_counts AS (
  SELECT
    o.delivery_city,
    o.delivery_man_id,
    COUNT(*) AS delivered_orders
  FROM `carrybee.orders` o
  WHERE o.order_status = 'Delivery'
  GROUP BY o.delivery_city, o.delivery_man_id
),

ranked AS (
  SELECT
    dc.*,
    DENSE_RANK() OVER (
      PARTITION BY dc.delivery_city
      ORDER BY dc.delivered_orders DESC
    ) AS city_rank
  FROM delivered_counts dc
)

SELECT
  r.delivery_city,
  r.delivery_man_id,
  dm.name AS delivery_man_name,
  dm.working_area,
  r.delivered_orders AS total_delivered_order_count,
  r.city_rank
FROM ranked r
JOIN `carrybee.delivery_men` dm
  ON r.delivery_man_id = dm.id
WHERE r.city_rank <= 3
ORDER BY r.delivery_city, r.city_rank, r.delivered_orders DESC;