SELECT
    pt.flt_pyt_debug_core_partner_id,
    p.partner_trade_name,
    p.address,
    p.contact_number,
    p.segment_type AS partner_segment_type,
    p.country,
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
    ) AS adjusted_product_cost_per_usage,
    COALESCE(ccl.product_cost_per_usage, first_ccl.product_cost_per_usage) AS product_cost_per_usage,
    COALESCE(ccl.activity_name, first_ccl.activity_name) AS activity_name,
    COALESCE(ccl.segment_type, first_ccl.segment_type) AS product_segment_type,
    COALESCE(ccl.last_price_update, first_ccl.last_price_update) AS last_price_update,
   
    CASE
        WHEN pt.flt_pyt_transaction_type IN ('Validation', 'Retroactive') THEN 'Sessao realizada'
        ELSE 'Sessao não realizada'
    END AS session_group,

    CASE
        WHEN COALESCE(ccl.product_cap_value, first_ccl.product_cap_value) < 
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
             )
        THEN COALESCE(ccl.product_cap_value, first_ccl.product_cap_value)
        ELSE COALESCE(
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
             )
    END AS total_payment,
    CASE
        WHEN COALESCE(
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
             ) >= COALESCE(ccl.product_cap_value, first_ccl.product_cap_value)
        THEN 1
        ELSE 0
    END AS cap_hit_flag,

    CASE
        WHEN COALESCE(ccl.product_cap_value, first_ccl.product_cap_value) < 
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
             )
        THEN 1
        ELSE 0
    END AS cost_less_than_cap
FROM payment_transactions pt
LEFT JOIN partners p 
    ON pt.flt_pyt_debug_core_partner_id = p.core_partner_id


OUTER APPLY (
    SELECT TOP 1
        ccl1.product_cost_per_usage,
        ccl1.product_cap_value,
        ccl1.activity_name,
        ccl1.segment_type,
        ccl1.last_price_update
    FROM cap_change_log ccl1
    WHERE ccl1.core_partner_id = pt.flt_pyt_debug_core_partner_id
    AND ccl1.satya_partner_product_id = pt.flt_pyt_partner_product_id
    AND ccl1.last_price_update <= pt.flt_pyt_transaction_created_at
    ORDER BY ccl1.last_price_update DESC
) ccl


OUTER APPLY (
    SELECT TOP 1
        ccl2.product_cost_per_usage,
        ccl2.product_cap_value,
        ccl2.activity_name,
        ccl2.segment_type,
        ccl2.last_price_update
    FROM cap_change_log ccl2
    WHERE ccl2.core_partner_id = pt.flt_pyt_debug_core_partner_id
    AND ccl2.satya_partner_product_id = pt.flt_pyt_partner_product_id
    ORDER BY ccl2.last_price_update ASC
) first_ccl;
