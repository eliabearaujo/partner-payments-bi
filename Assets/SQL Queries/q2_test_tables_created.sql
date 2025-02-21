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

INSERT INTO payment_transactions (
    flt_pyt_debug_core_partner_id, 
    flt_pyt_partner_trade_name, 
    flt_pyt_partner_product_id, 
    flt_pyt_session_considered_at_localtime, 
    flt_pyt_transaction_created_at, 
    flt_pyt_debug_gympass_individual_id, 
    flt_pyt_transaction_type
) VALUES
(101, 'Gym B', 1001, CONVERT(DATETIME, '2025-01-21 10:07:40', 120), CONVERT(DATETIME, '2025-01-21 07:07:40', 120), 2002, 'NO_SHOW'),
(101, 'Gym B', 1001, CONVERT(DATETIME, '2025-01-24 18:13:06', 120), CONVERT(DATETIME, '2025-01-24 15:13:06', 120), 390, 'VALIDATION'),
(101, 'Gym D', 1001, CONVERT(DATETIME, '2025-01-18 19:42:19', 120), CONVERT(DATETIME, '2025-01-18 16:42:19', 120), 269, 'LATE_CANCEL'),
(101, 'Gym D', 1001, CONVERT(DATETIME, '2025-01-07 16:13:37', 120), CONVERT(DATETIME, '2025-01-07 13:13:37', 120), 821, 'RETROACTIVE');


INSERT INTO partners (
    core_partner_id, 
    partner_trade_name, 
    address, 
    contact_number, 
    segment_type, 
    country
) VALUES
(101, 'FitClub Gym', '123 Main St, Downtown', '(202) 123-4567', 'Full Service Gym', 'United States');


INSERT INTO cap_change_log (
	cap_change_id,
    core_partner_id, 
    satya_partner_product_id, 
    activity_name, 
    product_cost_per_usage, 
    product_cap_value, 
    segment_type, 
    last_price_update
) VALUES
(1,101, 1001, 'Musculação', 50, 50, 'Full Service Gym', CONVERT(DATETIME, '2025-01-10 00:00:00', 120));

SELECT * FROM payment_transactions
SELECT * FROM partners
SELECT * FROM cap_change_log