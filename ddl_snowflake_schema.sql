-- DDL скрипт для создания модели данных "снежинка"

-- Измерения (Dimensions)

-- Измерение Страны
CREATE TABLE dim_country (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE NOT NULL
);

-- Измерение Регионов
CREATE TABLE dim_region (
    region_id SERIAL PRIMARY KEY,
    state VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country_id INTEGER REFERENCES dim_country(country_id)
);

-- Измерение Покупателей
CREATE TABLE dim_customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INTEGER,
    email VARCHAR(200),
    region_id INTEGER REFERENCES dim_region(region_id)
);

-- Измерение Продавцов
CREATE TABLE dim_seller (
    seller_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    region_id INTEGER REFERENCES dim_region(region_id)
);

-- Измерение Брендов
CREATE TABLE dim_brand (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) UNIQUE NOT NULL
);

-- Измерение Поставщиков
CREATE TABLE dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100),
    contact_person VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(20),
    address VARCHAR(200),
    region_id INTEGER REFERENCES dim_region(region_id)
);

-- Измерение Категорий товаров
CREATE TABLE dim_product_category (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
);

-- Измерение Товаров
CREATE TABLE dim_product (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200),
    category_id INTEGER REFERENCES dim_product_category(category_id),
    brand_id INTEGER REFERENCES dim_brand(brand_id),
    supplier_id INTEGER REFERENCES dim_supplier(supplier_id),
    price DECIMAL(10,2),
    weight DECIMAL(10,2),
    color VARCHAR(50),
    size VARCHAR(20),
    material VARCHAR(100),
    description TEXT,
    rating DECIMAL(3,2),
    reviews INTEGER,
    release_date DATE,
    expiry_date DATE
);

-- Измерение Магазинов
CREATE TABLE dim_store (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(100),
    location VARCHAR(200),
    phone VARCHAR(20),
    email VARCHAR(200),
    region_id INTEGER REFERENCES dim_region(region_id)
);

-- Измерение Питомцев
CREATE TABLE dim_pet_breed (
    breed_id SERIAL PRIMARY KEY,
    breed_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE dim_pet_type (
    pet_type_id SERIAL PRIMARY KEY,
    pet_type_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE dim_pet (
    pet_id SERIAL PRIMARY KEY,
    pet_name VARCHAR(100),
    pet_type_id INTEGER REFERENCES dim_pet_type(pet_type_id),
    breed_id INTEGER REFERENCES dim_pet_breed(breed_id),
    customer_id INTEGER REFERENCES dim_customer(customer_id)
);

-- Измерение Времени
CREATE TABLE dim_time (
    time_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    month_name VARCHAR(20),
    day INTEGER,
    day_of_week INTEGER,
    day_name VARCHAR(20),
    week_of_year INTEGER
);

-- Таблица фактов - Продажи
CREATE TABLE fact_sales (
    sale_fact_id SERIAL PRIMARY KEY,
    time_id INTEGER REFERENCES dim_time(time_id),
    customer_id INTEGER REFERENCES dim_customer(customer_id),
    seller_id INTEGER REFERENCES dim_seller(seller_id),
    product_id INTEGER REFERENCES dim_product(product_id),
    store_id INTEGER REFERENCES dim_store(store_id),
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    original_sale_id INTEGER -- ссылка на исходную запись
);

-- Индексы для оптимизации запросов
CREATE INDEX idx_fact_sales_time ON fact_sales(time_id);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_id);
CREATE INDEX idx_fact_sales_seller ON fact_sales(seller_id);
CREATE INDEX idx_fact_sales_product ON fact_sales(product_id);
CREATE INDEX idx_fact_sales_store ON fact_sales(store_id);
CREATE INDEX idx_dim_time_date ON dim_time(full_date);
