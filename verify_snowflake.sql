-- Проверка результатов нормализации в модель "снежинка"

-- 1. Проверка количества записей в каждой таблице
SELECT 'dim_country' as table_name, COUNT(*) as records FROM dim_country
UNION ALL
SELECT 'dim_region', COUNT(*) FROM dim_region
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL
SELECT 'dim_brand', COUNT(*) FROM dim_brand
UNION ALL
SELECT 'dim_supplier', COUNT(*) FROM dim_supplier
UNION ALL
SELECT 'dim_product_category', COUNT(*) FROM dim_product_category
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL
SELECT 'dim_pet_type', COUNT(*) FROM dim_pet_type
UNION ALL
SELECT 'dim_pet_breed', COUNT(*) FROM dim_pet_breed
UNION ALL
SELECT 'dim_pet', COUNT(*) FROM dim_pet
UNION ALL
SELECT 'dim_time', COUNT(*) FROM dim_time
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales
UNION ALL
SELECT 'mock_data (исходная)', COUNT(*) FROM mock_data
ORDER BY table_name;

-- 2. Проверка связности данных в таблице фактов
SELECT 
    'Факты без покупателя' as issue,
    COUNT(*) as count
FROM fact_sales
WHERE customer_id IS NULL
UNION ALL
SELECT 
    'Факты без продавца',
    COUNT(*)
FROM fact_sales
WHERE seller_id IS NULL
UNION ALL
SELECT 
    'Факты без товара',
    COUNT(*)
FROM fact_sales
WHERE product_id IS NULL
UNION ALL
SELECT 
    'Факты без времени',
    COUNT(*)
FROM fact_sales
WHERE time_id IS NULL
UNION ALL
SELECT 
    'Факты без магазина',
    COUNT(*)
FROM fact_sales
WHERE store_id IS NULL;

-- 3. Сравнение сумм продаж: исходные данные vs нормализованная модель
WITH original_totals AS (
    SELECT 
        SUM(sale_total_price) as original_total,
        COUNT(*) as original_count
    FROM mock_data
),
normalized_totals AS (
    SELECT 
        SUM(total_price) as normalized_total,
        COUNT(*) as normalized_count
    FROM fact_sales
)
SELECT 
    'Оригинальная сумма' as metric,
    original_total as value
FROM original_totals
UNION ALL
SELECT 
    'Нормализованная сумма',
    normalized_total
FROM normalized_totals
UNION ALL
SELECT 
    'Разница',
    original_total - normalized_total
FROM original_totals, normalized_totals
UNION ALL
SELECT 
    'Оригинальное количество записей',
    original_count::DECIMAL
FROM original_totals
UNION ALL
SELECT 
    'Нормализованное количество записей',
    normalized_count::DECIMAL
FROM normalized_totals;

-- 4. Проверка нормализации по странам
SELECT 
    'Уникальных стран в исходных данных' as metric,
    COUNT(DISTINCT country) as value
FROM (
    SELECT customer_country as country FROM mock_data WHERE customer_country IS NOT NULL
    UNION
    SELECT seller_country FROM mock_data WHERE seller_country IS NOT NULL
    UNION
    SELECT store_country FROM mock_data WHERE store_country IS NOT NULL
    UNION
    SELECT supplier_country FROM mock_data WHERE supplier_country IS NOT NULL
) all_countries
UNION ALL
SELECT 
    'Стран в dim_country',
    COUNT(*)
FROM dim_country;

-- 5. Детальный анализ продаж по измерениям
SELECT 
    c.first_name || ' ' || c.last_name as customer,
    co.country_name as customer_country,
    s.first_name || ' ' || s.last_name as seller,
    p.product_name,
    pc.category_name as product_category,
    st.store_name,
    t.full_date as sale_date,
    fs.quantity,
    fs.total_price
FROM fact_sales fs
JOIN dim_customer c ON fs.customer_id = c.customer_id
JOIN dim_seller s ON fs.seller_id = s.seller_id
JOIN dim_product p ON fs.product_id = p.product_id
JOIN dim_product_category pc ON p.category_id = pc.category_id
JOIN dim_store st ON fs.store_id = st.store_id
JOIN dim_time t ON fs.time_id = t.time_id
LEFT JOIN dim_region cr ON c.region_id = cr.region_id
LEFT JOIN dim_country co ON cr.country_id = co.country_id
ORDER BY fs.total_price DESC
LIMIT 10;

-- 6. Проверка иерархии в модели "снежинка"
SELECT 
    co.country_name,
    COUNT(DISTINCT r.region_id) as regions_count,
    COUNT(DISTINCT c.customer_id) as customers_count,
    COUNT(DISTINCT s.seller_id) as sellers_count,
    COUNT(DISTINCT st.store_id) as stores_count
FROM dim_country co
LEFT JOIN dim_region r ON co.country_id = r.country_id
LEFT JOIN dim_customer c ON r.region_id = c.region_id
LEFT JOIN dim_seller s ON r.region_id = s.region_id
LEFT JOIN dim_store st ON r.region_id = st.region_id
GROUP BY co.country_name
ORDER BY customers_count DESC;

-- 7. Проверка измерения времени
SELECT 
    year,
    COUNT(DISTINCT month) as months_count,
    COUNT(*) as days_count,
    MIN(full_date) as first_date,
    MAX(full_date) as last_date
FROM dim_time
GROUP BY year
ORDER BY year;
