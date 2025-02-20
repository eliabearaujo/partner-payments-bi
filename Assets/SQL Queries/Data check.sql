SELECT TOP 10 * FROM fact_partners_payout;
SELECT TOP 10 * FROM dim_store_partners;
SELECT TOP 10 * FROM dim_store_partner_products;

SELECT COUNT(*) as 'table_1' FROM fact_partners_payout;
SELECT COUNT(*) as 'table_2' FROM dim_store_partners;
SELECT COUNT(*) as 'table_3' FROM dim_store_partner_products;


SELECT 
	AVG(transaction_cost) as 'transaction_cost',
	AVG(product_cap) as 'product_cap'
FROM fact_partners_payout