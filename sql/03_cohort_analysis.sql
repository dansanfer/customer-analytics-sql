-- sql/03_cohort_analysis.sql
-- Análise de Retenção de Clientes por Mês de Aquisição (Coorte)

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