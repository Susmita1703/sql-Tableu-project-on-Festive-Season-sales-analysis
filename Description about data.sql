-- summary of Data 
/*	   Dataset contain 4 tables 'promotional campaigns', 'products', 
       'sales events' and 'store locations'.
        We have information on campaigns like 
       "Diwali" and "Sankranti," along with product details like "Atliq_Masoor_Dal" and 
       its category. 
       The heart of the analysis lies in the event table, which links 
       campaigns, products, and stores. This table captures details like base price, 
       promotion type, and quantity sold before and after promotions.
       Finally, the store table associates store IDs with their respective cities. By examining these 
       relationships, we can assess the effectiveness of promotions, product performance
       under discounts, and sales variations across different store locations.		*/
       
-- column descriptions

  -- Column Description for dim_campaigns:
  # campaign_id: Unique identifier for each promotional campaign.
  # campaign_name: Descriptive name of the campaign (e.g., Diwali, Sankranti).
  # start_date: The date on which the campaign begins.
  # end_date: The date on which the campaign ends.
  
  -- Column Description for dim_products:
  #product_code: Unique code assigned to each product for identification.
  # product_name: The full name of the product, including brand and specifics (e.g., quantity, size).
  #category: The classification of the product into broader categories such as Grocery & Staples, Home Care, Personal Care, Home Appliances, etc.

  -- Column Description for dim_stores:
  #store_id: Unique code identifying each store location.
  #city: The city where the store is located, indicating the geographical market.
  
  -- Column Description for fact_events:
  #event_id: Unique identifier for each sales event. 
  #store_id: Refers to the store where the event took place, linked to the dim_stores table.
  #campaign_id: Indicates the campaign under which the event was recorded, linked to the dim_campaigns table.
  #product_code: The code of the product involved in the sales event, linked to the dim_products table.
  #base_price: The standard price of the product before any promotional discount.
  #promo_type: The type of promotion applied (e.g., percentage discount, BOGOF(Buy One Get One Free), cashback).
  #quantity_sold(before_promo): The number of units sold in the week immediately preceding the start of the campaign, serving as a baseline for comparison with promotional sales.
  #quantity_sold(after_promo): The quantity of the product sold after the promotion was applied.



