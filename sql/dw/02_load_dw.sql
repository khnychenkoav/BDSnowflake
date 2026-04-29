BEGIN;

INSERT INTO dw.dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name FROM stage.v_mock_data_typed
    UNION
    SELECT seller_country FROM stage.v_mock_data_typed
    UNION
    SELECT store_country FROM stage.v_mock_data_typed
    UNION
    SELECT supplier_country FROM stage.v_mock_data_typed
) countries
WHERE country_name IS NOT NULL
ORDER BY country_name;

INSERT INTO dw.dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day_of_month,
    day_of_week,
    day_name,
    week_of_year
)
SELECT
    to_char(full_date, 'YYYYMMDD')::integer AS date_key,
    full_date,
    extract(year FROM full_date)::smallint AS year,
    extract(quarter FROM full_date)::smallint AS quarter,
    extract(month FROM full_date)::smallint AS month,
    trim(to_char(full_date, 'Month')) AS month_name,
    extract(day FROM full_date)::smallint AS day_of_month,
    extract(isodow FROM full_date)::smallint AS day_of_week,
    trim(to_char(full_date, 'Day')) AS day_name,
    extract(week FROM full_date)::smallint AS week_of_year
FROM (
    SELECT sale_date AS full_date FROM stage.v_mock_data_typed
    UNION
    SELECT product_release_date FROM stage.v_mock_data_typed
    UNION
    SELECT product_expiry_date FROM stage.v_mock_data_typed
) dates
WHERE full_date IS NOT NULL
ORDER BY full_date;

INSERT INTO dw.dim_product_category (product_category_name)
SELECT DISTINCT product_category
FROM stage.v_mock_data_typed
WHERE product_category IS NOT NULL
ORDER BY product_category;

INSERT INTO dw.dim_product_brand (product_brand_name)
SELECT DISTINCT product_brand
FROM stage.v_mock_data_typed
WHERE product_brand IS NOT NULL
ORDER BY product_brand;

INSERT INTO dw.dim_product_material (product_material_name)
SELECT DISTINCT product_material
FROM stage.v_mock_data_typed
WHERE product_material IS NOT NULL
ORDER BY product_material;

INSERT INTO dw.dim_product_color (product_color_name)
SELECT DISTINCT product_color
FROM stage.v_mock_data_typed
WHERE product_color IS NOT NULL
ORDER BY product_color;

INSERT INTO dw.dim_product_size (product_size_name)
SELECT DISTINCT product_size
FROM stage.v_mock_data_typed
WHERE product_size IS NOT NULL
ORDER BY product_size;

INSERT INTO dw.dim_pet_type (pet_type_name)
SELECT DISTINCT customer_pet_type
FROM stage.v_mock_data_typed
WHERE customer_pet_type IS NOT NULL
ORDER BY customer_pet_type;

INSERT INTO dw.dim_pet_breed (pet_breed_name)
SELECT DISTINCT customer_pet_breed
FROM stage.v_mock_data_typed
WHERE customer_pet_breed IS NOT NULL
ORDER BY customer_pet_breed;

INSERT INTO dw.dim_pet_category (pet_category_name)
SELECT DISTINCT pet_category
FROM stage.v_mock_data_typed
WHERE pet_category IS NOT NULL
ORDER BY pet_category;

INSERT INTO dw.dim_customer (
    source_customer_id,
    first_name,
    last_name,
    age,
    email,
    country_key,
    postal_code
)
SELECT
    s.sale_customer_id,
    s.customer_first_name,
    s.customer_last_name,
    s.customer_age,
    s.customer_email,
    c.country_key,
    s.customer_postal_code
FROM (
    SELECT DISTINCT ON (customer_email)
        sale_customer_id,
        customer_first_name,
        customer_last_name,
        customer_age,
        customer_email,
        customer_country,
        customer_postal_code,
        raw_id
    FROM stage.v_mock_data_typed
    WHERE customer_email IS NOT NULL
    ORDER BY customer_email, raw_id
) s
JOIN dw.dim_country c ON c.country_name = s.customer_country
ORDER BY s.customer_email;

INSERT INTO dw.dim_seller (
    source_seller_id,
    first_name,
    last_name,
    email,
    country_key,
    postal_code
)
SELECT
    s.sale_seller_id,
    s.seller_first_name,
    s.seller_last_name,
    s.seller_email,
    c.country_key,
    s.seller_postal_code
