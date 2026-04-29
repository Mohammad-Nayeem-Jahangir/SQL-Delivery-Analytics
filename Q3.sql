/* 
Q3 — Registered City vs. Delivery City Mismatch

Question (assessment page 2):
"How many distinct customers have received at least one order in a delivery city
that differs from the city in their registered address?
The customer address format is: area, zone, city."

Tables/columns (from your schemas):
- customers: id, name, address   (address = "area, zone, city")
- orders: customer_id, delivery_city, ...

Logic:
1) Extract the registered city from customers.address (the 3rd comma-separated part).
2) Join orders to customers on orders.customer_id = customers.id
3) Count DISTINCT customers where delivery_city != registered_city
*/

WITH customers_clean AS (
  SELECT
    id AS customer_id,
    name AS customer_name,
    address,

    -- Split address by commas and take the 3rd part (city).
    -- TRIM removes extra spaces.
    TRIM(SPLIT(address, ',')[SAFE_OFFSET(2)]) AS registered_city
  FROM `carrybee.customers`
),

mismatch_customers AS (
  SELECT DISTINCT
    o.customer_id
  FROM `carrybee.orders` o
  JOIN customers_clean c
    ON o.customer_id = c.customer_id
  WHERE c.registered_city IS NOT NULL
    AND o.delivery_city IS NOT NULL
    AND o.delivery_city != c.registered_city
)

SELECT
  COUNT(*) AS distinct_customers_with_registered_city_vs_delivery_city_mismatch
FROM mismatch_customers;