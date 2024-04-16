-- performig EDA
-- Column type
   #Numerical= base_price,quantity_sold(before_promo),quantity_sold(after_promo)[this is continious data]
   #categorical=start_date,end_date,campaign_id,campaign_name,product_code,product_name,category,store_id,city,event_id,promo_type[this is ordinal data]

-- preview of data
/* First 5 products */
select * from fact_events
order by event_id LIMIT 5;
/* Random 5 products */
select * from fact_events
ORDER BY RAND() LIMIT 5;
 
  
-- Univariate Analysis of numerical data 
/*On column name = base_price 
  basic deatils about this column */ 
select count(base_price), min(base_price),max(base_price), avg(base_price),std(base_price) from fact_events;
     /* Since the standard deviation is larger than the average, we can conclude that the data points are spread 
     out over a wider range of values than  around the average. In other words,
     The base prices tend to deviate more from the average price than they cluster around it.*/
     
#calculating skewness of base_price
SELECT
    (1 / COUNT(base_price)) * SUM((base_price - mean_val) * (base_price - mean_val) * (base_price - mean_val)) / POWER(STDDEV(base_price), 3) AS skewness
FROM
    fact_events
CROSS JOIN
    (SELECT AVG(base_price) AS mean_val FROM fact_events) AS mean_values;
    /*CONCLUSION
    data is positively skewed
    it means that there are many small values and few extremely large values */
    
#calculating outliers
    
select (count(*)+1)*0.25  from fact_events;
   # OUTPUT IS 375.25
select * from ( select row_number() over(order by base_price ) as index_, base_price from fact_events)  a where index_= 375 ; 
select * from ( select row_number() over(order by base_price ) as index_, base_price from fact_events)  a where index_= 376;

SELECT (1-0.25)*110 + 0.25*110 AS Q1 FROM fact_events;
    #q1=110
select (count(*)+1)*0.75  from fact_events;
    #OUTPUT IS 1125.75
select * from ( select row_number() over(order by base_price ) as index_, base_price from fact_events)  a where index_= 1125 ; 
select * from ( select row_number() over(order by base_price ) as index_, base_price from fact_events)  a where index_=1126;
SELECT (1-0.75)*860+0.75*860 AS Q3 FROM fact_events;
    #Q3=860
SELECT * FROM fact_events WHERE base_price < 110 -(1.5*(860-110)) OR base_price > 860+(1.5*(860-110));
     /*CONCLUSION
     The value 30000 in the base_price column was identified as an outlier in the analysis. 
     Further examination revealed that a base price of 30000 is plausible within the context of the product
     category */
     
-- Univariate Analysis of Categorical data 

     #frequency distribution of columns =campaign_id,product_code
select campaign_id,product_code,count(*) from fact_events
group by campaign_id,product_code;
     /*In each campaign no of products are equally sold */
 
 -- Bivariate analysis 
 
      #Correlation between 'Base Price' and 'Quantity Sold'
SELECT 
    (COUNT(*) * SUM(base_price * `quantity_sold(after_promo)`) - SUM(base_price) * SUM(`quantity_sold(after_promo)`)) /
    (SQRT((COUNT(*) * SUM(base_price * base_price) - SUM(base_price) * SUM(base_price)) *
          (COUNT(*) * SUM(`quantity_sold(after_promo)` * `quantity_sold(after_promo)`) - SUM(`quantity_sold(after_promo)`) * SUM(`quantity_sold(after_promo)`)))) AS correlation
FROM fact_events;
   /*CONCLUSION 
    In this case, the coefficient of 0.266 suggests a positive correlation between base_price and quantity_sold_after_promo,
   but it's relatively weak.Therefore, we can conclude that there is a slight tendency for 
   higher base prices to correspond with higher quantities sold after the promotion.
   However, other factors may also influence the quantity sold, as the correlation is not particularly strong */
   
-- Comparison of Revenue Before and After Promotion

SELECT AVG(`revenue before promotion`) AS avg_revenue_before,
       AVG(`revenue after promotion`) AS avg_revenue_after
FROM fact_events ;
  /*CONCLUSION
   The comparison of revenue before and after promotions reveals a notable increase in average
    revenue, nearly doubling post-promotion */
  
-- Effect of Promo Type on Revenue

SELECT promo_type,
       AVG(`revenue before promotion`) AS avg_revenue_before,
       AVG(`revenue after promotion`) AS avg_revenue_after
FROM fact_events
GROUP BY promo_type;
  /*CONCLUSION
   The analysis shows that different promotion types have different effects on revenue.
   While promotions like "BOGOF" and "500 Cashback" greatly increase revenue after the 
   promotion, others like "25% OFF" and "50% OFF" show smaller increases */ 
  
-- Comparison of Quantity Sold Before and After Promotion

