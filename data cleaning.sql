-- Always create a backup table
create Table  dim_campaigns_backup like dim_campaigns ;
INSERT INTO  dim_campaigns_backup SELECT * FROM dim_campaigns;

create Table dim_products_backup like dim_products ;
INSERT INTO  dim_products_backup SELECT * FROM dim_products ;

create Table dim_stores_backup like dim_stores ;
INSERT INTO  dim_stores_backup SELECT * from  dim_stores;

create Table fact_events_backup like fact_events ;
INSERT INTO  fact_events_backup SELECT * FROM fact_events;

-- Check new tables properly made
select * from dim_campaigns;
SELECT * FROM dim_campaigns_backup;
SELECT * FROM dim_products_backup;
SELECT * FROM dim_stores_backup;
SELECT * FROM fact_events_backup;

-- cleaning data
ALTER TABLE dim_campaigns
MODIFY end_date DATE;  -- change datatype of end_date and start_date.
ALTER TABLE dim_campaigns
MODIFY start_date DATE;

SELECT * FROM fact_events
WHERE event_id LIKE '%+%';
-- SOME event_id ARE corrupt but their data are important.we do not know the event id but they are unique so we consider each as event_id

-- feature engenieering

#ADD NEW COLUMN NAME ID,CONTAIN,UNIQUE NUMBER
ALTER TABLE fact_events
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;
#ADD THREE NEW COLUMN    
ALTER TABLE fact_events
ADD COLUMN `BASE_PRICE_AFTER_Discount` integer AFTER promo_type,
ADD COLUMN `revenue before promotion` integer,
ADD COLUMN `revenue after promotion` integer;

SET SQL_SAFE_UPDATES=0;
#we have to find the revenue before promotion
UPDATE fact_events F1
SET `BASE_PRICE_AFTER_Discount` = (select 
 case when promo_type ="50% OFF" Then (50*base_price)/100
	  when promo_type ="25% OFF" Then  (base_price-(25*base_price)/100)
	  WHEN promo_type ="BOGOF" Then (50*base_price)/100  
	  when promo_type ="500 Cashback" Then (base_price-500)
	  WHEN promo_type ="33% OFF" THEN (base_price-(33*base_price)/100)
 End AS U 
      from (SELECT * FROM fact_events ) F2 where F1.`id` = F2.`id`);

UPDATE fact_events F3
SET `revenue before promotion`=(select base_price*`quantity_sold(before_promo)`as revenue_before_promotion from 
  (SELECT * FROM fact_events) F4 WHERE F3.`id` = F4.`id`);
  
 #we have to find the revenue after promotion
UPDATE fact_events AS F5
JOIN (
    SELECT 
        id,
        CASE 
            WHEN promo_type = '50% OFF' THEN BASE_PRICE_AFTER_Discount * `quantity_sold(after_promo)`
            WHEN promo_type = '25% OFF' THEN BASE_PRICE_AFTER_Discount * `quantity_sold(after_promo)`
            WHEN promo_type = '500 Cashback' THEN BASE_PRICE_AFTER_Discount * `quantity_sold(after_promo)`
            WHEN promo_type = '33% OFF' THEN BASE_PRICE_AFTER_Discount * `quantity_sold(after_promo)`
            WHEN MOD(`quantity_sold(after_promo)`, 2) = 0 THEN BASE_PRICE_AFTER_Discount * `quantity_sold(after_promo)`
            ELSE (BASE_PRICE_AFTER_Discount * (`quantity_sold(after_promo)` - 1)) + base_price 
        END AS new_revenue
    FROM fact_events
) AS F6 ON F5.id = F6.id
SET F5.`revenue after promotion` = F6.new_revenue;
     #In a "Buy One Get One" (BOGO) offer, the number of products sold should indeed be even
     # This is because for every product purchased, another one is given for free as part of the offer. 
     #Thus, for every transaction in a BOGO offer, the number of products sold will always be an even number.
     #But in column quantity_sold(after_promo) for "Buy One Get One" where products sold is odd 
	 # so we consider that Customers might not have realized that it was a BOGO offer and purchased an odd number of products.
SELECT * FROM fact_events;














