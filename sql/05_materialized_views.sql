-- sql/05_materialized_views.sql
-- Camada Analítica: Views Materializadas para Consumo Otimizado (BI / Streamlit)

-- ========================================================
-- 1. VIEW MATERIALIZADA: Matriz de Retenção de Coorte
-- ========================================================
DROP MATERIALIZED VIEW IF EXISTS mv_cohort_retention;

CREATE MATERIALIZED VIEW mv_cohort_retention AS
WITH customer_first_purchase AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(transaction_date))::date AS cohort_month
    FROM transactions
    GROUP BY customer_id
),
monthly_activity AS (
    SELECT DISTINCT
        t.customer_id,
        c.cohort_month,
        DATE_TRUNC('month', t.transaction_date)::date AS activity_month
    FROM transactions t
    JOIN customer_first_purchase c ON t.customer_id = c.customer_id
),
cohort_index AS (
    SELECT 
        customer_id,
        cohort_month,
        activity_month,
        (EXTRACT(YEAR FROM activity_month) - EXTRACT(YEAR FROM cohort_month)) * 12 +
        (EXTRACT(MONTH FROM activity_month) - EXTRACT(MONTH FROM cohort_month)) AS month_number
    FROM monthly_activity
),
cohort_sizes AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM cohort_index
    WHERE month_number = 0
    GROUP BY cohort_month
),
retention_aggregation AS (
    SELECT 
        c.cohort_month,
        c.month_number,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM cohort_index c
    GROUP BY c.cohort_month, c.month_number
)
SELECT 
    r.cohort_month,
    s.cohort_size,
    r.month_number,
    r.active_customers,
    ROUND((r.active_customers::numeric / s.cohort_size) * 100, 2) AS retention_rate_pct
FROM retention_aggregation r
JOIN cohort_sizes s ON r.cohort_month = s.cohort_month
ORDER BY r.cohort_month, r.month_number;

-- Índice único para habilitar atualizações concorrentes sem travar leituras
CREATE UNIQUE INDEX idx_mv_cohort_unique ON mv_cohort_retention (cohort_month, month_number);


-- ========================================================
-- 2. VIEW MATERIALIZADA: Segmentação RFM de Clientes
-- ========================================================
DROP MATERIALIZED VIEW IF EXISTS mv_rfm_segmentation;

CREATE MATERIALIZED VIEW mv_rfm_segmentation AS
WITH customer_aggregates AS (
    SELECT 
        customer_id,
        DATE_PART('day', '2026-09-23 00:00:00+00'::timestamptz - MAX(transaction_date)) AS recency_days,
        COUNT(transaction_id) AS frequency,
        SUM(amount) AS monetary_value
    FROM transactions
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        monetary_value,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary_value ASC) AS m_score
    FROM customer_aggregates
),
rfm_segmented AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        monetary_value,
        r_score,
        f_score,
        m_score,
        (r_score + f_score + m_score) AS total_score,
        CASE 
            WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'VIP / Campeão'
            WHEN r_score >= 3 AND f_score >= 2 THEN 'Cliente Leal'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'Em Risco de Churn'
            WHEN r_score = 1 AND f_score = 1 THEN 'Hibernando / Perdido'
            ELSE 'Potencial / Promissor'
        END AS customer_segment
    FROM rfm_scores
)
SELECT 
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary_value, 2) AS monetary_total,
    r_score,
    f_score,
    m_score,
    total_score,
    customer_segment
FROM rfm_segmented
ORDER BY total_score DESC, monetary_total DESC;

-- Índice para acelerar consultas diretas por cliente e por segmento
CREATE UNIQUE INDEX idx_mv_rfm_customer ON mv_rfm_segmentation (customer_id);
CREATE INDEX idx_mv_rfm_segment ON mv_rfm_segmentation (customer_segment);


-- ========================================================
-- 3. PROCEDURE: Rotina de Atualização Periódica
-- ========================================================
CREATE OR REPLACE PROCEDURE sp_refresh_analytics_views()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Atualiza as views de forma concorrente sem bloquear consultas ativas
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_cohort_retention;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_rfm_segmentation;
    RAISE NOTICE 'Views analíticas atualizadas com sucesso em %', clock_timestamp();
END;
$$;