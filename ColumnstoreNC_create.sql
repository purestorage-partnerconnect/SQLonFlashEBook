USE [master]
GO
/****** Object:  Database [ColumnstoreNC]    Script Date: 11/3/2016 8:51:48 PM ******/
CREATE DATABASE [ColumnstoreNC]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Columnstore', FILENAME = N'H:\Data\ColumnstoreNC.mdf' , SIZE = 131072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 131072KB ), 
 FILEGROUP [Columnstore_Data] 
( NAME = N'Columnstore_Data1', FILENAME = N'H:\Data\ColumnstoreNC_Data1.ndf' , SIZE = 131072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 131072KB ),
( NAME = N'Columnstore_Data2', FILENAME = N'H:\Data\ColumnstoreNC_Data2.ndf' , SIZE = 131072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 131072KB )
 LOG ON 
( NAME = N'Columnstore_log', FILENAME = N'L:\Logs\ColumnstoreNC_log.ldf' , SIZE = 131072KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [ColumnstoreNC] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE [ColumnstoreNC] SET READ_COMMITTED_SNAPSHOT ON 
GO
USE [ColumnstoreNC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GenerateRandomDateTime] (
	@StartDate datetime,
	@EndDate datetime
)

RETURNS	NVARCHAR(max)
AS BEGIN

DECLARE @RetVal DATETIME

DECLARE @Seconds INT = DATEDIFF(SECOND, @StartDate, @EndDate)


DECLARE @Random INT
SET @Random = (SELECT ROUND(((@Seconds-1) * RandNumber), 0) from dbo.RandView)

DECLARE @Milliseconds INT 
SET @Milliseconds = (SELECT ROUND((999 * RandNumber), 0) from dbo.RandView)

SET @RetVal = DATEADD(MILLISECOND, @Milliseconds, DATEADD(SECOND, @Random, @StartDate))



RETURN @RetVal
END
GO
/****** Object:  UserDefinedFunction [dbo].[GenerateRandomPrice]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GenerateRandomPrice] (
	@StartPrice int,
	@EndPrice int
)

RETURNS	NUMERIC(10,2)
AS BEGIN

DECLARE @RetVal NUMERIC(10,2)


SELECT @RetVal = ((@EndPrice - @StartPrice)
* RandNumber + @StartPrice) from dbo.RandView


RETURN @RetVal
END

GO
/****** Object:  UserDefinedFunction [dbo].[GenerateRandomString]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GenerateRandomString] (
	@NumberOfCharacters int
)

RETURNS	NVARCHAR(max)
AS BEGIN

DECLARE @RetVal NVARCHAR(max) = N'';
DECLARE @CharSet NVARCHAR(256) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
DECLARE @counter INT = 0
DECLARE @tmp INT

while @counter < @NumberOfCharacters BEGIN
	SELECT @tmp = cast(RandNumber * 51 AS INT)+1 from dbo.RandView
	SELECT  @RetVal += SUBSTRING(@Charset, @tmp, 1)
	set @counter = @counter + 1
END

RETURN @RetVal
END

GO
/****** Object:  View [dbo].[RandView]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RandView]
AS
SELECT RAND() RandNumber

GO
/****** Object:  Table [dbo].[Order]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Order](
	[OrderID] [bigint] IDENTITY(1,1) NOT NULL,
	[PersonID] [bigint] NOT NULL,
	[OrderDT] [datetime] NOT NULL,
	[ShipDT] [datetime] NULL,
	[SalesRepID] [int] NOT NULL,
	[ProductCost] [numeric](18, 2) NULL,
	[ShippingCost] [numeric](10, 2) NULL,
	[TaxCost] [numeric](10, 2) NULL,
	[OrderCost] [numeric](18, 2) NULL,
 CONSTRAINT [PK_Order] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Columnstore_Data]
) ON [Columnstore_Data]

GO
/****** Object:  Table [dbo].[OrderLine]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderLine](
	[OrderLineID] [bigint] IDENTITY(1,1) NOT NULL,
	[OrderID] [bigint] NOT NULL,
	[ProductID] [bigint] NOT NULL,
	[QuantityOrdered] [int] NOT NULL,
	[UnitPrice] [numeric](10, 2) NOT NULL,
 CONSTRAINT [PK_OrderLine] PRIMARY KEY CLUSTERED 
(
	[OrderLineID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Columnstore_Data]
) ON [Columnstore_Data]

GO
/****** Object:  Table [dbo].[Person]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Person](
	[PersonID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[CreatedDT] [datetime] NOT NULL,
 CONSTRAINT [PK_Person] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Columnstore_Data]
) ON [Columnstore_Data]

GO
/****** Object:  Table [dbo].[Product]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product](
	[ProductID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](50) NOT NULL,
	[UnitPrice] [numeric](12, 2) NOT NULL,
	[ProductTypeID] [int] NOT NULL,
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Columnstore_Data]
) ON [Columnstore_Data]

GO
/****** Object:  Table [dbo].[ProductType]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductType](
	[ProductTypeID] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ProductType] PRIMARY KEY CLUSTERED 
(
	[ProductTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Columnstore_Data]
) ON [Columnstore_Data]

GO
/****** Object:  Table [dbo].[SalesRep]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesRep](
	[SalesRepID] [int] IDENTITY(1,1) NOT NULL,
	[RepName] [nvarchar](100) NOT NULL,
	[SalesTerritoryID] [int] NOT NULL,
 CONSTRAINT [PK_SalesRep] PRIMARY KEY CLUSTERED 
(
	[SalesRepID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Columnstore_Data]
) ON [Columnstore_Data]

GO
/****** Object:  Table [dbo].[SalesTerritory]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SalesTerritory](
	[SalesTerritoryID] [int] IDENTITY(1,1) NOT NULL,
	[TerritoryName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_SalesTerritory] PRIMARY KEY CLUSTERED 
(
	[SalesTerritoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Columnstore_Data]
) ON [Columnstore_Data]

GO
/****** Object:  Index [NCI_Order]    Script Date: 11/3/2016 8:51:48 PM ******/
CREATE NONCLUSTERED COLUMNSTORE INDEX [NCI_Order] ON [dbo].[Order]
(
	[PersonID],
	[OrderDT],
	[ShipDT],
	[SalesRepID],
	[ProductCost],
	[ShippingCost],
	[TaxCost],
	[OrderCost]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [Columnstore_Data]
GO
/****** Object:  Index [NCI_OrderLine]    Script Date: 11/3/2016 8:51:48 PM ******/
CREATE NONCLUSTERED COLUMNSTORE INDEX [NCI_OrderLine] ON [dbo].[OrderLine]
(
	[OrderID],
	[ProductID],
	[QuantityOrdered],
	[UnitPrice]
)WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [Columnstore_Data]
GO
ALTER TABLE [dbo].[Order] ADD  CONSTRAINT [DF_Order_OrderDT]  DEFAULT (getutcdate()) FOR [OrderDT]
GO
ALTER TABLE [dbo].[Person] ADD  CONSTRAINT [DF_Person_CreatedDT]  DEFAULT (getutcdate()) FOR [CreatedDT]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_Person] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_Person]
GO
ALTER TABLE [dbo].[Order]  WITH CHECK ADD  CONSTRAINT [FK_Order_SalesRep] FOREIGN KEY([SalesRepID])
REFERENCES [dbo].[SalesRep] ([SalesRepID])
GO
ALTER TABLE [dbo].[Order] CHECK CONSTRAINT [FK_Order_SalesRep]
GO
ALTER TABLE [dbo].[OrderLine]  WITH CHECK ADD  CONSTRAINT [FK_OrderLine_Order] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Order] ([OrderID])
GO
ALTER TABLE [dbo].[OrderLine] CHECK CONSTRAINT [FK_OrderLine_Order]
GO
ALTER TABLE [dbo].[OrderLine]  WITH CHECK ADD  CONSTRAINT [FK_OrderLine_Product] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Product] ([ProductID])
GO
ALTER TABLE [dbo].[OrderLine] CHECK CONSTRAINT [FK_OrderLine_Product]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_ProductType] FOREIGN KEY([ProductTypeID])
REFERENCES [dbo].[ProductType] ([ProductTypeID])
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_ProductType]
GO
ALTER TABLE [dbo].[SalesRep]  WITH CHECK ADD  CONSTRAINT [FK_SalesRep_SalesTerritory] FOREIGN KEY([SalesTerritoryID])
REFERENCES [dbo].[SalesTerritory] ([SalesTerritoryID])
GO
ALTER TABLE [dbo].[SalesRep] CHECK CONSTRAINT [FK_SalesRep_SalesTerritory]
GO
/****** Object:  StoredProcedure [dbo].[Order_Generate]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Order_Generate] AS

BEGIN

SET NOCOUNT ON
SET XACT_ABORT ON

declare @OrderLines int 
declare @OrderID bigint
declare @PersonID bigint
declare @SalesRepID int
declare @LoopCounter int = 0
declare @ProductID bigint
declare @UnitPrice numeric(12,2)
declare @ShipDT datetime
declare @ProductCost numeric(10,2)
declare @ShippingCost numeric(10,2)
declare @TaxCost numeric(10,2)
declare @OrderCost numeric(18,2)

SET @OrderLines = ceiling(rand()*100)

SET @PersonID = (SELECT top 1 PersonID FROM dbo.Person
	WHERE PersonID > rand() * (SELECT max(personid) FROM dbo.Person) )

SET @SalesRepID = (SELECT top 1 SalesRepID FROM dbo.SalesRep
	WHERE SalesRepID > rand() * (SELECT max(SalesRepID) FROM dbo.SalesRep) )


BEGIN TRANSACTION [OrderTran]

BEGIN TRY

INSERT INTO dbo.[Order] (PersonID, OrderDT, SalesRepID)
SELECT 
	@PersonID, 
	dbo.GenerateRandomDateTime('2010-01-01', GETDATE()),
	@SalesRepID

SELECT @OrderID = SCOPE_IDENTITY()

WHILE @LoopCounter < @OrderLines BEGIN

	SELECT
		top 1 @ProductID = ProductID , @UnitPrice = UnitPrice
	from 
		dbo.Product 
	where
		productid >= rand() * 
			(select max(productid) from dbo.Product)

	insert into dbo.OrderLine (OrderID, ProductID, QuantityOrdered, UnitPrice)
	SELECT 
		@OrderID, 
		@ProductID,
		CEILING(RAND()*1000),
		@UnitPrice

	select @ShippingCost = dbo.GenerateRandomPrice(5,500)

	select 
		@ShipDT = dateadd(dd,CEILING(RAND()*10), OrderDT),
		@ProductCost = sum(UnitPrice),
		@TaxCost = sum(UnitPrice) * 0.05,
		@OrderCost = sum(UnitPrice) * 1.05
	from 
		orderline l
		join dbo.[Order] o on o.OrderID = l.OrderID
	where
		o.OrderID = @OrderID
	group by
		OrderDT


	UPDATE dbo.[Order] 
	set 
		ShipDT = @ShipDT,		
		ProductCost = @ProductCost,
		TaxCost = @TaxCost,
		ShippingCost = @ShippingCost,
		OrderCost = @OrderCost + @ShippingCost
	where
		OrderID = @OrderID


	SET @LoopCounter = @LoopCounter + 1
END

COMMIT TRANSACTION [OrderTran]

END TRY
BEGIN CATCH 
	ROLLBACK TRANSACTION [OrderTran]
END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[Product_by_Date]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[Product_by_Date] (
	@StartDT datetime,
	@EndDT datetime
) as

set nocount on;

select
	l.ProductID,
	--t.TerritoryName,
	sum(l.QuantityOrdered) as SoldCount,
	sum(l.UnitPrice) as SoldValue
from
	dbo.[Order] o
	join dbo.OrderLine l on o.OrderID = l.OrderID
	join dbo.Person p on p.PersonID = o.PersonID
	join dbo.SalesRep r on r.SalesRepID = o.SalesRepID
	join dbo.SalesTerritory t on t.SalesTerritoryID = r.SalesTerritoryID
where
	o.OrderDT >= @StartDT
	and o.OrderDT <= @EndDT
group by
	l.ProductID
	--t.TerritoryName
order by 
	/*t.TerritoryName asc,*/ SoldValue desc
