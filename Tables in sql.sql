CREATE DATABASE IF NOT EXISTS retail_events_db;
USE retail_events_db;
-- Table structure for table `dim_campaigns`
CREATE TABLE `dim_campaigns` (
  `campaign_id` varchar(20) NOT NULL,
  `campaign_name` varchar(50) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  PRIMARY KEY (`campaign_id`)
);     

-- Table structure for table `dim_products`
CREATE TABLE `dim_products` (
  `product_code` varchar(10) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `category` varchar(50) NOT NULL,
  PRIMARY KEY (`product_code`));
  
  -- Table structure for table `dim_stores`
  CREATE TABLE `dim_stores` (
  `store_id` varchar(15) NOT NULL,
  `city` varchar(50) NOT NULL,
  PRIMARY KEY (`store_id`)
);

-- Table structure for table `fact_events`
CREATE TABLE `fact_events` (
  `event_id` varchar(10) NOT NULL,
  `store_id` varchar(10) NOT NULL,
  `campaign_id` varchar(20) NOT NULL,
  `product_code` varchar(10) NOT NULL,
  `base_price` int NOT NULL,
  `promo_type` varchar(50) DEFAULT NULL,
  `quantity_sold(before_promo)` int NOT NULL,
  `quantity_sold(after_promo)` int NOT NULL
);




  
  
  
  




