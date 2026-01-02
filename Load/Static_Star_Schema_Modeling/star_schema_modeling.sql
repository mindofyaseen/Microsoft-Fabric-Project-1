/* SECTION 1: CREATE TABLES WITH FABRIC SUPPORTED DATA TYPES */

-- 1. Dim_Product
DROP TABLE IF EXISTS Gold_WareHouse_1.gold.Dim_Product;
GO
CREATE TABLE Gold_WareHouse_1.gold.Dim_Product (
    ProductKey INT NOT NULL,
    ProductSKU VARCHAR(8000),
    ProductName VARCHAR(8000),
    ModelName VARCHAR(8000),
    ProductColor VARCHAR(8000),
    ProductSize VARCHAR(8000),
    ProductCost DECIMAL(18,4),
    ProductPrice DECIMAL(18,4),
    SubcategoryName VARCHAR(8000),
    CategoryName VARCHAR(8000)
);
GO
INSERT INTO Gold_WareHouse_1.gold.Dim_Product
SELECT products.ProductKey, products.ProductSKU, products.ProductName, products.ModelName,
       products.ProductColor, products.ProductSize, products.ProductCost, products.ProductPrice,
       sub_categories.SubcategoryName, categories.CategoryName
FROM Muhammad_Yaseen_Lake_House_1.dbo.adventureworks_products as products
INNER JOIN Muhammad_Yaseen_Lake_House_1.dbo.adventureworks_product_subcategories as sub_categories ON products.ProductSubcategoryKey = sub_categories.ProductSubcategoryKey
INNER JOIN Muhammad_Yaseen_Lake_House_1.dbo.adventureworks_product_categories as categories ON categories.ProductCategoryKey = sub_categories.ProductCategoryKey;
GO

-- 2. Dim_Customer
DROP TABLE IF EXISTS Gold_WareHouse_1.gold.Dim_Customer;
GO
CREATE TABLE Gold_WareHouse_1.gold.Dim_Customer (
    CustomerKey INT NOT NULL,
    FirstName VARCHAR(8000),
    LastName VARCHAR(8000),
    BirthDate DATE,
    MaritalStatus VARCHAR(10),
    Gender VARCHAR(10),
    EmailAddress VARCHAR(8000),
    AnnualIncome VARCHAR(8000),
    EducationLevel VARCHAR(8000),
    Occupation VARCHAR(8000)
);
GO
INSERT INTO Gold_WareHouse_1.gold.Dim_Customer
SELECT CustomerKey, FirstName, LastName, BirthDate, MaritalStatus, Gender, EmailAddress, AnnualIncome, EducationLevel, Occupation
FROM Muhammad_Yaseen_Lake_House_1.dbo.adventureworks_customers;
GO

-- 3. Dim_Calendar
DROP TABLE IF EXISTS Gold_WareHouse_1.gold.Dim_Calendar;
GO
CREATE TABLE Gold_WareHouse_1.gold.Dim_Calendar (
    Date DATE NOT NULL,
    Year INT,
    Month INT,
    Month_Name VARCHAR(8000),
    Quarter INT,
    Day_name VARCHAR(8000),
    Weekend_Flag VARCHAR(8000) -- Bit ki jagah Varchar kyunke data mein 'Weekend'/'Weekday' likha hai
);
GO
INSERT INTO Gold_WareHouse_1.gold.Dim_Calendar
SELECT Date, Year, Month, CAST(DATENAME(month, Date) AS VARCHAR(8000)), Quarter, Day_name, Weekend_Flag
FROM Muhammad_Yaseen_Lake_House_1.dbo.time_intelligence_calendar;
GO

-- 4. Dim_Territory
DROP TABLE IF EXISTS Gold_WareHouse_1.gold.Dim_Territory;
GO
CREATE TABLE Gold_WareHouse_1.gold.Dim_Territory (
    SalesTerritoryKey INT NOT NULL,
    Region VARCHAR(8000),
    Country VARCHAR(8000),
    Continent VARCHAR(8000)
);
GO
INSERT INTO Gold_WareHouse_1.gold.Dim_Territory
SELECT SalesTerritoryKey, Region, Country, Continent
FROM Muhammad_Yaseen_Lake_House_1.dbo.adventureworks_territories;
GO

-- 5. Fact_Sales
DROP TABLE IF EXISTS Gold_WareHouse_1.gold.Fact_Sales;
GO
CREATE TABLE Gold_WareHouse_1.gold.Fact_Sales (
    OrderDate DATE,
    StockDate DATE,
    OrderNumber VARCHAR(8000),
    ProductKey INT,
    CustomerKey INT,
    TerritoryKey INT,
    OrderLineItem INT,
    OrderQuantity INT
);
GO
INSERT INTO Gold_WareHouse_1.gold.Fact_Sales
SELECT * FROM Muhammad_Yaseen_Lake_House_1.dbo.fact_sales;
GO

/* SECTION 2: STAR SCHEMA CONSTRAINTS (NOT ENFORCED) */

ALTER TABLE Gold_WareHouse_1.gold.Dim_Product ADD CONSTRAINT PK_Dim_Product PRIMARY KEY NONCLUSTERED (ProductKey) NOT ENFORCED;
GO
ALTER TABLE Gold_WareHouse_1.gold.Dim_Customer ADD CONSTRAINT PK_Dim_Customer PRIMARY KEY NONCLUSTERED (CustomerKey) NOT ENFORCED;
GO
ALTER TABLE Gold_WareHouse_1.gold.Dim_Calendar ADD CONSTRAINT PK_Dim_Calendar PRIMARY KEY NONCLUSTERED (Date) NOT ENFORCED;
GO
ALTER TABLE Gold_WareHouse_1.gold.Dim_Territory ADD CONSTRAINT PK_Dim_Territory PRIMARY KEY NONCLUSTERED (SalesTerritoryKey) NOT ENFORCED;
GO

ALTER TABLE Gold_WareHouse_1.gold.Fact_Sales ADD CONSTRAINT FK_Sales_Product FOREIGN KEY (ProductKey) REFERENCES Gold_WareHouse_1.gold.Dim_Product(ProductKey) NOT ENFORCED;
GO
ALTER TABLE Gold_WareHouse_1.gold.Fact_Sales ADD CONSTRAINT FK_Sales_Customer FOREIGN KEY (CustomerKey) REFERENCES Gold_WareHouse_1.gold.Dim_Customer(CustomerKey) NOT ENFORCED;
GO
ALTER TABLE Gold_WareHouse_1.gold.Fact_Sales ADD CONSTRAINT FK_Sales_Calendar FOREIGN KEY (OrderDate) REFERENCES Gold_WareHouse_1.gold.Dim_Calendar(Date) NOT ENFORCED;
GO
ALTER TABLE Gold_WareHouse_1.gold.Fact_Sales ADD CONSTRAINT FK_Sales_Territory FOREIGN KEY (TerritoryKey) REFERENCES Gold_WareHouse_1.gold.Dim_Territory(SalesTerritoryKey) NOT ENFORCED;
GO