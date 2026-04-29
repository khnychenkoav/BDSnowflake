SELECT
    d.year,
    d.month,
    count(*) AS sales_count,
    sum(f.source_sale_total_amount) AS source_revenue,
    sum(f.calculated_total_amount) AS calculated_revenue,
    sum(f.calculated_total_amount - f.source_sale_total_amount) AS revenue_delta
FROM dw.fact_sales f
JOIN dw.dim_date d ON d.date_key = f.sale_date_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

SELECT
    product_category_name,
    count(*) AS sales_count,
    sum(source_sale_total_amount) AS source_revenue,
    round(avg(product_unit_price), 2) AS avg_unit_price
FROM dw.v_sales_enriched
GROUP BY product_category_name
ORDER BY source_revenue DESC;

SELECT
    st.store_name,
    co.country_name AS store_country,
    count(*) AS sales_count,
    sum(f.source_sale_total_amount) AS source_revenue
FROM dw.fact_sales f
JOIN dw.dim_store st ON st.store_key = f.store_key
JOIN dw.dim_country co ON co.country_key = st.country_key
GROUP BY st.store_name, co.country_name
ORDER BY source_revenue DESC
LIMIT 20;

SELECT
    source_file,
    count(*) AS rows_count,
    count(*) FILTER (WHERE is_total_consistent) AS consistent_total_rows,
    count(*) FILTER (WHERE NOT is_total_consistent) AS inconsistent_total_rows,
    min(source_sale_total_amount) AS min_source_total,
    max(source_sale_total_amount) AS max_source_total
FROM dw.fact_sales
GROUP BY source_file
ORDER BY source_file;
