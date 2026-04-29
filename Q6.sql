/* 
Q6 — City Change Cases from Order Logs

Question (assessment page 2):
"Identify all order IDs where City Change occurred in the order_logs table and return:
- order_id
- city_change_reason
- final_status
- aging_hours
- sla_breached
Also report how many of these City Change orders were ultimately returned."

How we detect "City Change":
- The order_logs table doesn't have an explicit city_change flag/reason column.
- So we treat a log row as a "City Change" event when:
  description contains the words "city change" (case-insensitive).

City change reason:
- We will use the description text as the reason (since that is the only field that can hold a reason).

Final status:
- From orders.order_status (Delivery/Return/Lost)

Aging + SLA breach:
- Computed from orders.order_pickup_date and orders.order_delivery_date
- SLA rules: same city 24h, outside city 48h
*/

WITH city_change_logs AS (
  SELECT
    order_id,
    description AS city_change_reason
  FROM `carrybee.order_logs`
  WHERE REGEXP_CONTAINS(LOWER(description), r'city\s*change')
),

base_orders AS (
  SELECT
    o.order_id,
    o.order_status AS final_status,
    o.pickup_city,
    o.delivery_city,

    -- total time from pickup to delivery/closure
    TIMESTAMP_DIFF(o.order_delivery_date, o.order_pickup_date, HOUR) AS aging_hours,

    -- SLA hours depending on same city vs outside city
    CASE
      WHEN o.pickup_city = o.delivery_city THEN 24
      ELSE 48
    END AS sla_hours,

    -- SLA breached flag
    CASE
      WHEN TIMESTAMP_DIFF(o.order_delivery_date, o.order_pickup_date, HOUR) >
           CASE WHEN o.pickup_city = o.delivery_city THEN 24 ELSE 48 END
      THEN 1 ELSE 0
    END AS sla_breached
  FROM `carrybee.orders` o
),

final_city_change_cases AS (
  -- If an order has multiple city-change logs, keep one row per order.
  -- We use ANY_VALUE for the reason (you can also pick the latest reason if preferred).
  SELECT
    ccl.order_id,
    ANY_VALUE(ccl.city_change_reason) AS city_change_reason
  FROM city_change_logs ccl
  GROUP BY ccl.order_id
)

-- Output table required by Q6
SELECT
  f.order_id,
  f.city_change_reason,
  bo.final_status,
  bo.aging_hours,
  bo.sla_breached
FROM final_city_change_cases f
JOIN base_orders bo
  ON f.order_id = bo.order_id
ORDER BY f.order_id;