FROM (
    SELECT DISTINCT ON (seller_email)
        sale_seller_id,
        seller_first_name,
        seller_last_name,
        seller_email,
        seller_country,
        seller_postal_code,
        raw_id
    FROM stage.v_mock_data_typed
    WHERE seller_email IS NOT NULL
    ORDER BY seller_email, raw_id
) s
JOIN dw.dim_country c ON c.country_name = s.seller_country
ORDER BY s.seller_email;

INSERT INTO dw.dim_store (
    store_name,
    store_location,
    city,
    state,
    country_key,
    phone,
    email
)
SELECT
    s.store_name,
    s.store_location,
    s.store_city,
    s.store_state,
    c.country_key,
    s.store_phone,
    s.store_email
FROM (
    SELECT DISTINCT ON (store_email)
        store_name,
        store_location,
        store_city,
        store_state,
        store_country,
        store_phone,
        store_email,
        raw_id
    FROM stage.v_mock_data_typed
    WHERE store_email IS NOT NULL
    ORDER BY store_email, raw_id
) s
JOIN dw.dim_country c ON c.country_name = s.store_country
ORDER BY s.store_email;

INSERT INTO dw.dim_supplier (
    supplier_name,
    contact_name,
    email,
    phone,
    address,
    city,
    country_key
)
SELECT
    s.supplier_name,
    s.supplier_contact,
    s.supplier_email,
    s.supplier_phone,
    s.supplier_address,
    s.supplier_city,
    c.country_key
FROM (
    SELECT DISTINCT ON (supplier_email)
        supplier_name,
        supplier_contact,
        supplier_email,
        supplier_phone,
        supplier_address,
        supplier_city,
        supplier_country,
        raw_id
    FROM stage.v_mock_data_typed
    WHERE supplier_email IS NOT NULL
    ORDER BY supplier_email, raw_id
) s
JOIN dw.dim_country c ON c.country_name = s.supplier_country
ORDER BY s.supplier_email;

INSERT INTO dw.dim_pet (
    pet_nk_hash,
    pet_name,
    pet_type_key,
    pet_breed_key,
    pet_category_key
)
SELECT
    s.pet_nk_hash,
    s.customer_pet_name,
    pt.pet_type_key,
    pb.pet_breed_key,
    pc.pet_category_key
FROM (
    SELECT DISTINCT ON (pet_nk_hash)
        pet_nk_hash,
        customer_pet_name,
        customer_pet_type,
        customer_pet_breed,
        pet_category,
        raw_id
    FROM stage.v_mock_data_typed
    WHERE pet_nk_hash IS NOT NULL
    ORDER BY pet_nk_hash, raw_id
) s
JOIN dw.dim_pet_type pt ON pt.pet_type_name = s.customer_pet_type
JOIN dw.dim_pet_breed pb ON pb.pet_breed_name = s.customer_pet_breed
JOIN dw.dim_pet_category pc ON pc.pet_category_name = s.pet_category
ORDER BY s.pet_nk_hash;

INSERT INTO dw.dim_product (
    product_nk_hash,
    source_product_id,
    product_name,
    product_category_key,
    product_brand_key,
    product_material_key,
    product_color_key,
    product_size_key,
    product_weight,
    product_description,
    product_rating,
    product_reviews,
    release_date_key,
    expiry_date_key
)
SELECT
    s.product_nk_hash,
    s.sale_product_id,
    s.product_name,
    pc.product_category_key,
    pb.product_brand_key,
    pm.product_material_key,
    pcol.product_color_key,
    ps.product_size_key,
    s.product_weight,
    s.product_description,
    s.product_rating,
    s.product_reviews,
    to_char(s.product_release_date, 'YYYYMMDD')::integer,
    to_char(s.product_expiry_date, 'YYYYMMDD')::integer
FROM (
    SELECT DISTINCT ON (product_nk_hash)
        product_nk_hash,
        sale_product_id,
        product_name,
        product_category,
        product_brand,
        product_material,
        product_color,
        product_size,
        product_weight,
        product_description,
        product_rating,
        product_reviews,
        product_release_date,
        product_expiry_date,
        raw_id
    FROM stage.v_mock_data_typed
    WHERE product_nk_hash IS NOT NULL
    ORDER BY product_nk_hash, raw_id
) s
JOIN dw.dim_product_category pc ON pc.product_category_name = s.product_category
JOIN dw.dim_product_brand pb ON pb.product_brand_name = s.product_brand
JOIN dw.dim_product_material pm ON pm.product_material_name = s.product_material
JOIN dw.dim_product_color pcol ON pcol.product_color_name = s.product_color
JOIN dw.dim_product_size ps ON ps.product_size_name = s.product_size
ORDER BY s.product_nk_hash;

