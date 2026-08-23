use food_delivery_analysis;

-- ============================================
-- FOOD DELIVERY BUSINESS ANALYSIS
-- ============================================

-- 1. Total number of orders--(combined)
SELECT COUNT(*) AS total_orders,
	COUNT(DISTINCT Order_ID) AS unique_orders,
	SUM(Total) AS total_revenue,
	AVG(Total) AS average_order_value,
	AVG(Item_Count) AS average_items_per_order,
	AVG(DistanceKM) AS average_delivery_distance_km
FROM food_delivery_orders;

-- 2. Unique orders
SELECT COUNT(DISTINCT Order_ID) AS unique_orders
FROM food_delivery_orders;

-- 3. Order status distribution
SELECT OrderDate
FROM food_delivery_orders
WHERE OrderDate IS NOT NULL
LIMIT 10;
SELECT
    OrderDate,
    STR_TO_DATE(OrderDate, '%M %d %Y') AS converted_date
FROM food_delivery_orders
LIMIT 10;
-- 4. Order date range
SELECT
    MIN(CAST(OrderDate AS DATETIME)) AS first_order_date,
    MAX(CAST(OrderDate AS DATETIME)) AS last_order_date
FROM food_delivery_orders;

-- 5. Total revenue
SELECT
    SUM(Total) AS total_revenue
FROM food_delivery_orders;

-- 6. Average order value
SELECT
    AVG(Total) AS average_order_value
FROM food_delivery_orders;

-- 7. Average items per order
SELECT
    AVG(Item_Count) AS average_items_per_order
FROM food_delivery_orders;

-- 8. Average delivery distance
SELECT
    AVG(DistanceKM) AS average_delivery_distance_km
FROM food_delivery_orders;

-- ============================================
-- RESTAURANT PERFORMANCE ANALYSIS
-- ============================================

-- 9. Top restaurants by number of orders
SELECT
    Restaurant_name,
    COUNT(*) AS order_count
FROM food_delivery_orders
GROUP BY Restaurant_name
ORDER BY order_count DESC
LIMIT 10;

-- 10. Top restaurants by revenue
SELECT
    Restaurant_name,
    SUM(Total) AS total_revenue
FROM food_delivery_orders
GROUP BY Restaurant_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 11. Average order value by restaurant
SELECT
    Restaurant_name,
    COUNT(*) AS order_count,
    SUM(Total) AS total_revenue,
    AVG(Rating) AS average_rating
FROM food_delivery_orders
GROUP BY Restaurant_name
ORDER BY average_order_value DESC;

-- 12. Average rating by restaurant
SELECT
    Restaurant_name,
    COUNT(Rating) AS rated_orders,
    AVG(Rating) AS average_rating
FROM food_delivery_orders
GROUP BY Restaurant_name
ORDER BY average_rating DESC;

-- 13. Restaurant performance summary--(combined)
SELECT
    Restaurant_name,
    COUNT(*) AS order_count,
    ROUND(SUM(Total),2) AS total_revenue,
    ROUND(AVG(Total),2) AS average_order_value,
    COUNT(Rating) AS rated_orders,
    ROUND(AVG(Rating),2) AS average_rating,
    CASE
        WHEN AVG(Total) > (SELECT AVG(Total) FROM food_delivery_orders) THEN 'Yes'
        ELSE 'No'
    END AS above_avg_aov,
	RANK() OVER (
    ORDER BY SUM(Total) DESC) AS revenue_rank,
	ROUND(SUM(Total) * 100.0 / SUM(SUM(Total)) OVER (),2) AS revenue_percentage,
    SUM(CASE
		WHEN Order_Status = 'Delivered' THEN 1
        ELSE 0
	END) AS delivered_orders,
    ROUND(SUM(CASE
				WHEN Order_Status = 'Delivered' THEN 1
                ELSE 0
			  END)* 100.0 / COUNT(*),2) AS delivery_rate
FROM food_delivery_orders
GROUP BY Restaurant_name
ORDER BY total_revenue DESC;

-- 14. Total discounts by type(combined)
SELECT
	CASE
        WHEN Restaurant_discount_Promo > 0 THEN 'Promo Discount'
        ELSE 'No Promo Discount'
    END AS promo_status,
	COUNT(*) AS order_count,
    ROUND(SUM(Restaurant_discount_Promo),2) AS promo_discount,
    ROUND(SUM(Restaurant_discount_Flat),2) AS flat_discount,
    ROUND(SUM(Gold_discount),2) AS gold_discount,
    ROUND(SUM(Brand_pack_discount),2) AS brand_pack_discount,
    ROUND(AVG(Total),2) AS average_order_value,
    ROUND(AVG(Item_Count),2) AS average_items_per_order
