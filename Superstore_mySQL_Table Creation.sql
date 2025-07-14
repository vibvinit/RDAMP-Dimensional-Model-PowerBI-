CREATE DATABASE IF NOT EXISTS RDAMP;

USE RDAMP;

CREATE TABLE Orders (
		Order_ID VARCHAR(10) NOT NULL PRIMARY KEY,
                Order_mode CHAR(10)
        );
 
 CREATE TABLE Store_Locations (
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
      
     CREATE TABLE date_dim(
		Order_Date DATE PRIMARY KEY,
		Years int,
		Months VARCHAR(20),
		Quarters VARCHAR(10)
		);
        
        
		CREATE TABLE Sales (
		Order_ID VARCHAR(10),
        Customer_ID VARCHAR(10),
        Order_Date DATE,
        Postal_Code VARCHAR(5),
        Product_ID VARCHAR(40) ,
        Sales_Price Decimal(6,2),
        Cost_Price Decimal(6,3),
        Quantity int,
        Discount Decimal(3,2),
        
        CONSTRAINT fk_order FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
		CONSTRAINT fk_postal FOREIGN KEY (Postal_Code) REFERENCES Store_Locations(Postal_Code),
		CONSTRAINT fk_product FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
        CONSTRAINT fk_date FOREIGN KEY (Order_Date) REFERENCES date_dim(Order_Date)
        );
