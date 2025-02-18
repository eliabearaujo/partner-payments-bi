SELECT TOP 10 * FROM fact_partners_payout;
SELECT TOP 10 * FROM dim_store_partners;
SELECT TOP 10 * FROM dim_store_partner_products;

SELECT COUNT(*) FROM fact_partners_payout;
SELECT COUNT(*) FROM dim_store_partners;
SELECT COUNT(*) FROM dim_store_partner_products;


SELECT 
	AVG(transaction_cost) as 'transaction_cost',
	AVG(product_cap) as 'product_cap'
FROM fact_partners_payout