FROM food_delivery_orders
GROUP BY promo_status;

-- 15. Orders receiving each discount type
SELECT
    SUM(CASE WHEN Restaurant_discount_Promo > 0 THEN 1 ELSE 0 END) AS promo_orders,
    SUM(CASE WHEN Restaurant_discount_Flat > 0 THEN 1 ELSE 0 END) AS flat_discount_orders,
    SUM(CASE WHEN Gold_discount > 0 THEN 1 ELSE 0 END) AS gold_discount_orders,
    SUM(CASE WHEN Brand_pack_discount > 0 THEN 1 ELSE 0 END) AS brand_pack_discount_orders
FROM food_delivery_orders;

-- 16. Average discount per discounted order
SELECT
    SUM(Restaurant_discount_Promo) / NULLIF(SUM(CASE WHEN Restaurant_discount_Promo > 0 THEN 1 ELSE 0 END), 0) AS avg_promo_discount,
    SUM(Restaurant_discount_Flat) / NULLIF(SUM(CASE WHEN Restaurant_discount_Flat > 0 THEN 1 ELSE 0 END), 0) AS avg_flat_discount,
    SUM(Gold_discount) / NULLIF(SUM(CASE WHEN Gold_discount > 0 THEN 1 ELSE 0 END), 0) AS avg_gold_discount,
    SUM(Brand_pack_discount) / NULLIF(SUM(CASE WHEN Brand_pack_discount > 0 THEN 1 ELSE 0 END), 0) AS avg_brand_pack_discount
FROM food_delivery_orders;

-- 17. Promo discount vs average order value
SELECT
    CASE
        WHEN Restaurant_discount_Promo > 0 THEN 'Promo Discount'
        ELSE 'No Promo Discount'
    END AS promo_status,
    COUNT(*) AS order_count,
    AVG(Total) AS average_order_value,
    AVG(Item_Count) AS average_items_per_order
FROM food_delivery_orders
GROUP BY promo_status;

-- 18. Revenue comparison: promo vs non-promo
SELECT
    CASE
        WHEN Restaurant_discount_Promo > 0 THEN 'Promo Discount'
        ELSE 'No Promo Discount'
    END AS promo_status,
    COUNT(*) AS order_count,
    SUM(Total) AS total_revenue,
    AVG(Total) AS average_order_value
FROM food_delivery_orders
GROUP BY promo_status;

-- ============================================
-- DELIVERY PERFORMANCE ANALYSIS
-- ============================================

-- 19. Average operational waiting times
SELECT
    AVG(`KPT_duration_minutes`) AS average_kpt_minutes,
    AVG(`Rider_wait_time_minutes`) AS average_rider_wait_minutes
FROM food_delivery_orders;

-- 20. Average KPT by order status
SELECT
	    CASE
        WHEN DistanceKM <= 3 THEN '0-3 km'
        WHEN DistanceKM <= 5 THEN '3-5 km'
        WHEN DistanceKM <= 8 THEN '5-8 km'
        ELSE '8+ km'
    END AS distance_range,
    Order_Status,
    COUNT(*) AS order_count,
    AVG(Total) AS average_order_value,
    AVG(KPT_duration_minutes) AS average_kpt_minutes,
    AVG(`Rider_wait_time_minutes`) AS average_rider_wait_minutes
FROM food_delivery_orders
WHERE KPT_duration_minutes IS NOT NULL AND Rider_wait_time_minutes IS NOT NULL
GROUP BY distance_range,order_status
ORDER BY CASE distance_range
        WHEN '0-3 km' THEN 1
        WHEN '3-5 km' THEN 2
        WHEN '5-8 km' THEN 3
        ELSE 4
    END;

-- 21. Average rider wait time by order status
SELECT
    Order_Status,
    COUNT(*) AS order_count,
    AVG(Rider_wait_time_minutes) AS average_rider_wait_minutes
FROM food_delivery_orders
WHERE Rider_wait_time_minutes IS NOT NULL
GROUP BY Order_Status
ORDER BY average_rider_wait_minutes DESC;

