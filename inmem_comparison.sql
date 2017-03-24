set statistics time on
GO

USE CMS
GO
EXEC dbo.Product_By_Date '2016-06-01', '2016-06-30'
GO
--24s

USE CMSMem
GO
EXEC dbo.Product_By_Date '2016-06-01', '2016-06-30'
GO
--3s

USE Columnstore
GO
EXEC dbo.Product_By_Date '2016-06-01', '2016-06-30'
GO
--826ms

USE CMSMemCI
GO
EXEC dbo.Product_By_Date '2016-06-01', '2016-06-30'
GO
--826ms

--------------------------------------------------

USE CMS
GO
EXEC dbo.Product_by_Territory_Date '2016-06-01', '2016-06-30'
GO
--12s

USE CMSMem
GO
EXEC dbo.Product_by_Territory_Date '2016-06-01', '2016-06-30'
GO
--3s

USE Columnstore
GO
EXEC dbo.Product_by_Territory_Date '2016-06-01', '2016-06-30'
GO
--8.8s

USE CMSMemCI
GO
EXEC dbo.Product_by_Territory_Date '2016-06-01', '2016-06-30'
GO
--8.8s
--------------------------------------------------

USE CMS
GO
EXEC dbo.Product_Ship_Delays_by_Age_Date 7, '2016-06-01', '2016-06-30'
GO
--0.353s

USE CMSMem
GO
EXEC dbo.Product_Ship_Delays_by_Age_Date 7, '2016-06-01', '2016-06-30'
GO
--0.363s

USE Columnstore
GO
EXEC dbo.Product_Ship_Delays_by_Age_Date 7, '2016-06-01', '2016-06-30'
GO
--0.301s

USE CMSMemCI
GO
EXEC dbo.Product_Ship_Delays_by_Age_Date 7, '2016-06-01', '2016-06-30'
GO
--0.301s
--------------------------------------------------
USE CMS
GO
EXEC dbo.Product_Ship_Delays_by_Date '2016-06-01', '2016-06-30'
GO
--124221ms

USE CMSMem
GO
EXEC dbo.Product_Ship_Delays_by_Date '2016-06-01', '2016-06-30'
GO
--860ms

USE Columnstore
GO
EXEC dbo.Product_Ship_Delays_by_Date '2016-06-01', '2016-06-30'
GO
--301ms

USE CMSMemCI
GO
EXEC dbo.Product_Ship_Delays_by_Date '2016-06-01', '2016-06-30'
GO
--301ms
--------------------------------------------------
USE CMS
GO
EXEC dbo.Sales_By_Territory_Date '2016-06-01', '2016-06-30'
GO
--226ms

USE CMSMem
GO
EXEC dbo.Sales_By_Territory_Date '2016-06-01', '2016-06-30'
GO
--1236ms

USE Columnstore
GO
EXEC dbo.Sales_By_Territory_Date '2016-06-01', '2016-06-30'
GO
--120ms

USE CMSMemCI
GO
EXEC dbo.Sales_By_Territory_Date '2016-06-01', '2016-06-30'
GO
--120ms
--------------------------------------------------
USE CMS
GO
EXEC dbo.Sales_By_Territory_Rep_Date '2016-06-01', '2016-06-30'
GO
--324ms

USE CMSMem
GO
EXEC dbo.Sales_By_Territory_Rep_Date '2016-06-01', '2016-06-30'
GO
--282ms

USE Columnstore
GO
EXEC dbo.Sales_By_Territory_Rep_Date '2016-06-01', '2016-06-30'
GO
--251ms

USE CMSMemCI
GO
EXEC dbo.Sales_By_Territory_Rep_Date '2016-06-01', '2016-06-30'
GO
--251ms

--------------------------------------------------
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

USE Columnstore
GO
EXEC dbo.Sales_Rep_Reassign 4652, 1265
GO
--19ms

USE CMSMemCI
GO
EXEC dbo.Sales_Rep_Reassign 4652, 1265
GO
--19ms