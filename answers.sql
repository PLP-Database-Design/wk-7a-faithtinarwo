-- Database Normalization Assignment Solutions

-- Create the database
CREATE DATABASE IF NOT EXISTS DatabaseNormalization;

-- Select the database to use
USE DatabaseNormalization;

-- -----------------------------------------------------------------
-- Question 1: Achieving 1NF (First Normal Form)
-- -----------------------------------------------------------------

-- Create the initial ProductDetail table with denormalized data
CREATE TABLE IF NOT EXISTS ProductDetail (
    OrderID INT,
    CustomerName VARCHAR(100),
    Products VARCHAR(255)
);

-- Insert sample data with comma-separated products
INSERT INTO ProductDetail (OrderID, CustomerName, Products)
VALUES
    (101, 'John Doe', 'Laptop, Mouse'),
    (102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
    (103, 'Emily Clark', 'Phone');

-- Solution to Question 1:
-- Create a normalized table in 1NF where each row has one product
CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    PRIMARY KEY (OrderID, Product)
);

-- Insert normalized data from ProductDetail into ProductDetail_1NF
-- This query splits the comma-separated Products values into individual rows
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT 
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.Products, ',', n.n), ',', -1)) AS Product
FROM 
    ProductDetail t
CROSS JOIN 
    (
        SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    ) n
WHERE 
    n.n <= 1 + LENGTH(t.Products) - LENGTH(REPLACE(t.Products, ',', ''));

-- The query above uses:
-- 1. A numbers table (1-5) to help split strings
-- 2. SUBSTRING_INDEX to extract each product item
-- 3. TRIM to remove any extra spaces

-- Select data from the normalized 1NF table
SELECT * FROM ProductDetail_1NF;

-- -----------------------------------------------------------------
-- Question 2: Achieving 2NF (Second Normal Form)
-- -----------------------------------------------------------------

-- Create the initial OrderDetails table (already in 1NF)
CREATE TABLE IF NOT EXISTS OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product)
);

-- Insert sample data
INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity)
VALUES
    (101, 'John Doe', 'Laptop', 2),
    (101, 'John Doe', 'Mouse', 1),
    (102, 'Jane Smith', 'Tablet', 3),
    (102, 'Jane Smith', 'Keyboard', 1),
    (102, 'Jane Smith', 'Mouse', 2),
    (103, 'Emily Clark', 'Phone', 1);

-- Solution to Question 2:

-- Step 1: Create Orders table to remove partial dependency
-- CustomerName depends only on OrderID, not the full primary key
CREATE TABLE Orders_2NF (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Step 2: Create OrderDetails table with only full dependencies
CREATE TABLE OrderDetails_2NF (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders_2NF(OrderID)
);

-- Step 3: Insert data into Orders_2NF (removing duplicates with DISTINCT)
INSERT INTO Orders_2NF (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Step 4: Insert data into OrderDetails_2NF
INSERT INTO OrderDetails_2NF (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- Show the results of 2NF normalization
SELECT * FROM Orders_2NF;
SELECT * FROM OrderDetails_2NF;