-- 22. Order value by delivery-distance range
SELECT
    CASE
        WHEN DistanceKM <= 3 THEN '0-3 km'
        WHEN DistanceKM <= 5 THEN '3-5 km'
        WHEN DistanceKM <= 8 THEN '5-8 km'
        ELSE '8+ km'
    END AS distance_range,
    COUNT(*) AS order_count,
    AVG(Total) AS average_order_value
FROM food_delivery_orders
GROUP BY distance_range
ORDER BY CASE distance_range
        WHEN '0-3 km' THEN 1
        WHEN '3-5 km' THEN 2
        WHEN '5-8 km' THEN 3
        ELSE 4
    END;

-- 23. Delivery distance vs operational performance
SELECT
    CASE
        WHEN DistanceKM <= 3 THEN '0-3 km'
        WHEN DistanceKM <= 5 THEN '3-5 km'
        WHEN DistanceKM <= 8 THEN '5-8 km'
        ELSE '8+ km'
    END AS distance_range,
    COUNT(*) AS order_count,
    AVG(KPT_duration_minutes) AS average_kpt_minutes,
    AVG(Rider_wait_time_minutes) AS average_rider_wait_minutes
FROM food_delivery_orders
GROUP BY distance_range
ORDER BY
    CASE distance_range
        WHEN '0-3 km' THEN 1
        WHEN '3-5 km' THEN 2
        WHEN '5-8 km' THEN 3
        ELSE 4
    END;

 -- ============================================
-- REJECTION, RETURN & ORDER PROBLEM ANALYSIS
-- ============================================   
-- 24. Actual cancellation/rejection reasons
SELECT
    Cancellation_Rejection_reason,
    COUNT(*) AS order_count
FROM food_delivery_orders
WHERE Cancellation_Rejection_reason IS NOT NULL
  AND TRIM(Cancellation_Rejection_reason) <> ''
  AND Cancellation_Rejection_reason <> 'Not Applicable'
GROUP BY Cancellation_Rejection_reason
ORDER BY order_count DESC;

-- 25. Order status by cancellation/rejection reason
SELECT
    Order_Status,
    Cancellation_Rejection_reason,
    COUNT(*) AS order_count
FROM food_delivery_orders
WHERE Cancellation_Rejection_reason <> 'Not Applicable'
  AND Cancellation_Rejection_reason IS NOT NULL
GROUP BY Order_Status, Cancellation_Rejection_reason
ORDER BY order_count DESC;

-- 26. Customer complaint analysis
SELECT
    Customer_complaint_tag,
    COUNT(*) AS complaint_count
FROM food_delivery_orders
WHERE Customer_complaint_tag IS NOT NULL
  AND TRIM(Customer_complaint_tag) <> ''
  AND Customer_complaint_tag <> 'No Complaint'
GROUP BY Customer_complaint_tag
ORDER BY complaint_count DESC;

-- 27. Customer complaints by restaurant
SELECT
    Restaurant_name,
    COUNT(*) AS complaint_count
FROM food_delivery_orders
WHERE Customer_complaint_tag IS NOT NULL
  AND TRIM(Customer_complaint_tag) <> ''
  AND Customer_complaint_tag <> 'No Complaint'
GROUP BY Restaurant_name
ORDER BY complaint_count DESC;

-- 28. Customer complaint rate by restaurant
SELECT
    Restaurant_name,
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN Customer_complaint_tag IS NOT NULL
             AND TRIM(Customer_complaint_tag) <> ''
             AND Customer_complaint_tag <> 'No Complaint'
            THEN 1
            ELSE 0
        END
    ) AS complaint_count,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN Customer_complaint_tag IS NOT NULL
                 AND TRIM(Customer_complaint_tag) <> ''
                 AND Customer_complaint_tag <> 'No Complaint'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS complaint_rate_percent
FROM food_delivery_orders
GROUP BY Restaurant_name
ORDER BY complaint_rate_percent DESC;

-- ============================================
-- TIME-BASED ANALYSIS
-- ============================================
-- 29. Orders by month
SELECT
    DATE_FORMAT(CAST(OrderDate AS DATETIME), '%Y-%m') AS order_month,
    COUNT(*) AS order_count
FROM food_delivery_orders
GROUP BY order_month
ORDER BY order_month;

-- 30. Orders by day of week
SELECT
    day_of_week,
    order_count
