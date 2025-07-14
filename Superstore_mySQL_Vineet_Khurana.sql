CREATE DATABASE IF NOT EXISTS RDMA;

USE RDMA;

CREATE TABLE Orders (
		order_ID VARCHAR(10) NOT NULL PRIMARY KEY,
        Order_date DATE,
        Order_mode CHAR(10)
        );
        
CREATE TABLE Stores (
		City CHAR(20),
        Postal_Code	VARCHAR(5) NOT NULL PRIMARY KEY,
        Country CHAR(20),
        Region CHAR(30)
        );
        
CREATE TABLE Products (
		Product_ID	VARCHAR(40) NOT NULL PRIMARY KEY,
        Product_Name CHAR(50),
        Subcategory CHAR(60),
        Category CHAR(20),
        Segment CHAR(20)
        );
        
    CREATE TABLE Sales (
		Order_ID VARCHAR(10) FOREIGN KEY,
        Customer_ID VARCHAR(10) NOT NULL,
        Postal_Code VARCHAR(5) FOREIGN KEY,
        Product_ID VARCHAR(40) FOREIGN KEY,
        Sales_Price int,
        Cost_Price int,
        Quantity int,
        Discount int
        )