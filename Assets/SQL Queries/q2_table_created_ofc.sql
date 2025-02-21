CREATE TABLE payment_transactions (
    flt_pyt_debug_core_partner_id INT,
    flt_pyt_partner_trade_name VARCHAR(255),
    flt_pyt_partner_product_id INT,
    flt_pyt_session_considered_at_localtime DATETIME,
    flt_pyt_transaction_created_at DATETIME,
    flt_pyt_debug_gympass_individual_id INT,
    flt_pyt_transaction_type VARCHAR(50)
);

CREATE TABLE partners (
    core_partner_id INT PRIMARY KEY,
    partner_trade_name VARCHAR(255),
    address VARCHAR(255),
    contact_number VARCHAR(50),
    segment_type VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE cap_change_log (
	cap_change_id INT,
    core_partner_id INT,
    satya_partner_product_id INT,
    activity_name VARCHAR(100),
    product_cost_per_usage FLOAT,
    product_cap_value FLOAT,
    segment_type VARCHAR(100),
    last_price_update DATETIME
);

