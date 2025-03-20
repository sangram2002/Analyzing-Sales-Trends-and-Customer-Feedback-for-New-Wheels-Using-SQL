-- Q1
WITH statewise_customers AS (
	SELECT c.state,
		COUNT(DISTINCT c.customer_id) AS Total_customers
	FROM customer_t c
	JOIN order_t o ON c.customer_id = o.customer_id
	GROUP BY c.state 
)
SELECT *, SUM(Total_customers) OVER () AS Total_customers_with_orders 
FROM statewise_customers 
ORDER BY Total_customers DESC;

-- Q2
SELECT p.vehicle_maker, COUNT(o.customer_id) AS customer_count
FROM product_t p 
JOIN order_t o ON p.product_id = o.product_id 
GROUP BY p.vehicle_maker 
ORDER BY customer_count DESC;

-- Q3
WITH VehicleRank AS (
	SELECT           		
		c.state,          				
		p.vehicle_maker,          		
		COUNT(DISTINCT c.customer_id) AS customer_count,  		
		RANK() OVER (PARTITION BY c.state ORDER BY COUNT(DISTINCT c.customer_id) DESC) AS rnk   	
	FROM customer_t c      	
	JOIN order_t o ON c.customer_id = o.customer_id      	
	JOIN product_t p ON o.product_id = p.product_id      	
	GROUP BY c.state, p.vehicle_maker  
) 
SELECT 
	state, vehicle_maker, customer_count  
	FROM VehicleRank  
	WHERE rnk = 1; 


-- Q4
SELECT      
	CASE          
		WHEN quarter_number IS NULL THEN 'Overall Average'
		ELSE quarter_number      
	END AS quarter_info,      
	AVG(rating) AS avg_rating 
FROM (     
	SELECT          
		quarter_number,          
		CASE              
			WHEN customer_feedback = 'Very Bad' THEN 1
			WHEN customer_feedback = 'Bad' THEN 2             
			WHEN customer_feedback = 'Okay' THEN 3             
			WHEN customer_feedback = 'Good' THEN 4             
			WHEN customer_feedback = 'Very Good' THEN 5             
			ELSE NULL          
		END AS rating     
	FROM order_t 
) AS feedback_scores 
GROUP BY quarter_number with rollup;

-- Q5
SELECT      
	quarter_number,     
COUNT(*) AS Total_Feedback,     
ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Very Bad' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Very_Bad_Perc,     
ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Bad' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Bad_Perc,     
ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Okay' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Okay_Perc,     
ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Good' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Good_Perc,     
ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Very_Good_Perc 
FROM order_t 
GROUP BY quarter_number 
ORDER BY quarter_number;

-- Q6
SELECT      
	quarter_number,      
	COUNT(order_id) AS total_orders 
FROM order_t 
GROUP BY quarter_number 
ORDER BY quarter_number; 

-- Q7

SELECT quarter_number, net_revenue,
  CASE     
	WHEN prev_quarter_revenue IS NULL THEN NULL     
	ELSE ((net_revenue - prev_quarter_revenue) / prev_quarter_revenue) * 100
  END AS qoq_percentage_change 
FROM (     
	SELECT quarter_number,         
SUM(vehicle_price * (1 - discount) * quantity) AS net_revenue,         LAG(SUM(vehicle_price * (1 - discount) * quantity))
  OVER (ORDER BY quarter_number) AS prev_quarter_revenue
    FROM order_t     
	GROUP BY quarter_number 
) AS RevenueWithLag 
ORDER BY quarter_number;

-- Q8
SELECT      
	quarter_number,      
	SUM(vehicle_price * (1 - discount) * quantity) AS net_revenue,
    COUNT(DISTINCT order_id) AS total_orders 
FROM order_t 
GROUP BY quarter_number 
ORDER BY quarter_number;

-- Q9

SELECT      
	c.credit_card_type,      
	AVG(o.discount) AS avg_discount 
FROM customer_t c 
JOIN order_t o ON o.customer_id = c.customer_id 
GROUP BY c.credit_card_type 
ORDER BY avg_discount DESC; 

-- Q10
SELECT 
	quarter_number,         
	AVG(julianday(ship_date, order_date)) AS avg_shipping_time 
FROM order_t 
GROUP BY quarter_number 
ORDER BY quarter_number;

SELECT         
COUNT(*) AS Total_Feedback,     
ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Very Bad' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Very_Bad_Perc,     
ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Bad' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Bad_Perc,     
ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Okay' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Okay_Perc,     
ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Good' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Good_Perc,     
ROUND(100.0 * SUM(CASE WHEN customer_feedback = 'Very Good' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Very_Good_Perc 
FROM order_t;

