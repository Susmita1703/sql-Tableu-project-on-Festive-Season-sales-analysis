#BUSINESS REQUEST

/*-- 1. Provide a list of products with a base price greater than 500 and that are featured
in promo type of 'BOGOF' (Buy One Get One Free). This information will help us
identify high-value products that are currently being heavily discounted, which
can be useful for evaluating our pricing and promotion strategies */

SELECT product_name,fact_events.base_price,fact_events.promo_type FROM fact_events
JOIN `dim_products` ON `dim_products`.product_code=fact_events.product_code 
WHERE fact_events.promo_type ='BOGOF' AND base_price >500;

/*-- 2. Generate a report that provides an overview of the number of stores in each city.
The results will be sorted in descending order of store counts, allowing us to
identify the cities with the highest store presence.The report includes two
essential fields: city and store count, which will assist in optimizing our retail
operations */

select city , count(store_id) as store_count from dim_stores group by city order by store_count desc ;

/*-- 3. Generate a report that displays each campaign along with the total revenue
generated before and after the campaign? The report includes three key fields:
campaign_name, total_revenue(before_promotion),
total_revenue(after_promotion). This report should help in evaluating the financial
impact of our promotional campaigns. (Display the values in millions) */

select campaign_id, sum(`revenue before promotion`)/1000000 as `total_revenue(before_promotion)_in_millons`
 ,sum(`revenue after promotion`)/1000000  as `total_revenue(after_promotion)_in_millons` from fact_events group by campaign_id;


/*-- 4. Produce a report that calculates the Incremental Sold Quantity (ISU%) for each
category during the Diwali campaign. Additionally, provide rankings for the
categories based on their ISU%. The report will include three key fields:
category, isu%, and rank order. This information will assist in assessing the
category-wise success and impact of the Diwali campaign on incremental sales.

Note: ISU% (Incremental Sold Quantity Percentage) is calculated as the
percentage increase/decrease in quantity sold (after promo) compared to
quantity sold (before promo) */


SELECT
    category, 
    ISU_percentage,
    RANK() OVER (ORDER BY ISU_percentage DESC) AS ISU_rank
FROM (
    SELECT
        category, 
        (SUM(`quantity_sold(after_promo)`)-SUM(`quantity_sold(before_promo)`))/SUM(`quantity_sold(before_promo)`)*100 AS ISU_percentage
    FROM fact_events 
    JOIN dim_products d ON fact_events.product_code = d.product_code  
    where fact_events .campaign_id="CAMP_DIW_01"
    GROUP BY category
) AS ISU_rankings;

/*-- 5. Create a report featuring the Top 5 products,ranked by Incremental Revenue
Percentage (IR%), across all campaigns. The report will provide essential
information including product name, category, and ir%. This analysis helps
identify the most successful products in terms of incremental revenue across our
campaigns, assisting in product optimization  */     
        
WITH ranked_campaigns AS (
    SELECT 
        campaign_id,
        product_name,
        category,
        IR_percentage,
        ROW_NUMBER() OVER (PARTITION BY campaign_id ORDER BY IR_percentage DESC) AS `rank`
    FROM (
        SELECT 
            campaign_id,
            product_name,
            category,
            (SUM(`revenue after promotion` - `revenue before promotion`) / SUM(`revenue before promotion`)) * 100 AS IR_percentage
        FROM 
            fact_events 
        JOIN 
            dim_products d ON fact_events.product_code = d.product_code
        GROUP BY 
            product_name,
            category,
            campaign_id
        ORDER BY 
            campaign_id
    ) h
)

SELECT 
    *
FROM 
    ranked_campaigns
WHERE 
    `rank` <= 5;
    
    
/* Top 5 products,ranked by Incremental Revenue
Percentage (IR%)*/
    
    WITH ranked_products AS (
    SELECT campaign_id,
        product_name,
        category,
        IR_percentage,
        ROW_NUMBER() OVER (ORDER BY IR_percentage DESC) AS `rank`
    FROM (
        SELECT campaign_id,
            product_name,
            category,
            (SUM(`revenue after promotion` - `revenue before promotion`) / SUM(`revenue before promotion`)) * 100 AS IR_percentage
        FROM 
            fact_events 
        JOIN 
            dim_products d ON fact_events.product_code = d.product_code
        GROUP BY 
            product_name,
            category,campaign_id) h)

SELECT *
FROM ranked_products
WHERE 
    `rank` <= 5;