FROM (
    SELECT
        DAYNAME(CAST(OrderDate AS DATETIME)) AS day_of_week,
        COUNT(*) AS order_count,
        MIN(WEEKDAY(CAST(OrderDate AS DATETIME))) AS day_order
    FROM food_delivery_orders
    GROUP BY DAYNAME(CAST(OrderDate AS DATETIME))
) AS daily
ORDER BY day_order;

-- 31. Orders by hour
SELECT
    HOUR(CAST(OrderTime AS DATETIME)) AS order_hour,
    COUNT(*) AS order_count
FROM food_delivery_orders
WHERE OrderTime IS NOT NULL
GROUP BY order_hour
ORDER BY order_hour;

-- 32. Monthly revenue trend
SELECT
    DATE_FORMAT(CAST(OrderDate AS DATETIME), '%Y-%m') AS order_month,
    COUNT(*) AS order_count,
    SUM(Total) AS total_revenue,
    AVG(Total) AS average_order_value
FROM food_delivery_orders
GROUP BY order_month
ORDER BY order_month;

-- ============================================
-- ADVANCED SQL ANALYSIS
-- ============================================

-- 33. Restaurants with above-average order value
WITH restaurant_metrics AS (
    SELECT
        Restaurant_name,
        COUNT(*) AS order_count,
        AVG(Total) AS average_order_value
    FROM food_delivery_orders
    GROUP BY Restaurant_name
)
SELECT
    Restaurant_name,
    order_count,
    ROUND(average_order_value, 2) AS average_order_value
FROM restaurant_metrics
WHERE average_order_value >(
    SELECT AVG(Total)
    FROM food_delivery_orders)
ORDER BY average_order_value DESC;

-- 34. Rank restaurants by total revenue
SELECT
    Restaurant_name,
    SUM(Total) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(Total) DESC
    ) AS revenue_rank
FROM food_delivery_orders
GROUP BY Restaurant_name
ORDER BY revenue_rank;

-- 35. Restaurant contribution to total revenue
SELECT
    Restaurant_name,
    ROUND(SUM(Total), 2) AS total_revenue,
    ROUND(
        SUM(Total) * 100.0 / SUM(SUM(Total)) OVER (),
        2
    ) AS revenue_percentage
FROM food_delivery_orders
GROUP BY Restaurant_name
ORDER BY revenue_percentage DESC;

-- 36. Compare restaurant order volume and revenue
SELECT
    Restaurant_name,
    COUNT(*) AS order_count,
    ROUND(SUM(Total), 2) AS total_revenue,
    ROUND(AVG(Total), 2) AS average_order_value
FROM food_delivery_orders
GROUP BY Restaurant_name
ORDER BY total_revenue DESC;

-- 37. Rank restaurants by average order value
SELECT
    Restaurant_name,
    COUNT(*) AS order_count,
    ROUND(AVG(Total), 2) AS average_order_value,
    RANK() OVER (
        ORDER BY AVG(Total) DESC
    ) AS aov_rank
FROM food_delivery_orders
GROUP BY Restaurant_name
ORDER BY aov_rank;

-- 38. Restaurant-wise order status performance
SELECT
    Restaurant_name,
    Order_Status,
    COUNT(*) AS order_count
FROM food_delivery_orders
GROUP BY
    Restaurant_name,
    Order_Status
ORDER BY
    Restaurant_name,
    order_count DESC;
    
-- 39. Monthly restaurant performance
SELECT
    DATE_FORMAT(OrderDate, '%Y-%m') AS order_month,
    Restaurant_name,
    COUNT(*) AS order_count,
    ROUND(SUM(Total), 2) AS total_revenue,
    ROUND(AVG(Total), 2) AS average_order_value
FROM food_delivery_orders
GROUP BY
    DATE_FORMAT(OrderDate, '%Y-%m'),
    Restaurant_name
ORDER BY
    order_month,
    total_revenue DESC;

-- 40. Final restaurant performance summary
SELECT
    Restaurant_name,

    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN Order_Status = 'Delivered' THEN 1
            ELSE 0
        END
    ) AS delivered_orders,

    ROUND(SUM(Total), 2) AS total_revenue,

    ROUND(AVG(Total), 2) AS average_order_value,

    ROUND(
        SUM(Total) * 100.0 /
        SUM(SUM(Total)) OVER (),
        2
    ) AS revenue_percentage,
    
    ROUND(
        SUM(
            CASE
                WHEN Order_Status = 'Delivered' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS delivery_rate
FROM food_delivery_orders
GROUP BY Restaurant_name
ORDER BY total_revenue DESC;