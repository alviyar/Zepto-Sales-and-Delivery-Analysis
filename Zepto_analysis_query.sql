select * from zepto

-- 1) Which product category contributes the highest revenue?
select "Product_Category", round(sum("Order_Value")::numeric, 2) as total_revenue from Zepto
group by "Product_Category"
order by total_revenue desc
limit 1

-- 2) What is the revenue contribution (%) of each product category?
SELECT 
    "Product_Category", 
    ROUND(SUM("Order_Value")::numeric, 2) AS category_revenue,
    ROUND(
        (SUM("Order_Value") * 100.0 / SUM(SUM("Order_Value")) OVER())::numeric, 
        2
    ) AS percentage_contribution
FROM zepto
GROUP BY "Product_Category"
ORDER BY percentage_contribution DESC;

-- 3) Which city has the highest average items per order?
select "City",ROUND(AVG("Items_Count")::numeric, 2) AS avg_items_per_order
from zepto
group by "City"
order by avg_items_per_order desc;
-- 4) Compare average rating for fast (<10 min), medium (10–15 min), and slow (>15 min) deliveries.
SELECT 
    CASE 
        WHEN "Delivery_Time_Min" < 10 THEN 'Fast'
        WHEN "Delivery_Time_Min" BETWEEN 10 AND 15 THEN 'Medium'
        ELSE 'Slow'
    END AS delivery_speed,
    
    ROUND(AVG("Customer_Rating")::numeric, 2) AS avg_rating

FROM zepto
GROUP BY delivery_speed
ORDER BY avg_rating DESC;
--Does distance range (0–5 km, 5–10 km, >10 km) affect customer rating?
SELECT 
    CASE 
        WHEN "Distance_Km" < 5 THEN 'Near'
        WHEN "Distance_Km" BETWEEN 5 AND 10 THEN 'Medium'
        ELSE 'Far'
    END AS delivery_distance,
    
    ROUND(AVG("Customer_Rating")::numeric, 2) AS avg_rating

FROM zepto
GROUP BY delivery_distance
ORDER BY avg_rating DESC;
--5)Which payment method is most used?
select "Payment_Method",count(*) as total_orders
from zepto
group by "Payment_Method"
order by total_orders desc
limit 3

-- 6)Does payment method influence average order value?
select "Payment_Method",ROUND(AVG("Order_Value")::numeric, 2) AS avg_order_value
from zepto
group by "Payment_Method"
order by avg_order_value desc 

-- 7)Which age group (18–25, 26–35, 36–45, 46+) generates highest revenue?
SELECT 
    CASE 
        WHEN "Customer_Age" BETWEEN 18 AND 25 THEN 'Young Adult'
		WHEN "Customer_Age" BETWEEN 26 AND 35 THEN 'Adult'
		WHEN "Customer_Age" BETWEEN 36 AND 45 THEN 'Mid-Age'
        ELSE 'Senior Citizen'
    END AS Age_group,
    
    ROUND(sum("Order_Value")::numeric, 2) AS revenue

FROM zepto
GROUP BY Age_group
ORDER BY revenue DESC;

-- 9)Identify cities where delivery partner rating is below overall average.
SELECT 
    "City",
    ROUND(AVG("Delivery_Partner_Rating")::numeric, 2) AS city_avg_partner_rating,
    ROUND((SELECT AVG("Delivery_Partner_Rating") FROM zepto)::numeric, 2) 
    AS overall_avg_partner_rating
FROM zepto
GROUP BY "City"
HAVING AVG("Delivery_Partner_Rating") < 
       (SELECT AVG("Delivery_Partner_Rating") FROM zepto)
ORDER BY city_avg_partner_rating;

-- 10) What percentage of total revenue comes from discounted orders?
SELECT 
    ROUND(
        (
            SUM(CASE WHEN "Discount_Applied" = 1 THEN "Order_Value" ELSE 0 END)
            /
            SUM("Order_Value")
        )::numeric * 100
    , 2) AS discount_revenue_percentage
FROM zepto;
-- 11)Top 5 cities by order volume (not revenue).
select "City",ROUND(Sum("Items_Count")::numeric, 2) AS order_volume
from zepto
group by "City"
order by order_volume desc
limit 5
-- 12) Is there a relationship between items count and order value? (group into item ranges).
SELECT 
    CASE 
        WHEN "Items_Count" BETWEEN 1 AND 5 THEN '1-5 Items'
        WHEN "Items_Count" BETWEEN 6 AND 10 THEN '6-10 Items'
        WHEN "Items_Count" BETWEEN 11 AND 15 THEN '11-15 Items'
        ELSE '16+ Items'
    END AS item_range,
    
    ROUND(AVG("Order_Value")::numeric, 2) AS avg_order_value

FROM zepto
GROUP BY item_range
ORDER BY avg_order_value DESC;