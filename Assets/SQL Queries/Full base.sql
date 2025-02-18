SELECT 
    fpp.*, -- Todas as colunas da tabela fact_partners_payout
    dsp.partner_trade_name,
    dsp.address,
    dsp.contact_number,
    dsp.segment_type AS partner_segment, -- Segmento do parceiro
    dsp.country,
    dspp.activity_name,
    dspp.product_cost_per_usage,
    dspp.product_cap_value,
    dspp.segment_type AS product_segment, -- Segmento do produto
    dspp.last_price_update,
    CASE 
        WHEN fpp.transaction_type IN ('Retroactive', 'Validation') THEN 'Sessão Realizada'
        WHEN fpp.transaction_type IN ('Late_Cancel', 'No_Show') THEN 'Sessão não Realizada'
        ELSE 'Outros'
    END AS session_group, -- Classifica os motivos em dois grupos
    CASE 
        WHEN fpp.transaction_cost > fpp.product_cap THEN fpp.product_cap
        ELSE fpp.transaction_cost
    END AS capped_cost, -- Paga o menor valor entre transaction_cost e product_cap
    CASE 
        WHEN fpp.transaction_cost >= fpp.product_cap THEN 1 
        ELSE 0 
    END AS cap_hit_flag, -- Flag para indicar se o CAP foi atingido (0 ou 1)
    CASE 
        WHEN fpp.transaction_cost > fpp.product_cap THEN 1 
        ELSE 0 
    END AS cap_less_than_cost_flag -- Flag para indicar se o CAP era menor que o custo (0 ou 1)
FROM fact_partners_payout fpp
LEFT JOIN dim_store_partners dsp 
    ON fpp.core_partner_id = dsp.core_partner_id
LEFT JOIN dim_store_partner_products dspp 
    ON fpp.partner_product_id = dspp.satya_partner_product_id
ORDER BY fpp.transaction_cost DESC; -- Exemplo de ordenação