-- Query trazendo o cap e o custo antes da solicitaçao de ajuste.

SELECT 
    pt.*, 
    ccl.product_cap_value,
    CASE 
        WHEN pt.flt_pyt_transaction_type = 'LATE_CANCEL' 
        THEN ccl.product_cost_per_usage / 2
        ELSE ccl.product_cost_per_usage
    END AS adjusted_product_cost_per_usage
FROM payment_transactions pt
LEFT JOIN cap_change_log ccl 
    ON pt.flt_pyt_debug_core_partner_id = ccl.core_partner_id 
    AND pt.flt_pyt_partner_product_id = ccl.satya_partner_product_id;

-- Inserindo primeira solicitacao de de alteracao do parceiro.

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
(2,101, 1001, 'Musculação', 80, 70, 'Full Service Gym', CONVERT(DATETIME, '2025-01-17 00:00:00', 120));

-- Verificando se foi inserida uma solicitacao de alteracao
SELECT * FROM cap_change_log

-- Verificando se o novo preco esta sendo aplicado.
SELECT 
    pt.flt_pyt_debug_core_partner_id,
    pt.flt_pyt_partner_trade_name,
    pt.flt_pyt_partner_product_id,
    pt.flt_pyt_session_considered_at_localtime,
    pt.flt_pyt_transaction_created_at,
    pt.flt_pyt_debug_gympass_individual_id,
    pt.flt_pyt_transaction_type,
    COALESCE(ccl.product_cap_value, first_ccl.product_cap_value) AS product_cap_value,
    COALESCE(
        CASE 
            WHEN pt.flt_pyt_transaction_type = 'LATE_CANCEL' 
            THEN ccl.product_cost_per_usage / 2
            ELSE ccl.product_cost_per_usage
        END,
        CASE 
            WHEN pt.flt_pyt_transaction_type = 'LATE_CANCEL' 
            THEN first_ccl.product_cost_per_usage / 2
            ELSE first_ccl.product_cost_per_usage
        END
    ) AS adjusted_product_cost_per_usage
FROM payment_transactions pt

-- Pega o preço mais recente antes da data da transação
OUTER APPLY (
    SELECT TOP 1
        ccl1.product_cost_per_usage,
        ccl1.product_cap_value
    FROM cap_change_log ccl1
    WHERE ccl1.core_partner_id = pt.flt_pyt_debug_core_partner_id
    AND ccl1.satya_partner_product_id = pt.flt_pyt_partner_product_id
    AND ccl1.last_price_update <= pt.flt_pyt_transaction_created_at
    ORDER BY ccl1.last_price_update DESC
) ccl

-- Se não houver um preço anterior, pega o primeiro preço registrado
OUTER APPLY (
    SELECT TOP 1
        ccl2.product_cost_per_usage,
        ccl2.product_cap_value
    FROM cap_change_log ccl2
    WHERE ccl2.core_partner_id = pt.flt_pyt_debug_core_partner_id
    AND ccl2.satya_partner_product_id = pt.flt_pyt_partner_product_id
    ORDER BY ccl2.last_price_update ASC
) first_ccl;

-- Inserindo segunda solicitacao de de alteracao do parceiro.

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
(3,101, 1001, 'Musculação', 90, 75, 'Full Service Gym', CONVERT(DATETIME, '2025-01-23 00:00:00', 120));

-- Verificando se foi inserida uma solicitacao de alteracao
SELECT * FROM cap_change_log

-- Verificando se o novo preco esta sendo aplicado.
SELECT 
    pt.flt_pyt_debug_core_partner_id,
    pt.flt_pyt_partner_trade_name,
    pt.flt_pyt_partner_product_id,
    pt.flt_pyt_session_considered_at_localtime,
    pt.flt_pyt_transaction_created_at,
    pt.flt_pyt_debug_gympass_individual_id,
    pt.flt_pyt_transaction_type,
    COALESCE(ccl.product_cap_value, first_ccl.product_cap_value) AS product_cap_value,
    COALESCE(
        CASE 
            WHEN pt.flt_pyt_transaction_type = 'LATE_CANCEL' 
            THEN ccl.product_cost_per_usage / 2
            ELSE ccl.product_cost_per_usage
        END,
        CASE 
            WHEN pt.flt_pyt_transaction_type = 'LATE_CANCEL' 
            THEN first_ccl.product_cost_per_usage / 2
            ELSE first_ccl.product_cost_per_usage
        END
    ) AS adjusted_product_cost_per_usage
FROM payment_transactions pt

-- Pega o preço mais recente antes da data da transação
OUTER APPLY (
    SELECT TOP 1
        ccl1.product_cost_per_usage,
        ccl1.product_cap_value
    FROM cap_change_log ccl1
    WHERE ccl1.core_partner_id = pt.flt_pyt_debug_core_partner_id
    AND ccl1.satya_partner_product_id = pt.flt_pyt_partner_product_id
    AND ccl1.last_price_update <= pt.flt_pyt_transaction_created_at
    ORDER BY ccl1.last_price_update DESC
) ccl

