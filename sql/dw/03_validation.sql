SELECT 'stage.mock_data_raw' AS object_name, count(*) AS rows_count
FROM stage.mock_data_raw
UNION ALL SELECT 'dw.fact_sales', count(*) FROM dw.fact_sales
UNION ALL SELECT 'dw.dim_customer', count(*) FROM dw.dim_customer
UNION ALL SELECT 'dw.dim_seller', count(*) FROM dw.dim_seller
UNION ALL SELECT 'dw.dim_product', count(*) FROM dw.dim_product
UNION ALL SELECT 'dw.dim_store', count(*) FROM dw.dim_store
UNION ALL SELECT 'dw.dim_supplier', count(*) FROM dw.dim_supplier
UNION ALL SELECT 'dw.dim_pet', count(*) FROM dw.dim_pet
UNION ALL SELECT 'dw.dim_country', count(*) FROM dw.dim_country
UNION ALL SELECT 'dw.dim_date', count(*) FROM dw.dim_date
ORDER BY object_name;

SELECT source_file, count(*) AS rows_count
FROM stage.mock_data_raw
GROUP BY source_file
ORDER BY source_file;

SELECT *
FROM dw.v_sales_quality_summary;

SELECT
    count(*) FILTER (WHERE c.customer_key IS NULL) AS missing_customer_fk,
    count(*) FILTER (WHERE se.seller_key IS NULL) AS missing_seller_fk,
    count(*) FILTER (WHERE p.product_key IS NULL) AS missing_product_fk,
    count(*) FILTER (WHERE st.store_key IS NULL) AS missing_store_fk,
    count(*) FILTER (WHERE sup.supplier_key IS NULL) AS missing_supplier_fk,
    count(*) FILTER (WHERE pet.pet_key IS NULL) AS missing_pet_fk
FROM dw.fact_sales f
LEFT JOIN dw.dim_customer c ON c.customer_key = f.customer_key
LEFT JOIN dw.dim_seller se ON se.seller_key = f.seller_key
LEFT JOIN dw.dim_product p ON p.product_key = f.product_key
LEFT JOIN dw.dim_store st ON st.store_key = f.store_key
LEFT JOIN dw.dim_supplier sup ON sup.supplier_key = f.supplier_key
LEFT JOIN dw.dim_pet pet ON pet.pet_key = f.pet_key;

SELECT
    product_category_name,
    count(*) AS sales_count,
    sum(source_sale_total_amount) AS source_revenue,
    sum(calculated_total_amount) AS calculated_revenue
FROM dw.v_sales_enriched
GROUP BY product_category_name
ORDER BY source_revenue DESC;
