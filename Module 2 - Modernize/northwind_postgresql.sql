-- Create the "categories" table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    description TEXT
);

-- Create the "suppliers" table
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    contact_title VARCHAR(255),
    address VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    phone VARCHAR(20)
);

-- Create the "products" table
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    supplier_id INT REFERENCES suppliers(supplier_id),
    category_id INT REFERENCES categories(category_id),
    quantity_per_unit VARCHAR(255),
    unit_price NUMERIC(10, 2),
    units_in_stock INT,
    units_on_order INT,
    reorder_level INT,
    discontinued BOOLEAN DEFAULT FALSE
);

-- Create the "customers" table
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    contact_title VARCHAR(255),
    address VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    phone VARCHAR(20)
);

-- Create the "orders" table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(10) REFERENCES customers(customer_id),
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    freight NUMERIC(10, 2),
    ship_name VARCHAR(255),
    ship_address VARCHAR(255),
    ship_city VARCHAR(255),
    ship_postal_code VARCHAR(20),
    ship_country VARCHAR(50)
);

-- Create the "order_details" table
CREATE TABLE order_details (
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    unit_price NUMERIC(10, 2),
    quantity INT,
    discount NUMERIC(3, 2),
    PRIMARY KEY (order_id, product_id)
);

-- Create the "employees" table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    title VARCHAR(255),
    birth_date DATE,
    hire_date DATE,
    address VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    phone VARCHAR(20)
);

-- Create the "shippers" table
CREATE TABLE shippers (
    shipper_id SERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20)
);

-- Insert sample data into the "categories" table
INSERT INTO categories (category_name, description)
VALUES
    ('Beverages', 'Soft drinks, coffees, teas, beers, and ales'),
    ('Condiments', 'Sweet and savory sauces, relishes, spreads, and seasonings'),
    ('Confections', 'Desserts, candies, and sweet breads'),
    ('Dairy Products', 'Cheeses'),
    ('Grains/Cereals', 'Breads, crackers, pasta, and cereal');

-- Insert sample data into the "suppliers" table
INSERT INTO suppliers (company_name, contact_name, contact_title, address, city, postal_code, country, phone)
VALUES
    ('Exotic Liquids', 'Charlotte Cooper', 'Purchasing Manager', '49 Gilbert St.', 'London', 'EC1 4SD', 'UK', '555-2222'),
    ('New Orleans Cajun Delights', 'Shelley Burke', 'Order Administrator', 'P.O. Box 78934', 'New Orleans', '70117', 'USA', '555-8222');

-- Insert sample data into the "products" table
INSERT INTO products (product_name, supplier_id, category_id, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued)
VALUES
    ('Chai', 1, 1, '10 boxes x 20 bags', 18.00, 39, 0, 10, FALSE),
    ('Chang', 1, 1, '24 - 12 oz bottles', 19.00, 17, 40, 25, FALSE),
    ('Aniseed Syrup', 1, 2, '12 - 550 ml bottles', 10.00, 13, 70, 25, FALSE);

-- Insert sample data into the "customers" table
INSERT INTO customers (customer_id, company_name, contact_name, contact_title, address, city, postal_code, country, phone)
VALUES
    ('ALFKI', 'Alfreds Futterkiste', 'Maria Anders', 'Sales Representative', 'Obere Str. 57', 'Berlin', '12209', 'Germany', '030-0074321'),
    ('ANATR', 'Ana Trujillo Emparedados y helados', 'Ana Trujillo', 'Owner', 'Avda. de la Constitución 2222', 'México D.F.', '05021', 'Mexico', '555-5555');

-- Insert sample data into the "orders" table
INSERT INTO orders (customer_id, order_date, required_date, shipped_date, freight, ship_name, ship_address, ship_city, ship_postal_code, ship_country)
VALUES
    ('ALFKI', '2023-01-01', '2023-01-10', '2023-01-05', 32.38, 'Alfreds Futterkiste', 'Obere Str. 57', 'Berlin', '12209', 'Germany'),
    ('ANATR', '2023-02-01', '2023-02-08', '2023-02-06', 11.61, 'Ana Trujillo Emparedados y helados', 'Avda. de la Constitución 2222', 'México D.F.', '05021', 'Mexico');

-- Insert sample data into the "order_details" table
INSERT INTO order_details (order_id, product_id, unit_price, quantity, discount)
VALUES
    (1, 1, 18.00, 10, 0.0),
    (1, 2, 19.00, 5, 0.0),
    (2, 1, 18.00, 4, 0.0);

-- Insert sample data into the "employees" table
INSERT INTO employees (last_name, first_name, title, birth_date, hire_date, address, city, postal_code, country, phone)
VALUES
    ('Davolio', 'Nancy', 'Sales Representative', '1968-12-08', '1992-05-01', '507 - 20th Ave. E.', 'Seattle', '98122', 'USA', '555-1234'),
    ('Fuller', 'Andrew', 'Vice President, Sales', '1952-02-19', '1992-08-14', '908 W. Capital Way', 'Tacoma', '98401', 'USA', '555-5678');

-- Insert sample data into the "shippers" table
INSERT INTO shippers (company_name, phone)
VALUES
    ('Speedy Express', '555-1234'),
    ('United Package', '555-5678');
