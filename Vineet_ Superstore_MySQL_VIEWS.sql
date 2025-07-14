
## ----------------------------------------------------CREATE VIEWS ------------------------------------------------------------------------------

# 1. vw_product_Seasonality_Trends

CREATE VIEW 	product_seasonality_trends AS
SELECT 			product_name, Years, Quarters, sum(quantity), sum(Sales_Price * Quantity) AS Total_Sales
FROM 			Sales s INNER JOIN date_dim d ON
				s.order_date = d.order_date
INNER JOIN 		products p ON
				s.Product_ID = p.Product_ID
GROUP BY 		Years, Quarters, Product_name
ORDER by 		Years, Quarters, Product_name;

SELECT 			*
FROM 			product_seasonality_trends;

# 2. vw_discount_impact_analysis: Correlation between discounts and profits 

CREATE VIEW 	discount_profit_analysis AS
SELECT 			Discount, sum((Sales_Price * Quantity) - ( Cost_Price * Quantity)) AS Total_Profit
FROM 			Sales
GROUP BY 		discount;

SELECT 			*
FROM 			discount_profit_analysis;

# 3. vw_customer_order_patterns: Average order value, frequency, and profit per customer segment 

CREATE VIEW 	customer_order_patterns AS
SELECT 			Customer_ID,avg(Sales_Price * Quantity) As Avg_Order_Val,
				Count(order_ID) AS Frequency,
				SUM((Sales_Price * Quantity) - ( Cost_Price * Quantity)) AS Profit
FROM 			Sales
GROUP BY 		Customer_ID
ORDER BY 		Frequency DESC;

SELECT 			*
FROM 			customer_order_patterns;

# 4. vw_channel_margin_report: Profitability comparison across online vs in-store 

CREATE VIEW 	channel_margin_report AS
SELECT 			SUM((Sales_Price * Quantity) - (Cost_Price * Quantity)) AS Profit,
				order_mode
FROM 			Sales s Inner JOIN Orders o ON
				s.order_ID = o.Order_ID
Group BY 		order_mode;

SELECT 			*
FROM 			channel_margin_report;

# 5. vw_region_category_rankings: Rank categories by profit margin per region 

CREATE VIEW 	region_category_rankings AS
WITH rankings AS 
(
SELECT 			category, region, SUM((Sales_Price * Quantity) - (Cost_Price * Quantity)) AS Profit 
FROM 			sales s Inner JOIN products p ON
				s.Product_ID = p.Product_ID
INNER JOIN 		store_locations sl ON 
				s.Postal_Code = sl.postal_Code
GROUP BY 		region, category
)

SELECT 			region, category, profit,  
				dense_rank() OVER (PARTITION BY region ORDER BY Profit DESC)
FROM 			rankings;

SELECT 			*
FROM 			region_category_rankings;


# 6. vw_Avg_order_val_channel_segment

CREATE VIEW 	Avg_order_val_channel_segment AS
WITH order_totals AS 
(
SELECT 			o.order_ID,	o.order_mode, p.segment,
				SUM(s.quantity * s.sales_price) AS order_value
FROM 			Sales s
INNER JOIN 		Orders o ON s.order_ID = o.order_ID
INNER JOIN 		Products p ON s.product_ID = p.Product_ID
GROUP BY 		o.order_ID, o.order_mode, p.segment
)

SELECT 			order_mode, segment,
				AVG(order_value) AS avg_order_value
FROM 			order_totals
GROUP BY 		order_mode, segment;
    
    SELECT 		*
    FROM 		Avg_order_val_channel_segment;
    
## ----------------------------------5 Reusable SQL Queries using JOIN for Business insights -----------------------------------------------------------------------------

   # 1. Monthly Sales & Profit Trend by Region

SELECT 			d.years, d.months, sl.region,
				SUM(s.sales_price * s.quantity) AS total_sales,
				SUM((s.sales_price - s.cost_price) * s.quantity) AS total_profit
FROM 			sales s
INNER JOIN 		store_locations sl ON s.Postal_Code = sl.Postal_Code
INNER JOIN 		date_dim d ON s.order_date = d.order_date
GROUP BY 		d.years, d.months, sl.region
ORDER BY 		d.years, d.months, total_sales DESC;
    
  # 2. Regional Profit Margin Comparison
  
SELECT 			sl.region,
				SUM((s.sales_price - s.cost_price) * s.quantity) AS total_profit,
				SUM(s.sales_price * s.quantity) AS total_sales,
				ROUND(SUM((s.sales_price - s.cost_price) * s.quantity) / SUM(s.sales_price * s.quantity), 2) AS profit_margin
FROM 			sales s
INNER JOIN 		store_locations sl ON s.postal_code = sl.postal_code
GROUP BY 		sl.region;
  
  # 3. Sales Contribution by Segment and Category
 
CREATE VIEW 	sales_segment_category AS
SELECT 			p.segment, p.category,
				SUM(s.sales_price * s.quantity) AS segment_category_sales,
				ROUND(100 * SUM(s.sales_price * s.quantity) / 
				(SELECT SUM(sales_price * quantity) FROM sales), 2) AS sales_contribution_percent
FROM 			sales s
INNER JOIN 		products p ON s.product_id = p.product_id
GROUP BY 		p.segment, p.category
ORDER BY 		sales_contribution_percent DESC;
 
 SELECT 		*
 FROM			sales_segment_category;
 
# 4. Underperforming Products (Low Sales & Low Profit)

SELECT 			p.product_name,	p.category,
				SUM(s.sales_price * s.quantity) AS total_sales,
				SUM((s.sales_price - s.cost_price) * s.quantity) AS total_profit
FROM 			sales s
INNER JOIN 		products p ON s.product_id = p.product_id
GROUP BY 		p.product_name, p.category
HAVING 			total_sales < 1000 AND total_profit < 500
ORDER BY 		total_profit ASC;
    
# 5. Customer Lifetime Value (CLV) by Subcategory

SELECT 			p.Subcategory, s.customer_id,
				SUM(s.sales_price * s.quantity) AS total_revenue,
				SUM((s.sales_price - s.cost_price) * s.quantity) AS total_profit,
				COUNT(DISTINCT s.order_id) AS total_orders
FROM 			sales s
INNER JOIN 		products p ON s.product_id = p.product_id
GROUP BY 		p.Subcategory, s.customer_id
ORDER BY		total_profit DESC;