INSERT INTO dw.fact_sales (
    source_row_id,
    source_file,
    source_id,
    source_customer_id,
    source_seller_id,
    source_product_id,
    sale_date_key,
    customer_key,
    seller_key,
    product_key,
    store_key,
    supplier_key,
    pet_key,
    sale_quantity,
    source_product_quantity,
    product_unit_price,
    source_sale_total_amount,
    calculated_total_amount,
    is_total_consistent
)
SELECT
    s.raw_id,
    s.source_file,
    s.source_id,
    s.sale_customer_id,
    s.sale_seller_id,
    s.sale_product_id,
    to_char(s.sale_date, 'YYYYMMDD')::integer,
    c.customer_key,
    se.seller_key,
    p.product_key,
    st.store_key,
    sup.supplier_key,
    pet.pet_key,
    s.sale_quantity,
    s.product_quantity,
    s.product_price,
    s.sale_total_price,
    round(s.product_price * s.sale_quantity, 2),
    round(s.product_price * s.sale_quantity, 2) = s.sale_total_price
FROM stage.v_mock_data_typed s
JOIN dw.dim_customer c ON c.email = s.customer_email
JOIN dw.dim_seller se ON se.email = s.seller_email
JOIN dw.dim_product p ON p.product_nk_hash = s.product_nk_hash
JOIN dw.dim_store st ON st.email = s.store_email
JOIN dw.dim_supplier sup ON sup.email = s.supplier_email
JOIN dw.dim_pet pet ON pet.pet_nk_hash = s.pet_nk_hash
ORDER BY s.raw_id;

CREATE OR REPLACE VIEW dw.v_sales_quality_summary AS
SELECT
    count(*) AS fact_rows,
    count(DISTINCT source_file) AS source_files,
    count(*) FILTER (WHERE NOT is_total_consistent) AS inconsistent_total_rows,
    min(source_sale_total_amount) AS min_source_sale_total,
    max(source_sale_total_amount) AS max_source_sale_total,
    min(calculated_total_amount) AS min_calculated_total,
    max(calculated_total_amount) AS max_calculated_total
FROM dw.fact_sales;

CREATE OR REPLACE VIEW dw.v_sales_enriched AS
SELECT
    f.sale_key,
    d.full_date AS sale_date,
    f.source_file,
    c.email AS customer_email,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    seller.email AS seller_email,
    p.product_name,
    pc.product_category_name,
    b.product_brand_name,
    st.store_name,
    sup.supplier_name,
    pet.pet_name,
    f.sale_quantity,
    f.product_unit_price,
    f.source_sale_total_amount,
    f.calculated_total_amount,
    f.is_total_consistent
FROM dw.fact_sales f
JOIN dw.dim_date d ON d.date_key = f.sale_date_key
JOIN dw.dim_customer c ON c.customer_key = f.customer_key
JOIN dw.dim_seller seller ON seller.seller_key = f.seller_key
JOIN dw.dim_product p ON p.product_key = f.product_key
JOIN dw.dim_product_category pc ON pc.product_category_key = p.product_category_key
JOIN dw.dim_product_brand b ON b.product_brand_key = p.product_brand_key
JOIN dw.dim_store st ON st.store_key = f.store_key
JOIN dw.dim_supplier sup ON sup.supplier_key = f.supplier_key
JOIN dw.dim_pet pet ON pet.pet_key = f.pet_key;

ANALYZE dw.dim_country;
ANALYZE dw.dim_date;
ANALYZE dw.dim_product_category;
ANALYZE dw.dim_product_brand;
ANALYZE dw.dim_product_material;
ANALYZE dw.dim_product_color;
ANALYZE dw.dim_product_size;
ANALYZE dw.dim_pet_type;
ANALYZE dw.dim_pet_breed;
ANALYZE dw.dim_pet_category;
ANALYZE dw.dim_customer;
ANALYZE dw.dim_seller;
ANALYZE dw.dim_store;
ANALYZE dw.dim_supplier;
ANALYZE dw.dim_pet;
ANALYZE dw.dim_product;
ANALYZE dw.fact_sales;

COMMIT;
