-- Assessment of data
   -- Table dim_campaigns
DESCRIBE retail_events_db.dim_campaigns;  -- DESCRIBE reveals a table's structure, including column names and data types.
   #column'start_date' and 'end_date' have text data type need to be change in datetime datatype
   #For this analysis all campaigns data must be present. No null values allowed!"
   
   -- Table dim_products
DESCRIBE retail_events_db.dim_products;

   -- Table dim_stores
describe retail_events_db.dim_stores;

   -- Table fact_events
DESCRIBE retail_events_db.fact_events;
   ##check for null values
SELECT * FROM retail_events_db.fact_events WHERE event_id IS NULL AND store_id IS NULL AND 
campaign_id IS NULL AND product_code IS NULL AND base_price IS NULL AND promo_type IS NULL AND
`quantity_sold(before_promo)` IS NULL AND `quantity_sold(after_promo)`IS NULL;
  ## check for duplicate values
select * from (SELECT *,COUNT(*) as c FROM retail_events_db.fact_events GROUP BY event_id,store_id,campaign_id,
product_code,base_price,promo_type,`quantity_sold(before_promo)`,`quantity_sold(after_promo)`) d where c > 1;

-- Dirty data 
  -- Table fact_events
	#In column 'event_id' there are some corrupted data 
-- Messy data
    #There are no messy data 


