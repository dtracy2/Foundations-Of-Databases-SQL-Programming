--*************************************************************************--
-- Title: Assignment06
-- Author: Dtracy
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,Dtracy,Created File
-- 2022/08/17,Dtracy,Completed Assigned Tasks below 
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_Dtracy')
	 Begin 
	  Alter Database [Assignment06DB_Dtracy] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_Dtracy;
	 End
	Create Database Assignment06DB_Dtracy;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_Dtracy;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- Create a base view for the Categories Table
Go
Create -- Drop
View vCategories With SchemaBinding
AS
Select
 CategoryID
,CategoryName	
From dbo.Categories;
Go
-- Test the vCategories View
--Go
--Select * from vCategories;
--Go
-- Create a base view for the Products Table
Create -- Drop
View vProducts With SchemaBinding
AS
Select
 ProductID
,ProductName	
,CategoryID
,UnitPrice
From dbo.Products;
Go
-- Test the vProducts View
--Go
--Select * from vProducts;
--Go

-- Create a base view for the Employees Table
Create -- Drop
View vEmployees With SchemaBinding
AS
Select
 EmployeeID
,EmployeeFirstName
,EmployeeLastName
,ManagerID
From dbo.Employees;
Go
-- Test the vEmployees View
--Go
--Select * from vEmployees;
--Go

-- Create a base view for the Inventories Table
Create -- Drop
View vInventories With SchemaBinding
AS
Select
 InventoryID
,InventoryDate	
,EmployeeID
,ProductID
,Count
From dbo.Inventories;
Go
-- Test the vInventories View
--Go
--Select * from vInventories;
--Go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Use the Deny Keyword to the public group cannont act on the tables
Go
Deny Select ON Categories to Public;
Deny Select ON Products to Public;
Deny Select ON Employees to Public;
Deny Select ON Inventories to Public;
Go

-- Use the Grant keyword to give access to the views to the Public
Go
Grant Select ON vCategories to Public;
Grant Select On vProducts to Public;
Grant Select On vEmployees to Public;
Grant Select On vInventories to Public;
Go


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Look over the data first if you can.

--Select * From vCategories;
--Select * From vProducts;

-- Make a list of what I want, columns, and tables, start with the From and tables.

--Select CategoryName,ProductName,UnitPrice From vCategories,vProducts;

-- Add in the JOIN and test
--Go
--Select vCategories.CategoryName,vProducts.ProductName,vProducts.UnitPrice
--From vCategories JOIN vProducts
--On vCategories.CategoryID = vProducts.CategoryID;
--Go
-- Add the Order of the results.
--GO
--Select vCategories.CategoryName,vProducts.ProductName,vProducts.UnitPrice
--From vCategories JOIN vProducts
--On vCategories.CategoryID = vProducts.CategoryID
--Order by vCategories.CategoryName,vProducts.ProductName;
--GO

-- Make this a view named: vProductsByCategories
GO
Create -- Drop
View vProductsByCategories With SchemaBinding
AS
Select TOP 1000000000000
vCategories.CategoryName,vProducts.ProductName,vProducts.UnitPrice
From dbo.vCategories JOIN dbo.vProducts
On vCategories.CategoryID = vProducts.CategoryID
Order by vCategories.CategoryName,vProducts.ProductName;
GO


-- Test View vProductsByCategories
--Go
--Select * from vProductsByCategories
--Go
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33

-- Look at the data.
--Go
--Select * from vInventories;
--Select * from vProducts;
--Go
--Make a list of what I want.
--Go
--Select vProducts.ProductName,vInventories.Count,vInventories.InventoryDate
--From vProducts, vInventories;
--Go
-- Join the tables on ProductID
--Go
--Select vProducts.ProductName,vInventories.Count,vInventories.InventoryDate
--From vProducts Join vInventories
--On vProducts.ProductID = vInventories.ProductID;
--Go
-- Group by the InventoryDate, Products and Count I moved it around to look like sample
--GO
--Select vProducts.ProductName,vInventories.InventoryDate,vInventories.Count
--From vProducts Join vInventories
--On vProducts.ProductID = vInventories.ProductID
--Group by vInventories.InventoryDate,vProducts.ProductName,vInventories.Count;
--GO

