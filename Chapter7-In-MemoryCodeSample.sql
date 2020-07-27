ALTER SERVER CONFIGURATION SET MEMORY_OPTIMIZED TEMPDB_METADATA = ON;

CREATE DATABASE CMSMem
    ON 
    PRIMARY(NAME = [CMSMem_data], 
         FILENAME = 'G:\Data\CMSMem_data.mdf', 
         SIZE=500MB), 
    FILEGROUP [CMSMem_InMem] 
         CONTAINS MEMORY_OPTIMIZED_DATA
        (NAME = [CMSMem_InMem1], 
           FILENAME = 'G:\Data\CMSMem_InMem1'),
        (NAME = [CMSMem_InMem2], 
           FILENAME = 'H:\Data\CMSMem_InMem2') 
    LOG ON (name = [CMSMem_log],
        Filename='L:\Logs\CMSMem_log.ldf', 
        SIZE=500MB);

ALTER DATABASE TestDBInMem SET 
  MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;

CREATE TABLE dbo.People (
   [ID] [int] IDENTITY(1,1) NOT NULL ,
   [Name] varchar(32) NOT NULL  
        INDEX IX_People_Name HASH
        WITH (BUCKET_COUNT = 75000000),
   [City] varchar(32) NOT NULL 
        INDEX IX_People_City HASH
        WITH (BUCKET_COUNT = 50000),
   [State_Province] varchar(32) NOT NULL
        INDEX IX_PEOPLE_State_Province HASH
        WITH (BUCKET_COUNT = 1000),
   PRIMARY KEY NONCLUSTERED HASH (ID) WITH
        (BUCKET_COUNT = 75000000)
) WITH (
      MEMORY_OPTIMIZED = ON, 
      DURABILITY = SCHEMA_AND_DATA);

SELECT
	OBJECT_NAME(s.object_id) AS TableName,
	i.name as IndexName, 
	s.total_bucket_count
FROM
	sys.dm_db_xtp_hash_index_stats s
	INNER JOIN sys.hash_indexes i 
		ON s.object_id = i.object_id 
			and s.index_id = i.index_id
ORDER BY
	TableName, IndexName

USE [CMS]
GO

CREATE proc [dbo].[Product_by_Date] (
	@StartDT DATETIME,
	@EndDT DATETIME
) AS

SET NOCOUNT ON;

SELECT
	l.ProductID,
	SUM(l.QuantityOrdered) AS SoldCount,
	SUM(l.UnitPrice) AS SoldValue
FROM
	dbo.[Order] o
	INNER JOIN dbo.OrderLine l 
		ON o.OrderID = l.OrderID
	INNER JOIN dbo.Person p 
		ON p.PersonID = o.PersonID
	INNER JOIN dbo.SalesRep r 
		ON r.SalesRepID = o.SalesRepID
	INNER JOIN dbo.SalesTerritory t 
		ON t.SalesTerritoryID = r.SalesTerritoryID
WHERE
	o.OrderDT >= @StartDT
	AND o.OrderDT <= @EndDT
GROUP BY
	l.ProductID
ORDER BY
	SoldValue DESC


USE [CMSMem]
GO

CREATE OR ALTER PROC [dbo].[Product_by_Date] (
	@StartDT DATETIME,
	@EndDT DATETIME
) 
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS

BEGIN ATOMIC WITH (
	TRANSACTION ISOLATION LEVEL = SNAPSHOT, 
	LANGUAGE = N'us_english')

SELECT
	l.ProductID,
	SUM(l.QuantityOrdered) AS SoldCount,
	SUM(l.UnitPrice) AS SoldValue
FROM
	dbo.[Order] o
	INNER JOIN dbo.OrderLine l 
		ON o.OrderID = l.OrderID
	INNER JOIN dbo.Person p 
		ON p.PersonID = o.PersonID
	INNER JOIN dbo.SalesRep r 
ON r.SalesRepID = o.SalesRepID
	INNER JOIN dbo.SalesTerritory t 
		ON t.SalesTerritoryID = r.SalesTerritoryID
WHERE
	o.OrderDT >= @StartDT
	AND o.OrderDT <= @EndDT
GROUP BY
	l.ProductID
ORDER BY
	SoldValue DESC
	
END;


USE CMS
GO
EXEC dbo.Product_By_Date '2020-06-01', '2020-06-30'
GO

USE CMSMem
GO
EXEC dbo.Product_By_Date '2020-06-01', '2020-06-30'
GO

--Update random sales reps
SET STATISTICS TIME ON
GO
USE CMS
GO
DECLARE @OldRepID INT, @NewRepID INT
SELECT TOP 1 @OldRepID = SalesRepID FROM dbo.SalesRep ORDER BY NEWID()
SELECT TOP 1 @NewRepID = SalesRepID FROM dbo.SalesRep ORDER BY NEWID()
-- So we can transpose the item to the 
-- in-memory command for continuity in operations
PRINT @OldRepID 
PRINT @NewRepID

EXEC dbo.Sales_Rep_Reassign @OldRepID, @NewRepID
GO
--148ms

USE CMSMem
GO
EXEC dbo.Sales_Rep_Reassign 4652, 1265
GO
--6ms

CREATE TABLE dbo.People (
   [ID] [int] IDENTITY(1,1) NOT NULL ,
   [Name] varchar(32) NOT NULL  
        INDEX IX_People_Name HASH
        WITH (BUCKET_COUNT = 60000000),
   [City] varchar(32) NOT NULL 
        INDEX IX_People_City HASH
        WITH (BUCKET_COUNT = 6000000),
   [State_Province] varchar(32) NOT NULL
   PRIMARY KEY NONCLUSTERED HASH (ID) WITH
        (BUCKET_COUNT = 60000000)
) WITH (
      MEMORY_OPTIMIZED = ON, 
      DURABILITY = SCHEMA_AND_DATA);

