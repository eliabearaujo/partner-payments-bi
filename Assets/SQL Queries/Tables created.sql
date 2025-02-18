CREATE TABLE fact_partners_payout (
    core_partner_id INT IDENTITY(1,1) PRIMARY KEY,
    partner_trade_name VARCHAR(255),
    partner_product_id INT,
    session_considered_at_localtime DATETIME,
	transaction_created_at DATETIME,
	gympass_individual_id INT,
    transaction_cost FLOAT,
    transaction_type VARCHAR(100),
    product_cap FLOAT
);

CREATE TABLE dim_store_partners (
    core_partner_id INT PRIMARY KEY,
    partner_trade_name VARCHAR(255),
    address VARCHAR(255),
    contact_number VARCHAR(50),
    segment_type VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE dim_store_partner_products (
    product_id INT PRIMARY KEY,
	activity_name VARCHAR(255),
    product_cost_per_usage FLOAT,
    product_cap_value FLOAT,
    segment_type VARCHAR(100),
	last_price_update DATETIME
);

