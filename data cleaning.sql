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

SELECT * FROM fact_events;