SELECT AVG(`quantity_sold(before_promo)`) AS avg_quantity_before,
       AVG(`quantity_sold(after_promo)`) AS avg_quantity_after
FROM fact_events;
  /*CONCLUSION
   The comparison reveals a significant increase in the average quantity sold after the 
   promotion, rising from 139.3667 to 290.3153. This indicates that the promotions have 
   effectively stimulated higher sales volumes, demonstrating their effectiveness in driving
   increased customer purchases */
  
-- Impact of Campaign ID on Quantity Sold
  
SELECT campaign_id,
       SUM(`quantity_sold(after_promo)`) AS total_quantity_sold
FROM fact_events
GROUP BY campaign_id;

    /*CONCLUSION
    #both campaigns were successful in driving sales, with "CAMP_SAN_01" yielding a higher
    #total quantity sold compared to "CAMP_DIW_01" */

-- Promotion Effectiveness by Product Category

SELECT 
    product_code,
    AVG(`revenue before promotion`) AS avg_revenue_before,
    AVG(`revenue after promotion`) AS avg_revenue_after
FROM fact_events
GROUP BY product_code
order by product_code ;
     /*CONCLUSION 
      Some products, like P02 and P15, made a lot more money after promotions. Others, like
      P05 and P10, didn't see as big of a boost. This means we should focus our promotional
      efforts more on products that have the potential to make more money with promotions*/
     
-- incremental revenue
SELECT sum((`revenue after promotion` - `revenue before promotion`)) as total_incremental_revenue
FROM fact_events;

-- Incremental revenue produced by diwali sale and sankaranti sale
SELECT campaign_id,sum((`revenue after promotion` - `revenue before promotion`)) as total_incremental_revenue
FROM fact_events
group by campaign_id;

-- Total Incremental revenue     
   SELECT sum((`revenue after promotion` - `revenue before promotion`)) as total_incremental_revenue
FROM fact_events;  
     
--  STORE PERGORMANCE ANALYSIS

     # Analyze sales performance by store location.
SELECT 
   fact_events.store_id, city,SUM(`revenue after promotion`) AS total_revenue
FROM fact_events
join dim_stores on fact_events.store_id = dim_stores.store_id
GROUP BY store_id
ORDER BY total_revenue DESC;
     /*CONCLUSION
      Cities like Mysuru, Chennai, and Bengaluru consistently show higher sales, suggesting
      variations in purchasing power and market demand across different locations */
      
--  which are the top 10 stoes in terms of incremental revenue generated from the promotions ?
SELECT 
    store_id,
    SUM(`revenue after promotion` - `revenue before promotion`) AS incremental_revenue
FROM fact_events
GROUP BY store_id
ORDER BY incremental_revenue DESC
LIMIT 10;

-- which are the bottom 10 stores when it comes to incremental sold units during the promotional period ?
SELECT 
    store_id,
    SUM(`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) AS bottom_incremental_sold_units
FROM fact_events
GROUP BY store_id
ORDER BY bottom_incremental_sold_units ASC
LIMIT 10;

-- How does performance of stores vary by city?
SELECT c.city,fe.`store_id`,sum(`revenue after promotion`)-sum(`revenue before promotion`) as profit,
        SUBSTRING_INDEX(c.store_id, '-', -1) as store_no
        FROM fact_events fe join `dim_stores` c 
        on fe.store_id = c.store_id
        group by fe.`store_id`
		order by profit desc;
      /*It appears that the top-performing stores are primarily located in cities like Mysuru, Chennai, Bengaluru,
      and Madurai */
      



-- Calculate CLV for each customer.
     /*we don't have individual customer IDs, we can use a combination of other columns to
      represent unique customer characteristics or behaviors. Let's assume we can use the 
      combination of 'event_id' and 'store_id' as a pseudo-customer identifier */

SELECT 
    CONCAT(event_id, '_', store_id) AS pseudo_customer_id,
    SUM(`revenue after promotion`) AS total_revenue,
    COUNT(DISTINCT event_id) AS total_transactions,
    SUM(`revenue after promotion`) / COUNT(DISTINCT event_id) AS clv
FROM fact_events
GROUP BY pseudo_customer_id;
      /*Some groups bring in more money and make more transactions, while others bring in 
       less. Understanding this helps businesses tailor their marketing strategies to focus 
       more on customers who bring in more money over time, which can ultimately increase
       overall sales and profits */




-- what are the top 2 promotion types that resulted in highest incremental revenue 
SELECT 
    promo_type,
    SUM(`revenue after promotion` - `revenue before promotion`) AS incremental_revenue
FROM fact_events
GROUP BY promo_type
ORDER BY incremental_revenue DESC
LIMIT 2;

-- what are the bottom 2 promotional types in terms of their impact on incremental sold units
SELECT 
    promo_type,
    SUM(`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) AS incremental_sold_units
