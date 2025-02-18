--Query para verificar se um cliente agendou mais de uma sessão no mesmo dia/verificar a possibilidade de isso ocorrer.
SELECT 
    gympass_individual_id, 
    CAST(session_considered_at_localtime AS DATE) AS session_date, 
    COUNT(*) AS session_count
FROM fact_partners_payout
GROUP BY gympass_individual_id, CAST(session_considered_at_localtime AS DATE)
HAVING COUNT(*) > 1;

--visao do parceiro

WITH all_days AS (
    SELECT DISTINCT CAST(fpp.session_considered_at_localtime AS DATE) AS visit_date
    FROM fact_partners_payout fpp
),
capped_visit_cost AS (
    SELECT 
        fpp.core_partner_id,
        fpp.gympass_individual_id,
        fpp.partner_product_id,
        fpp.session_considered_at_localtime,
        fpp.transaction_cost,
        fpp.product_cap,
        CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN fpp.product_cap
            ELSE fpp.transaction_cost
        END AS capped_cost -- Paga o menor valor entre transaction_cost e product_cap
    FROM fact_partners_payout fpp
),
partner_numbers AS (
    SELECT 
        dsp.partner_trade_name, 
        COUNT(*) AS jan_total_visits,
        SUM(fpp.transaction_cost) AS jan_total_revenue,
        SUM(cvc.capped_cost) AS jan_total_payment,
        ROUND(AVG(fpp.product_cap), 2) AS avg_cap, -- CAP médio por parceiro
        SUM(CASE 
            WHEN fpp.transaction_cost >= fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_hit_count, -- Conta quantas vezes o CAP foi atingido
        SUM(CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_less_than_cost_count -- Conta quantas vezes o CAP era menor que o custo
    FROM fact_partners_payout fpp
    JOIN dim_store_partners dsp ON fpp.core_partner_id = dsp.core_partner_id
    LEFT JOIN capped_visit_cost cvc 
        ON fpp.core_partner_id = cvc.core_partner_id
        AND fpp.gympass_individual_id = cvc.gympass_individual_id
        AND fpp.partner_product_id = cvc.partner_product_id
        AND fpp.session_considered_at_localtime = cvc.session_considered_at_localtime
    GROUP BY dsp.partner_trade_name
)
SELECT 
    pn.partner_trade_name, 
    pn.jan_total_visits,
    ROUND(CAST(pn.jan_total_visits AS FLOAT) / (SELECT COUNT(*) FROM all_days), 2) AS avg_visits_per_day,
    ROUND(CAST(pn.jan_total_revenue AS FLOAT) / (SELECT COUNT(*) FROM all_days), 2) AS avg_revenue_per_day,
    pn.jan_total_payment,
    pn.avg_cap,
    pn.cap_hit_count,
    pn.cap_less_than_cost_count
FROM partner_numbers pn
ORDER BY pn.jan_total_payment DESC;

--visao por produto

WITH all_days AS (
    SELECT DISTINCT CAST(fpp.session_considered_at_localtime AS DATE) AS visit_date
    FROM fact_partners_payout fpp
),
capped_visit_cost AS (
    SELECT 
        fpp.core_partner_id,
        fpp.gympass_individual_id,
        fpp.partner_product_id,
        fpp.session_considered_at_localtime,
        fpp.transaction_cost,
        fpp.product_cap,
        CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN fpp.product_cap
            ELSE fpp.transaction_cost
        END AS capped_cost -- Paga o menor valor entre transaction_cost e product_cap
    FROM fact_partners_payout fpp
),
product_numbers AS (
    SELECT 
        dsp.activity_name, -- Nome da atividade (produto)
        COUNT(*) AS jan_total_visits,
        SUM(fpp.transaction_cost) AS jan_total_revenue,
        SUM(cvc.capped_cost) AS jan_total_payment,
        ROUND(AVG(fpp.product_cap), 2) AS avg_cap, -- CAP médio por produto
        SUM(CASE 
            WHEN fpp.transaction_cost >= fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_hit_count, -- Conta quantas vezes o CAP foi atingido
        SUM(CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_less_than_cost_count -- Conta quantas vezes o CAP era menor que o custo
    FROM fact_partners_payout fpp
    JOIN dim_store_partner_products dsp ON fpp.partner_product_id = dsp.satya_partner_product_id
    LEFT JOIN capped_visit_cost cvc 
        ON fpp.core_partner_id = cvc.core_partner_id
        AND fpp.gympass_individual_id = cvc.gympass_individual_id
        AND fpp.partner_product_id = cvc.partner_product_id
        AND fpp.session_considered_at_localtime = cvc.session_considered_at_localtime
    GROUP BY dsp.activity_name
),
total_numbers AS (
    SELECT
        SUM(jan_total_visits) AS total_visits,
        SUM(jan_total_revenue) AS total_revenue,
        SUM(jan_total_payment) AS total_payment
    FROM product_numbers
)
SELECT 
    pn.activity_name, 
    pn.jan_total_visits,
    ROUND(CAST(pn.jan_total_visits AS FLOAT) / (SELECT COUNT(*) FROM all_days), 2) AS avg_visits_per_day,
    ROUND(CAST(pn.jan_total_revenue AS FLOAT) / (SELECT COUNT(*) FROM all_days), 2) AS avg_revenue_per_day,
    pn.jan_total_payment,
    pn.avg_cap,
    pn.cap_hit_count,
    pn.cap_less_than_cost_count,
    ROUND(CAST(pn.jan_total_visits AS FLOAT) / tn.total_visits * 100, 2) AS pct_total_visits,
    ROUND(CAST(pn.jan_total_revenue AS FLOAT) / tn.total_revenue * 100, 2) AS pct_total_revenue,
    ROUND(CAST(pn.jan_total_payment AS FLOAT) / tn.total_payment * 100, 2) AS pct_total_payment
FROM product_numbers pn
CROSS JOIN total_numbers tn
ORDER BY pn.jan_total_payment DESC;


-- olhando para o segmento

WITH all_days AS (
    SELECT DISTINCT CAST(fpp.session_considered_at_localtime AS DATE) AS visit_date
    FROM fact_partners_payout fpp
),
capped_visit_cost AS (
    SELECT 
        fpp.core_partner_id,
        fpp.gympass_individual_id,
        fpp.partner_product_id,
        fpp.session_considered_at_localtime,
        fpp.transaction_cost,
        fpp.product_cap,
        CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN fpp.product_cap
            ELSE fpp.transaction_cost
        END AS capped_cost -- Paga o menor valor entre transaction_cost e product_cap
    FROM fact_partners_payout fpp
),
segment_numbers AS (
    SELECT 
        dsp.segment_type, -- Segmento do parceiro
        COUNT(*) AS jan_total_visits,
        SUM(fpp.transaction_cost) AS jan_total_revenue,
        SUM(cvc.capped_cost) AS jan_total_payment,
        ROUND(AVG(fpp.product_cap), 2) AS avg_cap, -- CAP médio por segmento
        SUM(CASE 
            WHEN fpp.transaction_cost >= fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_hit_count, -- Conta quantas vezes o CAP foi atingido
        SUM(CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_less_than_cost_count -- Conta quantas vezes o CAP era menor que o custo
    FROM fact_partners_payout fpp
    JOIN dim_store_partners dsp ON fpp.core_partner_id = dsp.core_partner_id
    LEFT JOIN capped_visit_cost cvc 
        ON fpp.core_partner_id = cvc.core_partner_id
        AND fpp.gympass_individual_id = cvc.gympass_individual_id
        AND fpp.partner_product_id = cvc.partner_product_id
        AND fpp.session_considered_at_localtime = cvc.session_considered_at_localtime
    GROUP BY dsp.segment_type
),
total_numbers AS (
    SELECT
        SUM(jan_total_visits) AS total_visits,
        SUM(jan_total_revenue) AS total_revenue,
        SUM(jan_total_payment) AS total_payment
    FROM segment_numbers
)
SELECT 
    sn.segment_type, 
    sn.jan_total_visits,
    ROUND(CAST(sn.jan_total_visits AS FLOAT) / (SELECT COUNT(*) FROM all_days), 2) AS avg_visits_per_day,
    ROUND(CAST(sn.jan_total_revenue AS FLOAT) / (SELECT COUNT(*) FROM all_days), 2) AS avg_revenue_per_day,
    sn.jan_total_payment,
    sn.avg_cap,
    sn.cap_hit_count,
    sn.cap_less_than_cost_count,
    ROUND(CAST(sn.jan_total_visits AS FLOAT) / tn.total_visits * 100, 2) AS pct_total_visits,
    ROUND(CAST(sn.jan_total_revenue AS FLOAT) / tn.total_revenue * 100, 2) AS pct_total_revenue,
    ROUND(CAST(sn.jan_total_payment AS FLOAT) / tn.total_payment * 100, 2) AS pct_total_payment
FROM segment_numbers sn
CROSS JOIN total_numbers tn
ORDER BY sn.jan_total_payment DESC;

-- analisando o transaction_type

WITH all_days AS (
    SELECT DISTINCT CAST(fpp.session_considered_at_localtime AS DATE) AS visit_date
    FROM fact_partners_payout fpp
),
capped_visit_cost AS (
    SELECT 
        fpp.core_partner_id,
        fpp.gympass_individual_id,
        fpp.partner_product_id,
        fpp.session_considered_at_localtime,
        fpp.transaction_cost,
        fpp.product_cap,
        fpp.transaction_type, -- Motivo do pagamento
        CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN fpp.product_cap
            ELSE fpp.transaction_cost
        END AS capped_cost -- Paga o menor valor entre transaction_cost e product_cap
    FROM fact_partners_payout fpp
),
transaction_type_numbers AS (
    SELECT 
        fpp.transaction_type, -- Motivo do pagamento
        COUNT(*) AS jan_total_visits,
        SUM(fpp.transaction_cost) AS jan_total_revenue,
        SUM(cvc.capped_cost) AS jan_total_payment,
        ROUND(AVG(fpp.product_cap), 2) AS avg_cap, -- CAP médio por motivo de pagamento
        SUM(CASE 
            WHEN fpp.transaction_cost >= fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_hit_count, -- Conta quantas vezes o CAP foi atingido
        SUM(CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_less_than_cost_count -- Conta quantas vezes o CAP era menor que o custo
    FROM fact_partners_payout fpp
    LEFT JOIN capped_visit_cost cvc 
        ON fpp.core_partner_id = cvc.core_partner_id
        AND fpp.gympass_individual_id = cvc.gympass_individual_id
        AND fpp.partner_product_id = cvc.partner_product_id
        AND fpp.session_considered_at_localtime = cvc.session_considered_at_localtime
    GROUP BY fpp.transaction_type
),
total_numbers AS (
    SELECT
        SUM(jan_total_visits) AS total_visits,
        SUM(jan_total_revenue) AS total_revenue,
        SUM(jan_total_payment) AS total_payment
    FROM transaction_type_numbers
)
SELECT 
    ttn.transaction_type, 
    ttn.jan_total_visits,
    ROUND(CAST(ttn.jan_total_visits AS FLOAT) / (SELECT COUNT(*) FROM all_days), 2) AS avg_visits_per_day,
    ROUND(CAST(ttn.jan_total_revenue AS FLOAT) / (SELECT COUNT(*) FROM all_days), 2) AS avg_revenue_per_day,
    ttn.jan_total_payment,
    ttn.avg_cap,
    ttn.cap_hit_count,
    ttn.cap_less_than_cost_count,
    ROUND(CAST(ttn.jan_total_visits AS FLOAT) / tn.total_visits * 100, 2) AS pct_total_visits,
    ROUND(CAST(ttn.jan_total_revenue AS FLOAT) / tn.total_revenue * 100, 2) AS pct_total_revenue,
    ROUND(CAST(ttn.jan_total_payment AS FLOAT) / tn.total_payment * 100, 2) AS pct_total_payment
FROM transaction_type_numbers ttn
CROSS JOIN total_numbers tn
ORDER BY ttn.jan_total_payment DESC;

--sessoes validas e nao validas

WITH all_days AS (
    SELECT DISTINCT CAST(fpp.session_considered_at_localtime AS DATE) AS visit_date
    FROM fact_partners_payout fpp
),
capped_visit_cost AS (
    SELECT 
        fpp.core_partner_id,
        fpp.gympass_individual_id,
        fpp.partner_product_id,
        fpp.session_considered_at_localtime,
        fpp.transaction_cost,
        fpp.product_cap,
        fpp.transaction_type, -- Motivo do pagamento
        CASE 
            WHEN fpp.transaction_type IN ('Retroactive', 'Validation') THEN 'Sessões Realizadas'
            WHEN fpp.transaction_type IN ('Late_Cancel', 'No_Show') THEN 'Sessões Não Realizadas'
            ELSE 'Outros'
        END AS session_group, -- Classifica os motivos em dois grupos
        CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN fpp.product_cap
            ELSE fpp.transaction_cost
        END AS capped_cost -- Paga o menor valor entre transaction_cost e product_cap
    FROM fact_partners_payout fpp
),
session_group_numbers AS (
    SELECT 
        cvc.session_group, -- Grupo de sessões (Realizadas ou Não Realizadas)
        COUNT(*) AS jan_total_visits,
        SUM(fpp.transaction_cost) AS jan_total_revenue,
        SUM(cvc.capped_cost) AS jan_total_payment, -- Usa o capped_cost calculado
        ROUND(AVG(fpp.product_cap), 2) AS avg_cap, -- CAP médio por grupo de sessões
        SUM(CASE 
            WHEN fpp.transaction_cost >= fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_hit_count, -- Conta quantas vezes o CAP foi atingido
        SUM(CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_less_than_cost_count -- Conta quantas vezes o CAP era menor que o custo
    FROM fact_partners_payout fpp
    LEFT JOIN capped_visit_cost cvc 
        ON fpp.core_partner_id = cvc.core_partner_id
        AND fpp.gympass_individual_id = cvc.gympass_individual_id
        AND fpp.partner_product_id = cvc.partner_product_id
        AND fpp.session_considered_at_localtime = cvc.session_considered_at_localtime
    GROUP BY cvc.session_group
),
total_numbers AS (
    SELECT
        SUM(jan_total_visits) AS total_visits,
        SUM(jan_total_revenue) AS total_revenue,
        SUM(jan_total_payment) AS total_payment
    FROM session_group_numbers
)
SELECT 
    sgn.session_group, 
    sgn.jan_total_visits,
    ROUND(CAST(sgn.jan_total_visits AS FLOAT) / (SELECT COUNT(*) FROM all_days), 2) AS avg_visits_per_day,
    ROUND(CAST(sgn.jan_total_revenue AS FLOAT) / (SELECT COUNT(*) FROM all_days), 2) AS avg_revenue_per_day,
    sgn.jan_total_payment,
    sgn.avg_cap,
    sgn.cap_hit_count,
    sgn.cap_less_than_cost_count,
    ROUND(CAST(sgn.jan_total_visits AS FLOAT) / tn.total_visits * 100, 2) AS pct_total_visits,
    ROUND(CAST(sgn.jan_total_revenue AS FLOAT) / tn.total_revenue * 100, 2) AS pct_total_revenue,
    ROUND(CAST(sgn.jan_total_payment AS FLOAT) / tn.total_payment * 100, 2) AS pct_total_payment
FROM session_group_numbers sgn
CROSS JOIN total_numbers tn
ORDER BY sgn.jan_total_payment DESC;

--Atividades e meios de pagamentos

WITH all_days AS (
    SELECT DISTINCT CAST(fpp.session_considered_at_localtime AS DATE) AS visit_date
    FROM fact_partners_payout fpp
),
capped_visit_cost AS (
    SELECT 
        fpp.core_partner_id,
        fpp.gympass_individual_id,
        fpp.partner_product_id,
        fpp.session_considered_at_localtime,
        fpp.transaction_cost,
        fpp.product_cap,
        fpp.transaction_type, -- Motivo do pagamento
        CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN fpp.product_cap
            ELSE fpp.transaction_cost
        END AS capped_cost -- Paga o menor valor entre transaction_cost e product_cap
    FROM fact_partners_payout fpp
),
activity_transaction_analysis AS (
    SELECT 
        dsp.activity_name, -- Nome da atividade (produto)
        fpp.transaction_type, -- Motivo do pagamento
        COUNT(*) AS total_visits,
        SUM(fpp.transaction_cost) AS total_revenue,
        SUM(cvc.capped_cost) AS total_payment,
        ROUND(AVG(fpp.product_cap), 2) AS avg_cap, -- CAP médio por atividade e motivo
        SUM(CASE 
            WHEN fpp.transaction_cost >= fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_hit_count, -- Conta quantas vezes o CAP foi atingido
        SUM(CASE 
            WHEN fpp.transaction_cost > fpp.product_cap THEN 1 
            ELSE 0 
        END) AS cap_less_than_cost_count -- Conta quantas vezes o CAP era menor que o custo
    FROM fact_partners_payout fpp
    JOIN dim_store_partner_products dsp ON fpp.partner_product_id = dsp.satya_partner_product_id
    LEFT JOIN capped_visit_cost cvc 
        ON fpp.core_partner_id = cvc.core_partner_id
        AND fpp.gympass_individual_id = cvc.gympass_individual_id
        AND fpp.partner_product_id = cvc.partner_product_id
        AND fpp.session_considered_at_localtime = cvc.session_considered_at_localtime
    GROUP BY dsp.activity_name, fpp.transaction_type
)
SELECT 
    ata.activity_name,
    ata.transaction_type,
    ata.total_visits,
    ROUND(CAST(ata.total_visits AS FLOAT) / (SELECT COUNT(*) FROM all_days), 2) AS avg_visits_per_day,
    ata.total_revenue,
    ata.total_payment,
    ata.avg_cap,
    ata.cap_hit_count,
    ata.cap_less_than_cost_count,
    ROUND(CAST(ata.total_visits AS FLOAT) / SUM(ata.total_visits) OVER (PARTITION BY ata.activity_name) * 100, 2) AS pct_visits_by_activity -- % de visitas por atividade
FROM activity_transaction_analysis ata
ORDER BY ata.activity_name, ata.transaction_type;