GO
/****** Object:  StoredProcedure [dbo].[Product_by_Territory_Date]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[Product_by_Territory_Date] (
	@StartDT datetime,
	@EndDT datetime
) as

set nocount on;

select
	l.ProductID,
	t.TerritoryName,
	sum(l.QuantityOrdered) as SoldCount,
	sum(l.UnitPrice) as SoldValue
from
	dbo.[Order] o
	join dbo.OrderLine l on o.OrderID = l.OrderID
	join dbo.Person p on p.PersonID = o.PersonID
	join dbo.SalesRep r on r.SalesRepID = o.SalesRepID
	join dbo.SalesTerritory t on t.SalesTerritoryID = r.SalesTerritoryID
where
	o.OrderDT >= @StartDT
	and o.OrderDT <= @EndDT
group by
	l.ProductID,
	t.TerritoryName
order by 
	t.TerritoryName asc, SoldValue desc
GO
/****** Object:  StoredProcedure [dbo].[Product_Ship_Delays_by_Age_Date]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Product_Ship_Delays_by_Age_Date] (
	@MinDaysDelayed int = 7,
	@StartDT datetime,
	@EndDT datetime
) as

set nocount on;

select
	count(o.OrderID) as NumOrdersImpacted,
	datediff(dd, o.OrderDT, o.ShipDT) as ShippingDelayDays
from
	dbo.[Order] o
	join dbo.OrderLine l on o.OrderID = l.OrderID
	join dbo.Person p on p.PersonID = o.PersonID
	join dbo.SalesRep r on r.SalesRepID = o.SalesRepID
	join dbo.SalesTerritory t on t.SalesTerritoryID = r.SalesTerritoryID
where
	o.OrderDT >= @StartDT
	and o.OrderDT <= @EndDT
group by
	datediff(dd, o.OrderDT, o.ShipDT)
having
	datediff(dd, o.OrderDT, o.ShipDT) >= @MinDaysDelayed
order by 
	ShippingDelayDays desc
GO
/****** Object:  StoredProcedure [dbo].[Product_Ship_Delays_by_Date]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Product_Ship_Delays_by_Date] (
	@StartDT datetime,
	@EndDT datetime
) as

set nocount on;

select
	count(o.OrderID) as NumOrdersImpacted,
	datediff(dd, o.OrderDT, o.ShipDT) as ShippingDelayDays
from
	dbo.[Order] o
	join dbo.OrderLine l on o.OrderID = l.OrderID
	join dbo.Person p on p.PersonID = o.PersonID
	join dbo.SalesRep r on r.SalesRepID = o.SalesRepID
	join dbo.SalesTerritory t on t.SalesTerritoryID = r.SalesTerritoryID
where
	o.OrderDT >= @StartDT
	and o.OrderDT <= @EndDT
group by
	datediff(dd, o.OrderDT, o.ShipDT)
order by 
	ShippingDelayDays desc
GO
/****** Object:  StoredProcedure [dbo].[Sales_By_Territory_Date]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[Sales_By_Territory_Date] (
	@StartDT datetime,
	@EndDT datetime
) as

set nocount on;

select
	t.SalesTerritoryID, 
	t.TerritoryName,
	sum(o.OrderCost) as TotalOrderValue,
	count(o.OrderID) as OrderCount
from
	dbo.[Order] o
	--join dbo.OrderLine l on o.OrderID = l.OrderID
	join dbo.Person p on p.PersonID = o.PersonID
	join dbo.SalesRep r on r.SalesRepID = o.SalesRepID
	join dbo.SalesTerritory t on t.SalesTerritoryID = r.SalesTerritoryID
where
	o.OrderDT >= @StartDT
	and o.OrderDT <= @EndDT
group by
	t.SalesTerritoryID, 
	t.TerritoryName
order by 
	t.TerritoryName asc
GO
/****** Object:  StoredProcedure [dbo].[Sales_By_Territory_Rep_Date]    Script Date: 11/3/2016 8:51:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Sales_By_Territory_Rep_Date] (
	@StartDT datetime,
	@EndDT datetime
) as

set nocount on;

select
	t.SalesTerritoryID, 
	t.TerritoryName,
	r.SalesRepID,
	sum(o.OrderCost) as TotalOrderValue,
	count(o.OrderID) as OrderCount
from
	dbo.[Order] o
	--join dbo.OrderLine l on o.OrderID = l.OrderID
	join dbo.Person p on p.PersonID = o.PersonID
	join dbo.SalesRep r on r.SalesRepID = o.SalesRepID
	join dbo.SalesTerritory t on t.SalesTerritoryID = r.SalesTerritoryID
where
	o.OrderDT >= @StartDT
	and o.OrderDT <= @EndDT
group by
	t.SalesTerritoryID, 
	t.TerritoryName,
	r.SalesRepID
order by 
	t.TerritoryName asc, TotalOrderValue desc
GO
USE [master]
GO
ALTER DATABASE [ColumnstoreNC] SET  READ_WRITE 
GO
