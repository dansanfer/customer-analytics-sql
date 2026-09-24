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