FROM fact_events
GROUP BY promo_type
ORDER BY incremental_sold_units
LIMIT 2;

-- significant difference in the performance of discount-based promotions.
SELECT 
    promo_type,
    SUM(`revenue after promotion` - `revenue before promotion`) AS total_incremental_revenue
 FROM fact_events
 WHERE promo_type IN ('25% OFF', '50% OFF', 'BOGOF', '500 Cashback') -- Selecting relevant promotion types
 GROUP BY promo_type order by total_incremental_revenue desc ;

-- Which promotions strike the best balance between Incremental Sold Units and maintaining healthy margins?
SELECT 
    promo_type,
    SUM(`revenue after promotion` - `revenue before promotion`) / SUM(`quantity_sold(after_promo)` - `quantity_sold(before_promo)`) AS revenue_per_sold_unit
 FROM fact_events
 GROUP BY promo_type
 ORDER BY revenue_per_sold_unit DESC;
      /*conclusion 
       The promotions that strike the best balance between incremental sold units and maintaining healthy 
       margins are "500 Cashback", "25% OFF", and "BOGOF", with "500 Cashback" being the most effective in this 
       regard */

-- Identify customer segments based on their response to different types of promotions.
SELECT 
    CASE 
        WHEN promo_type = '25% OFF' THEN 'Promotion A'
        WHEN promo_type = '50% OFF' THEN 'Promotion B'
        WHEN promo_type = '33% OFF' THEN 'Promotion C'
        WHEN promo_type = '500 Cashback' THEN 'Promotion D'
        WHEN promo_type = 'BOGOF' THEN 'Promotion E '
        ELSE 'No Promotion'
    END AS promotion_type,count(*)  FROM fact_events group by  promotion_type order by count(*) DESC;
    /*CONCLUSION
     Promotion E received the highest customer response with 500 customers, followed by 
     Promotion A with 400 customers. This suggests that businesses should focus their 
     attention on Promotion A to maximize customer engagement and sales */
    
-- Which product categories saw the most significant lift in sales from the promotions?
SELECT 
    d.category as product_category,
SUM((`revenue after promotion`-`revenue before promotion`)) AS lift_in_sales
FROM fact_events join `dim_products`as d on fact_events.product_code = d.product_code
GROUP BY category
ORDER BY lift_in_sales DESC;
       /*conclusion
        Grocery & Staples, combo1 saw the most significant lift in sales from the promotions
	    P05	Atliq_Scrub_Sponge_For_Dishwash	Home Care
	-- Are there specific products that respond exceptionally well or poorly to promotions?
        P05 Atliq_Scrub_Sponge_For_Dishwash	Home Care   is the products that respond exceptionally poor
        P04	Atliq_Farm_Chakki_Atta (1KG)Grocery & Staples  is the products that respond exceptionally well */

-- incremental revenue based on promo type in each category .
SELECT category,promo_type,sum((`revenue after promotion`-`revenue before promotion`)) FROM fact_events 
JOIN dim_products on dim_products.product_code=fact_events.product_code 
group by category,promo_type
order by category ,sum(`revenue after promotion`) desc;

-- What is the correlation between product category and promotion type effectiveness?
SELECT 
    category,
    promo_type,
    (SUM((total_revenue - mean_revenue) * (total_sales - mean_sales)) 
        / 
        (SQRT(SUM(POWER(total_revenue- mean_revenue, 2))) 
            * 
            SQRT(SUM(POWER(total_sales- mean_sales, 2))))) AS correlation
FROM (SELECT 
        category,
        promo_type,
        SUM(`revenue after promotion` - `revenue before promotion`) AS total_revenue,
        SUM(`quantity_sold(after_promo)`) AS total_sales,
        AVG(`revenue after promotion` - `revenue before promotion`) AS mean_revenue,
        AVG(`quantity_sold(after_promo)`) AS mean_sales
    FROM fact_events
    JOIN dim_products ON fact_events.product_code = dim_products.product_code
    GROUP BY category, promo_type
) AS sales_by_product_promotion
GROUP BY category, promo_type;
         /*conclusion
         BOGOF (Buy One Get One Free) promotions seem to have a strong negative correlation
         with Grocery & Staples products, implying that these promotions may not be as effective
         for this category compared to others. Conversely, promotions like 25% OFF appear to be
         more universally effective across different product categories */

-- Number of Products Sold from Each Category, Arranged According to Sum of Quantity Sold After Promotion
SELECT promo_type ,`dim_products`.product_code,`dim_products`.product_name, `dim_products`.category,
SUM(`quantity_sold(after_promo)`),count(*) FROM fact_events JOIN `dim_products`
ON fact_events.product_code= `dim_products`.product_code GROUP BY promo_type ,product_code 
order by SUM(`quantity_sold(after_promo)`) DESC;

------------------------------------------------



    
 