--Create a view called: vInventoriesByProductsByDates
GO
Create -- Drop
View vInventoriesByProductsByDates With SchemaBinding
AS
Select TOP 1000000000
vProducts.ProductName,vInventories.InventoryDate,vInventories.Count
From dbo.vProducts Join dbo.vInventories
On vProducts.ProductID = vInventories.ProductID
Group by vInventories.InventoryDate,vProducts.ProductName,vInventories.Count;
GO

-- Test view vInventoriesByProductsByDates
--go
--Select * from vInventoriesByProductsByDates;
--Go
-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- List the data
--Go
--Select * from Inventories;
--Select * from Employees;
--Go
-- List what I want from the tables.
--Go
--SELECT vInventories.InventoryDate,vEmployees.EmployeeFirstName,vEmployees.EmployeeLastName
--FROM vInventories,vEmployees;
--Go
-- Join the tables and concatenate the names with a space
--Go
--SELECT vInventories.InventoryDate,(vEmployees.EmployeeFirstName + ' ' + vEmployees.EmployeeLastName) AS FullName
--FROM vInventories Join vEmployees
--ON vInventories.EmployeeID = vEmployees.EmployeeID
--Go
-- Add in the group by
--GO
--SELECT vInventories.InventoryDate,(vEmployees.EmployeeFirstName + ' ' 
--+ vEmployees.EmployeeLastName) AS FullName
--FROM vInventories Join vEmployees
--ON vInventories.EmployeeID = vEmployees.EmployeeID
--Group BY vInventories.InventoryDate,vEmployees.EmployeeFirstName
--,vEmployees.EmployeeLastName;
--GO
-- Create a view called: vInventoriesByEmployeesByDates
GO
Create -- Drop
View vInventoriesByEmployeesByDates With SchemaBinding
AS
SELECT Top 1000000000
vInventories.InventoryDate,(vEmployees.EmployeeFirstName + ' ' 
+ vEmployees.EmployeeLastName) AS FullName
FROM dbo.vInventories Join dbo.vEmployees
ON vInventories.EmployeeID = vEmployees.EmployeeID
Group BY vInventories.InventoryDate,vEmployees.EmployeeFirstName
,vEmployees.EmployeeLastName;
GO

--Test the view vInventoriesByEmployeesByDates
--Go
--Select * from vInventoriesByEmployeesByDates;
--Go
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37

-- Look at the data
--Go
--Select * From vCategories;
--Select * From vProducts;
--Select * from vInventories;
--Go
--Make a list of columns and tables I want
--Go
--Select vCategories.CategoryName,vProducts.ProductName
--,vInventories.InventoryDate,vInventories.Count
--From vCategories,vProducts,vInventories;
--Go

-- Join the tables
--Go
--Select vCategories.CategoryName,vProducts.ProductName
--,vInventories.InventoryDate,vInventories.Count
--From vCategories 
--Inner Join vProducts ON vProducts.CategoryID = vCategories.CategoryID
--Inner Join vInventories ON vInventories.ProductID = vProducts.ProductID;
--Go
-- Add the Order By
--Go
--Select Categories.CategoryName,Products.ProductName
--,Inventories.InventoryDate,Inventories.Count
--From Categories 
--Inner Join Products ON Products.CategoryID = Categories.CategoryID
--Inner Join Inventories ON Inventories.ProductID = Products.ProductID
--Order BY Categories.CategoryID
--,Products.ProductID
--,Inventories.InventoryDate
--,Inventories.Count;
--Go

--Create a view named: vInventoriesByProductsByCategories
Go
Create -- Drop
View vInventoriesByProductsByCategories With SchemaBinding
AS
Select TOP 1000000000
Categories.CategoryName,Products.ProductName
,Inventories.InventoryDate,Inventories.Count
From dbo.Categories 
Inner Join dbo.Products ON Products.CategoryID = Categories.CategoryID
Inner Join dbo.Inventories ON Inventories.ProductID = Products.ProductID
Order BY Categories.CategoryID
,Products.ProductID
,Inventories.InventoryDate
,Inventories.Count;
Go

