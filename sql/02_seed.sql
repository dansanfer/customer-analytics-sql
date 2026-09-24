INSERT INTO customers (customer_name, signup_date)
SELECT 
    'Cliente ' || i,
    '2026-01-01 09:00:00+00'::timestamptz + (random() * (interval '60 days'))
FROM generate_series(1, 50) s(i);

INSERT INTO transactions (customer_id, amount, transaction_date)
SELECT 
    c.customer_id,
    ROUND((25 + random() * 475)::numeric, 2) AS amount,
    c.signup_date + (interval '1 day' * floor(random() * 200)) AS transaction_date
FROM customers c
CROSS JOIN generate_series(1, 8) g
WHERE (c.signup_date + (interval '1 day' * floor(random() * 200))) <= '2026-09-23 00:00:00+00';