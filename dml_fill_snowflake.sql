-- DML скрипт для заполнения модели данных "снежинка"

-- Заполнение измерения Стран
INSERT INTO dim_country (country_name)
SELECT DISTINCT customer_country
FROM mock_data
WHERE customer_country IS NOT NULL AND customer_country != ''
UNION
SELECT DISTINCT seller_country
FROM mock_data
WHERE seller_country IS NOT NULL AND seller_country != ''
UNION
SELECT DISTINCT store_country
FROM mock_data
WHERE store_country IS NOT NULL AND store_country != ''
UNION
SELECT DISTINCT supplier_country
FROM mock_data
WHERE supplier_country IS NOT NULL AND supplier_country != ''
ON CONFLICT (country_name) DO NOTHING;

-- Заполнение измерения Регионов
INSERT INTO dim_region (state, city, postal_code, country_id)
SELECT DISTINCT 
    COALESCE(md.customer_state, md.store_state) as state,
    COALESCE(md.customer_city, md.store_city, md.supplier_city) as city,
    COALESCE(md.customer_postal_code, md.seller_postal_code) as postal_code,
    dc.country_id
FROM mock_data md
LEFT JOIN dim_country dc ON dc.country_name = COALESCE(md.customer_country, md.seller_country, md.store_country, md.supplier_country)
WHERE (md.customer_country IS NOT NULL OR md.seller_country IS NOT NULL OR md.store_country IS NOT NULL OR md.supplier_country IS NOT NULL);

-- Заполнение измерения Брендов
INSERT INTO dim_brand (brand_name)
SELECT DISTINCT product_brand
FROM mock_data
WHERE product_brand IS NOT NULL AND product_brand != ''
ON CONFLICT (brand_name) DO NOTHING;

-- Заполнение измерения Категорий товаров
INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category IS NOT NULL AND product_category != ''
ON CONFLICT (category_name) DO NOTHING;

-- Заполнение измерения Типов питомцев
INSERT INTO dim_pet_type (pet_type_name)
SELECT DISTINCT customer_pet_type
FROM mock_data
WHERE customer_pet_type IS NOT NULL AND customer_pet_type != ''
ON CONFLICT (pet_type_name) DO NOTHING;

-- Заполнение измерения Пород питомцев
INSERT INTO dim_pet_breed (breed_name)
SELECT DISTINCT customer_pet_breed
FROM mock_data
WHERE customer_pet_breed IS NOT NULL AND customer_pet_breed != ''
ON CONFLICT (breed_name) DO NOTHING;

-- Заполнение измерения Покупателей
INSERT INTO dim_customer (first_name, last_name, age, email, region_id)
SELECT DISTINCT 
    md.customer_first_name,
    md.customer_last_name,
    md.customer_age,
    md.customer_email,
    dr.region_id
FROM mock_data md
LEFT JOIN dim_country dc ON dc.country_name = md.customer_country
LEFT JOIN dim_region dr ON dr.country_id = dc.country_id 
    AND dr.postal_code = md.customer_postal_code;

-- Заполнение измерения Продавцов
INSERT INTO dim_seller (first_name, last_name, email, region_id)
SELECT DISTINCT 
    md.seller_first_name,
    md.seller_last_name,
    md.seller_email,
    dr.region_id
FROM mock_data md
LEFT JOIN dim_country dc ON dc.country_name = md.seller_country
LEFT JOIN dim_region dr ON dr.country_id = dc.country_id 
    AND dr.postal_code = md.seller_postal_code;

-- Заполнение измерения Поставщиков
INSERT INTO dim_supplier (supplier_name, contact_person, email, phone, address, region_id)
SELECT DISTINCT 
    md.supplier_name,
    md.supplier_contact,
    md.supplier_email,
    md.supplier_phone,
    md.supplier_address,
    dr.region_id
FROM mock_data md
LEFT JOIN dim_country dc ON dc.country_name = md.supplier_country
LEFT JOIN dim_region dr ON dr.country_id = dc.country_id 
    AND dr.city = md.supplier_city;

-- Заполнение измерения Товаров
INSERT INTO dim_product (product_name, category_id, brand_id, supplier_id, price, weight, color, size, material, description, rating, reviews, release_date, expiry_date)
SELECT DISTINCT 
    md.product_name,
    dpc.category_id,
    db.brand_id,
    ds.supplier_id,
    md.product_price,
    md.product_weight,
    md.product_color,
    md.product_size,
    md.product_material,
    md.product_description,
    md.product_rating,
    md.product_reviews,
    md.product_release_date,
    md.product_expiry_date
FROM mock_data md
LEFT JOIN dim_product_category dpc ON dpc.category_name = md.product_category
LEFT JOIN dim_brand db ON db.brand_name = md.product_brand
LEFT JOIN dim_supplier ds ON ds.supplier_name = md.supplier_name;

-- Заполнение измерения Магазинов
INSERT INTO dim_store (store_name, location, phone, email, region_id)
SELECT DISTINCT 
    md.store_name,
    md.store_location,
    md.store_phone,
    md.store_email,
    dr.region_id
FROM mock_data md
LEFT JOIN dim_country dc ON dc.country_name = md.store_country
LEFT JOIN dim_region dr ON dr.country_id = dc.country_id 
    AND dr.city = md.store_city;

-- Заполнение измерения Питомцев
INSERT INTO dim_pet (pet_name, pet_type_id, breed_id, customer_id)
SELECT DISTINCT 
    md.customer_pet_name,
    dpt.pet_type_id,
    dpb.breed_id,
    dc.customer_id
FROM mock_data md
LEFT JOIN dim_pet_type dpt ON dpt.pet_type_name = md.customer_pet_type
LEFT JOIN dim_pet_breed dpb ON dpb.breed_name = md.customer_pet_breed
LEFT JOIN dim_customer dc ON dc.email = md.customer_email;

-- Заполнение измерения Времени
INSERT INTO dim_time (full_date, year, quarter, month, month_name, day, day_of_week, day_name, week_of_year)
SELECT DISTINCT 
    sale_date,
    EXTRACT(YEAR FROM sale_date),
    EXTRACT(QUARTER FROM sale_date),
    EXTRACT(MONTH FROM sale_date),
    TO_CHAR(sale_date, 'Month'),
    EXTRACT(DAY FROM sale_date),
    EXTRACT(DOW FROM sale_date),
    TO_CHAR(sale_date, 'Day'),
    EXTRACT(WEEK FROM sale_date)
FROM mock_data
WHERE sale_date IS NOT NULL
ON CONFLICT (full_date) DO NOTHING;

-- Заполнение таблицы фактов Продаж
INSERT INTO fact_sales (time_id, customer_id, seller_id, product_id, store_id, quantity, unit_price, total_price, original_sale_id)
SELECT 
    dt.time_id,
    dc.customer_id,
    ds.seller_id,
    dp.product_id,
    dst.store_id,
    md.sale_quantity,
    md.product_price,
    md.sale_total_price,
    md.id
FROM mock_data md
LEFT JOIN dim_time dt ON dt.full_date = md.sale_date
LEFT JOIN dim_customer dc ON dc.email = md.customer_email
LEFT JOIN dim_seller ds ON ds.email = md.seller_email
LEFT JOIN dim_product dp ON dp.product_name = md.product_name
LEFT JOIN dim_store dst ON dst.store_name = md.store_name;
