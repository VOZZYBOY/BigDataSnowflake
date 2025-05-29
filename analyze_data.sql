-- Анализ исходных данных mock_data

-- 1. Общая статистика
SELECT 
    'Общее количество записей' as metric,
    COUNT(*) as value
FROM mock_data
UNION ALL
SELECT 
    'Уникальных покупателей',
    COUNT(DISTINCT customer_email)
FROM mock_data
UNION ALL
SELECT 
    'Уникальных продавцов',
    COUNT(DISTINCT seller_email)
FROM mock_data
UNION ALL
SELECT 
    'Уникальных товаров',
    COUNT(DISTINCT product_name)
FROM mock_data
UNION ALL
SELECT 
    'Уникальных магазинов',
    COUNT(DISTINCT store_name)
FROM mock_data;

-- 2. Анализ продаж по странам
SELECT 
    customer_country,
    COUNT(*) as sales_count,
    SUM(sale_total_price) as total_revenue,
    AVG(sale_total_price) as avg_sale_amount
FROM mock_data
WHERE customer_country IS NOT NULL
GROUP BY customer_country
ORDER BY total_revenue DESC
LIMIT 10;

-- 3. Анализ популярных категорий товаров
SELECT 
    product_category,
    COUNT(*) as sales_count,
    SUM(sale_quantity) as total_quantity,
    SUM(sale_total_price) as total_revenue,
    AVG(product_rating) as avg_rating
FROM mock_data
GROUP BY product_category
ORDER BY total_revenue DESC;

-- 4. Анализ продаж по типам питомцев
SELECT 
    customer_pet_type,
    COUNT(*) as sales_count,
    SUM(sale_total_price) as total_revenue,
    AVG(sale_total_price) as avg_sale_amount
FROM mock_data
WHERE customer_pet_type IS NOT NULL
GROUP BY customer_pet_type
ORDER BY total_revenue DESC;

-- 5. Топ продавцов по выручке
SELECT 
    seller_first_name || ' ' || seller_last_name as seller_name,
    seller_country,
    COUNT(*) as sales_count,
    SUM(sale_total_price) as total_revenue
FROM mock_data
GROUP BY seller_first_name, seller_last_name, seller_country
ORDER BY total_revenue DESC
LIMIT 10;

-- 6. Анализ временных трендов продаж
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    COUNT(*) as sales_count,
    SUM(sale_total_price) as total_revenue
FROM mock_data
WHERE sale_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
ORDER BY year, month;

-- 7. Топ товаров по рейтингу и количеству отзывов
SELECT 
    product_name,
    product_category,
    product_rating,
    product_reviews,
    COUNT(*) as sales_count
FROM mock_data
WHERE product_rating IS NOT NULL
GROUP BY product_name, product_category, product_rating, product_reviews
ORDER BY product_rating DESC, product_reviews DESC
LIMIT 10;

-- 8. Анализ качества данных
SELECT 
    'Записи без даты продажи' as data_quality_issue,
    COUNT(*) as count
FROM mock_data
WHERE sale_date IS NULL
UNION ALL
SELECT 
    'Записи без email покупателя',
    COUNT(*)
FROM mock_data
WHERE customer_email IS NULL OR customer_email = ''
UNION ALL
SELECT 
    'Записи без email продавца',
    COUNT(*)
FROM mock_data
WHERE seller_email IS NULL OR seller_email = ''
UNION ALL
SELECT 
    'Записи без страны покупателя',
    COUNT(*)
FROM mock_data
WHERE customer_country IS NULL OR customer_country = '';

-- 9. Проверка уникальности ключевых полей
SELECT 
    'Дубликаты ID' as check_type,
    COUNT(*) - COUNT(DISTINCT id) as duplicates
FROM mock_data
UNION ALL
SELECT 
    'Дубликаты customer_email + sale_date + product_name',
    COUNT(*) - COUNT(DISTINCT customer_email || sale_date || product_name)
FROM mock_data;