-- Test the view: vInventoriesByProductsByCategories
--Go
--Select * from vInventoriesByProductsByCategories;
--Go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan

-- Look at the table data
--Go
--Select * FROM vCategories;
--Select * FROM vProducts;
--Select * FROM vInventories;
--Select *FROM vEmployees;
--Go
-- List the tables and columns needed and add some Alias
--Go
--Select C.CategoryName
--,P.ProductName
--,I.InventoryDate
--,I.Count
--,E.EmployeeFirstName
--,E.EmployeeLastName
--FROM vCategories AS C
--,vProducts AS P
--,vInventories AS I
--,vEmployees AS E;
--Go
-- Set the Joins needed USE some alias to get used to it.
--Go
--Select C.CategoryName
--,P.ProductName
--,I.InventoryDate
--,I.Count
--,(E.EmployeeFirstName + ' ' 
--+ E.EmployeeLastName) AS FullName
--FROM vCategories C INNER JOIN
--vProducts P
--ON p.CategoryID = c.CategoryID INNER JOIN
--vInventories I
--ON I.ProductID = P.ProductID INNER JOIN
--vEmployees E
--ON E.EmployeeID = I.EmployeeID
--Go
-- Add the Order requested Inventory Date, Category, Product, and Employee
--GO
--Select C.CategoryName
--,P.ProductName
--,I.InventoryDate
--,I.Count
--,(E.EmployeeFirstName + ' ' 
--+ E.EmployeeLastName) AS FullName
--FROM vCategories C INNER JOIN
--vProducts P
--ON p.CategoryID = c.CategoryID INNER JOIN
--vInventories I
--ON I.ProductID = P.ProductID INNER JOIN
--vEmployees E
--ON E.EmployeeID = I.EmployeeID
--Order BY I.InventoryDate, C.CategoryName, P.ProductName, E.EmployeeID;
--GO

-- Create a view named: vInventoriesByProductsByEmployees
GO
Create -- Drop
View vInventoriesByProductsByEmployees With SchemaBinding
AS
Select TOP 1000000000
C.CategoryName
,P.ProductName
,I.InventoryDate
,I.Count
,(E.EmployeeFirstName + ' ' 
+ E.EmployeeLastName) AS FullName
FROM dbo.vCategories C INNER JOIN
dbo.vProducts P
ON p.CategoryID = c.CategoryID INNER JOIN
dbo.vInventories I
ON I.ProductID = P.ProductID INNER JOIN
dbo.vEmployees E
ON E.EmployeeID = I.EmployeeID
Order BY I.InventoryDate, C.CategoryName, P.ProductName, E.EmployeeID;
GO
-- Test the view vInventoriesByProductsByEmployees
--Go
--Select * from vInventoriesByProductsByEmployees;
--Go


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


 --Look at the table data
--Go
--Select * FROM vCategories;
--Select * FROM vProducts;
--Select * FROM vInventories;
--Select * FROM vEmployees;
--Go
-- List the tables and columns needed and add some Alias
--Go
--Select C.CategoryName
--,P.ProductName
--,I.InventoryDate
--,I.Count
--,E.EmployeeFirstName
--,E.EmployeeLastName
--FROM vCategories AS C
--,vProducts AS P
--,vInventories AS I
--,vEmployees AS E;
--Go
-- Set the Joins needed 
--Go
--Select C.CategoryName
--,P.ProductName
--,I.InventoryDate
--,I.Count
--,(E.EmployeeFirstName + ' ' 
--+ E.EmployeeLastName) AS FullName
--FROM vCategories C INNER JOIN
--vProducts P
--ON p.CategoryID = c.CategoryID INNER JOIN
--vInventories I
--ON I.ProductID = P.ProductID INNER JOIN
--vEmployees E
--ON E.EmployeeID = I.EmployeeID
--Go
-- Add the Order
--GO
--Select C.CategoryName
--,P.ProductName
--,I.InventoryDate
--,I.Count
--,(E.EmployeeFirstName + ' ' 
--+ E.EmployeeLastName) AS FullName
--FROM vCategories C INNER JOIN
--vProducts P
--ON p.CategoryID = c.CategoryID INNER JOIN
--vInventories I
--ON I.ProductID = P.ProductID INNER JOIN
--vEmployees E
--ON E.EmployeeID = I.EmployeeID
--WHERE
--I.ProductID IN (Select I.ProductID  From Inventories Where I.ProductID < 3)
--Order BY I.InventoryDate, C.CategoryName, P.ProductName;
--GO