-- Se não houver um preço anterior, pega o primeiro preço registrado
OUTER APPLY (
    SELECT TOP 1
        ccl2.product_cost_per_usage,
        ccl2.product_cap_value
    FROM cap_change_log ccl2
    WHERE ccl2.core_partner_id = pt.flt_pyt_debug_core_partner_id
    AND ccl2.satya_partner_product_id = pt.flt_pyt_partner_product_id
    ORDER BY ccl2.last_price_update ASC
) first_ccl;

-- Deletando registro para verificar se a regra continua funcionando
DELETE FROM cap_change_log
WHERE cap_change_ID IN (2, 3);

SELECT * FROM cap_change_log

SELECT 
    pt.flt_pyt_debug_core_partner_id,
    pt.flt_pyt_partner_trade_name,
    pt.flt_pyt_partner_product_id,
    pt.flt_pyt_session_considered_at_localtime,
    pt.flt_pyt_transaction_created_at,
    pt.flt_pyt_debug_gympass_individual_id,
    pt.flt_pyt_transaction_type,
    COALESCE(ccl.product_cap_value, first_ccl.product_cap_value) AS product_cap_value,
    COALESCE(
        CASE 
            WHEN pt.flt_pyt_transaction_type = 'LATE_CANCEL' 
            THEN ccl.product_cost_per_usage / 2
            ELSE ccl.product_cost_per_usage
        END,
        CASE 
            WHEN pt.flt_pyt_transaction_type = 'LATE_CANCEL' 
            THEN first_ccl.product_cost_per_usage / 2
            ELSE first_ccl.product_cost_per_usage
        END
    ) AS adjusted_product_cost_per_usage
FROM payment_transactions pt

-- Pega o preço mais recente antes da data da transação
OUTER APPLY (
    SELECT TOP 1
        ccl1.product_cost_per_usage,
        ccl1.product_cap_value
    FROM cap_change_log ccl1
    WHERE ccl1.core_partner_id = pt.flt_pyt_debug_core_partner_id
    AND ccl1.satya_partner_product_id = pt.flt_pyt_partner_product_id
    AND ccl1.last_price_update <= pt.flt_pyt_transaction_created_at
    ORDER BY ccl1.last_price_update DESC
) ccl

-- Se não houver um preço anterior, pega o primeiro preço registrado
OUTER APPLY (
    SELECT TOP 1
        ccl2.product_cost_per_usage,
        ccl2.product_cap_value
    FROM cap_change_log ccl2
    WHERE ccl2.core_partner_id = pt.flt_pyt_debug_core_partner_id
    AND ccl2.satya_partner_product_id = pt.flt_pyt_partner_product_id
    ORDER BY ccl2.last_price_update ASC
) first_ccl;

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
(2, 101, 1001, 'Musculação', 80, 70, 'Full Service Gym', CONVERT(DATETIME, '2025-01-23 00:00:00', 120)),
(3, 101, 1001, 'Musculação', 90, 75, 'Full Service Gym', CONVERT(DATETIME, '2025-01-19 00:00:00', 120)),
(4, 101, 1001, 'Musculação', 150, 160, 'Full Service Gym', CONVERT(DATETIME, '2025-01-24 00:00:00', 120));

-- Verificando se foi inserida uma solicitacao de alteracao
SELECT * FROM cap_change_log

SELECT 
    pt.flt_pyt_debug_core_partner_id,
    pt.flt_pyt_partner_trade_name,
    pt.flt_pyt_partner_product_id,
    pt.flt_pyt_session_considered_at_localtime,
    pt.flt_pyt_transaction_created_at,
    pt.flt_pyt_debug_gympass_individual_id,
    pt.flt_pyt_transaction_type,
    COALESCE(ccl.product_cap_value, first_ccl.product_cap_value) AS product_cap_value,
    COALESCE(
        CASE 
            WHEN pt.flt_pyt_transaction_type = 'LATE_CANCEL' 
            THEN ccl.product_cost_per_usage / 2
            ELSE ccl.product_cost_per_usage
        END,
        CASE 
            WHEN pt.flt_pyt_transaction_type = 'LATE_CANCEL' 
            THEN first_ccl.product_cost_per_usage / 2
            ELSE first_ccl.product_cost_per_usage
        END
    ) AS adjusted_product_cost_per_usage
FROM payment_transactions pt

-- Pega o preço mais recente antes da data da transação
OUTER APPLY (
    SELECT TOP 1
        ccl1.product_cost_per_usage,
        ccl1.product_cap_value
    FROM cap_change_log ccl1
    WHERE ccl1.core_partner_id = pt.flt_pyt_debug_core_partner_id
    AND ccl1.satya_partner_product_id = pt.flt_pyt_partner_product_id
    AND ccl1.last_price_update <= pt.flt_pyt_transaction_created_at
    ORDER BY ccl1.last_price_update DESC
) ccl

-- Se não houver um preço anterior, pega o primeiro preço registrado
OUTER APPLY (
    SELECT TOP 1
        ccl2.product_cost_per_usage,
        ccl2.product_cap_value
    FROM cap_change_log ccl2
    WHERE ccl2.core_partner_id = pt.flt_pyt_debug_core_partner_id
    AND ccl2.satya_partner_product_id = pt.flt_pyt_partner_product_id
    ORDER BY ccl2.last_price_update ASC
) first_ccl;