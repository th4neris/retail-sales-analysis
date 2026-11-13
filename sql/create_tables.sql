-- Creates the retail_store database and its 8 tables
-- Run this file first, then 02_insert_data.sql

CREATE DATABASE IF NOT EXISTS retail_store;
USE retail_store;

-- categories: product categories
CREATE TABLE categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

-- products: products available for sale
CREATE TABLE products (
    product_id   INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id  INT,
    brand        VARCHAR(50),
    unit_cost    DECIMAL(10,2),
    unit_price   DECIMAL(10,2),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- stores: retail store locations
CREATE TABLE stores (
    store_id   INT AUTO_INCREMENT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    city       VARCHAR(50),
    region     VARCHAR(50)
);

-- employees: store employees
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50),
    last_name   VARCHAR(50),
    store_id    INT,
    hire_date   DATE,
    CONSTRAINT fk_employees_store
        FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- customers: customer information
CREATE TABLE customers (
    customer_id       INT AUTO_INCREMENT PRIMARY KEY,
    first_name        VARCHAR(50),
    last_name         VARCHAR(50),
    gender            VARCHAR(10),
    age               INT,
    city              VARCHAR(50),
    registration_date DATE
);

-- orders: customer orders (one row per order)
-- order_status: Completed, Pending, Cancelled, Returned
CREATE TABLE orders (
    order_id       INT AUTO_INCREMENT PRIMARY KEY,
    customer_id    INT,
    store_id       INT,
    employee_id    INT,
    order_date     DATE,
    payment_method VARCHAR(30),
    order_status   VARCHAR(20),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_orders_store
        FOREIGN KEY (store_id)    REFERENCES stores(store_id),
    CONSTRAINT fk_orders_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- order_items: individual products within each order
-- discount is a fraction: 0.10 = 10% off
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    unit_price    DECIMAL(10,2),
    discount      DECIMAL(3,2) DEFAULT 0,
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- payments: payment transactions (one per order)
-- payment_status: Paid, Pending, Failed, Refunded
CREATE TABLE payments (
    payment_id     INT AUTO_INCREMENT PRIMARY KEY,
    order_id       INT,
    payment_date   DATE,
    amount         DECIMAL(10,2),
    payment_method VARCHAR(30),
    payment_status VARCHAR(20),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
