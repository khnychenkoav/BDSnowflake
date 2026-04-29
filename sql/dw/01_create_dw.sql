DROP SCHEMA IF EXISTS dw CASCADE;
CREATE SCHEMA dw;

CREATE TABLE dw.dim_country (
    country_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_name text NOT NULL UNIQUE
);

CREATE TABLE dw.dim_date (
    date_key integer PRIMARY KEY,
    full_date date NOT NULL UNIQUE,
    year smallint NOT NULL,
    quarter smallint NOT NULL,
    month smallint NOT NULL,
    month_name text NOT NULL,
    day_of_month smallint NOT NULL,
    day_of_week smallint NOT NULL,
    day_name text NOT NULL,
    week_of_year smallint NOT NULL
);

CREATE TABLE dw.dim_product_category (
    product_category_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_category_name text NOT NULL UNIQUE
);

CREATE TABLE dw.dim_product_brand (
    product_brand_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_brand_name text NOT NULL UNIQUE
);

CREATE TABLE dw.dim_product_material (
    product_material_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_material_name text NOT NULL UNIQUE
);

CREATE TABLE dw.dim_product_color (
    product_color_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_color_name text NOT NULL UNIQUE
);

CREATE TABLE dw.dim_product_size (
    product_size_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_size_name text NOT NULL UNIQUE
);

CREATE TABLE dw.dim_pet_type (
    pet_type_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pet_type_name text NOT NULL UNIQUE
);

CREATE TABLE dw.dim_pet_breed (
    pet_breed_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pet_breed_name text NOT NULL UNIQUE
);

CREATE TABLE dw.dim_pet_category (
    pet_category_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pet_category_name text NOT NULL UNIQUE
);

CREATE TABLE dw.dim_customer (
    customer_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_customer_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    age integer NOT NULL CHECK (age BETWEEN 0 AND 130),
    email text NOT NULL UNIQUE,
    country_key integer NOT NULL REFERENCES dw.dim_country (country_key),
    postal_code text
);

CREATE TABLE dw.dim_seller (
    seller_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_seller_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL UNIQUE,
    country_key integer NOT NULL REFERENCES dw.dim_country (country_key),
    postal_code text
);

CREATE TABLE dw.dim_store (
    store_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    store_name text NOT NULL,
    store_location text NOT NULL,
    city text NOT NULL,
    state text,
    country_key integer NOT NULL REFERENCES dw.dim_country (country_key),
    phone text NOT NULL,
    email text NOT NULL UNIQUE
);

CREATE TABLE dw.dim_supplier (
    supplier_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_name text NOT NULL,
    contact_name text NOT NULL,
    email text NOT NULL UNIQUE,
    phone text NOT NULL,
    address text NOT NULL,
    city text NOT NULL,
    country_key integer NOT NULL REFERENCES dw.dim_country (country_key)
);

CREATE TABLE dw.dim_pet (
    pet_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pet_nk_hash char(32) NOT NULL UNIQUE,
    pet_name text NOT NULL,
    pet_type_key integer NOT NULL REFERENCES dw.dim_pet_type (pet_type_key),
    pet_breed_key integer NOT NULL REFERENCES dw.dim_pet_breed (pet_breed_key),
    pet_category_key integer NOT NULL REFERENCES dw.dim_pet_category (pet_category_key)
);

CREATE TABLE dw.dim_product (
    product_key integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_nk_hash char(32) NOT NULL UNIQUE,
    source_product_id integer NOT NULL,
    product_name text NOT NULL,
    product_category_key integer NOT NULL REFERENCES dw.dim_product_category (product_category_key),
    product_brand_key integer NOT NULL REFERENCES dw.dim_product_brand (product_brand_key),
    product_material_key integer NOT NULL REFERENCES dw.dim_product_material (product_material_key),
    product_color_key integer NOT NULL REFERENCES dw.dim_product_color (product_color_key),
    product_size_key integer NOT NULL REFERENCES dw.dim_product_size (product_size_key),
    product_weight numeric(10, 2) NOT NULL CHECK (product_weight > 0),
    product_description text NOT NULL,
    product_rating numeric(3, 1) NOT NULL CHECK (product_rating BETWEEN 0 AND 5),
    product_reviews integer NOT NULL CHECK (product_reviews >= 0),
    release_date_key integer NOT NULL REFERENCES dw.dim_date (date_key),
    expiry_date_key integer NOT NULL REFERENCES dw.dim_date (date_key),
    CHECK (expiry_date_key > release_date_key)
);

CREATE TABLE dw.fact_sales (
    sale_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_row_id bigint NOT NULL UNIQUE REFERENCES stage.mock_data_raw (raw_id),
    source_file text NOT NULL,
    source_id integer NOT NULL,
    source_customer_id integer NOT NULL,
    source_seller_id integer NOT NULL,
    source_product_id integer NOT NULL,
    sale_date_key integer NOT NULL REFERENCES dw.dim_date (date_key),
    customer_key integer NOT NULL REFERENCES dw.dim_customer (customer_key),
    seller_key integer NOT NULL REFERENCES dw.dim_seller (seller_key),
    product_key integer NOT NULL REFERENCES dw.dim_product (product_key),
    store_key integer NOT NULL REFERENCES dw.dim_store (store_key),
    supplier_key integer NOT NULL REFERENCES dw.dim_supplier (supplier_key),
    pet_key integer NOT NULL REFERENCES dw.dim_pet (pet_key),
    sale_quantity integer NOT NULL CHECK (sale_quantity > 0),
    source_product_quantity integer NOT NULL CHECK (source_product_quantity >= 0),
    product_unit_price numeric(12, 2) NOT NULL CHECK (product_unit_price >= 0),
    source_sale_total_amount numeric(14, 2) NOT NULL CHECK (source_sale_total_amount >= 0),
    calculated_total_amount numeric(14, 2) NOT NULL CHECK (calculated_total_amount >= 0),
    is_total_consistent boolean NOT NULL
);

CREATE INDEX ix_fact_sales_sale_date ON dw.fact_sales (sale_date_key);
CREATE INDEX ix_fact_sales_customer ON dw.fact_sales (customer_key);
CREATE INDEX ix_fact_sales_seller ON dw.fact_sales (seller_key);
CREATE INDEX ix_fact_sales_product ON dw.fact_sales (product_key);
CREATE INDEX ix_fact_sales_store ON dw.fact_sales (store_key);
CREATE INDEX ix_fact_sales_supplier ON dw.fact_sales (supplier_key);
CREATE INDEX ix_dim_customer_country ON dw.dim_customer (country_key);
CREATE INDEX ix_dim_seller_country ON dw.dim_seller (country_key);
CREATE INDEX ix_dim_store_country ON dw.dim_store (country_key);
CREATE INDEX ix_dim_supplier_country ON dw.dim_supplier (country_key);