-- Create View vInventoriesForChaiAndChangByEmployees
GO
Create -- Drop
View vInventoriesForChaiAndChangByEmployees With SchemaBinding
AS
Select TOP 1000000000
C.CategoryName
,P.ProductName
,I.InventoryDate
,I.Count
,(E.EmployeeFirstName + ' ' 
+ E.EmployeeLastName) AS FullName
FROM dbo.vCategories C INNER JOIN
dbo.vProducts P
ON p.CategoryID = c.CategoryID INNER JOIN
dbo.vInventories I
ON I.ProductID = P.ProductID INNER JOIN
dbo.vEmployees E
ON E.EmployeeID = I.EmployeeID
WHERE
I.ProductID IN (Select I.ProductID  From dbo.Inventories Where I.ProductID < 3)
Order BY I.InventoryDate, C.CategoryName, P.ProductName;
GO

--Test View vInventoriesForChaiAndChangByEmployees
--Go
--Select * from vInventoriesForChaiAndChangByEmployees;
--Go



-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

-- Look at the data for this
--Go
--Select * from vEmployees;
--Go
----Select the table and columns needed.
--Go
--Select (a.EmployeeFirstName + ' ' 
--+ a.EmployeeLastName) AS Manager
--,(b.EmployeeFirstName + ' ' 
--+ b.EmployeeLastName) AS Employee
--From vEmployees AS a Inner Join vEmployees AS b
--ON a.EmployeeID = b.ManagerID;
--Go
-- ADD the Order By
--Go
--Select (a.EmployeeFirstName + ' ' 
--+ a.EmployeeLastName) AS Manager
--,(b.EmployeeFirstName + ' ' 
--+ b.EmployeeLastName) AS Employee
--From vEmployees AS a Inner Join vEmployees AS b
--ON a.EmployeeID = b.ManagerID
--Order by a.ManagerID;
--GO
-- Create a view named: vEmployeesByManager
Go
Create -- Drop 
View vEmployeesByManager With SchemaBinding
AS
Select TOP 1000000000 
(a.EmployeeFirstName + ' ' 
+ a.EmployeeLastName) AS Manager
,(b.EmployeeFirstName + ' ' 
+ b.EmployeeLastName) AS Employee
From dbo.vEmployees AS a Inner Join dbo.vEmployees AS b
ON a.EmployeeID = b.ManagerID
Order by a.ManagerID;
GO

-- Test view vEmployeesByManager
--Go
--Select * from vEmployeesByManager;
--Go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth

-- Create view: vInventoriesByProductsByCategoriesByEmployees
-- Show the table data
--GO 
--Select * from Categories;
--Select * from Products;
--Select * from Inventories;
--Select * from Employees;
--GO


Create -- Drop
View vInventoriesByProductsByCategoriesByEmployees With SchemaBinding
AS
Select TOP 1000000000
C.CategoryID
,C.CategoryName
,P.ProductID
,P.ProductName
,P.UnitPrice
,I.InventoryID
,I.InventoryDate
,I.Count
,E.EmployeeID
,(E.EmployeeFirstName + ' ' 
+ E.EmployeeLastName) AS Employee
FROM dbo.vCategories C INNER JOIN
dbo.vProducts P
ON p.CategoryID = c.CategoryID INNER JOIN
dbo.vInventories I
ON I.ProductID = P.ProductID INNER JOIN
dbo.vEmployees E
ON E.EmployeeID = I.EmployeeID
Order BY C.CategoryName, P.ProductName,I.InventoryDate,E.EmployeeID;
GO

-- Test View vInventoriesByProductsByCategoriesByEmployees
--Go
--Select * from vInventoriesByProductsByCategoriesByEmployees;
--Go



-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/