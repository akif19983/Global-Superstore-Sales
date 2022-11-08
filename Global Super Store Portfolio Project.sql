-- Master table
Select *
From [Global Super Store Project]..Global_Superstore

--To find out the frequency of purchase for each customer

Select [Customer ID], COUNT([Customer ID]) as FrequencyOfPurchase
FROM [Global Super Store Project]..Global_Superstore
Group by [Customer ID]
Order by FrequencyOfPurchase desc

-- To find out the relation between Frequency of Purchase and the Profit

Drop Table if exists #FoPvsProfit
CREATE TABLE #FoPvsProfit
(
CustomerID nvarchar(255),
FoP int,
Profit int
)
Insert into #FoPvsProfit
Select [Customer ID], COUNT([Customer ID]) as FrequencyOfPurchase, SUM(Profit) as ProfitForCustomer
FROM [Global Super Store Project]..Global_Superstore
Group by [Customer ID]

ALTER TABLE #FoPvsProfit
DROP Column CustomerID

Select *
From #FoPvsProfit

Select Fop, COUNT(FoP) as NumberofCustomerwithSameFoP, AVG(Profit) as Profit
From #FoPvsProfit
Group by FoP
Order by FoP desc

-- Most Profittable Segment for Each Year

Update [Global Super Store Project]..Global_Superstore
Set [Order Date] = CAST([Order Date] as date)

With SegmentProfitPerYear(OrderYear, Segment, TotalProfit)
as
(
Select Year([Order Date]) as OrderYear, Segment, Profit
From [Global Super Store Project]..Global_Superstore
)
Select OrderYear, Segment, SUM(TotalProfit) YearlyTotalProfitPerSegment
From SegmentProfitPerYear
Group By OrderYear, Segment
Order by OrderYear, Segment

-- Distribution of Customer Across Country

Select Country, COUNT([Order ID]) as NumberOfCustomerPerCountry
From [Global Super Store Project]..Global_Superstore
Group by Country
Order by Country asc

-- Country Top Sales

Select Country, SUM(Sales) as SalesPerCountry
From [Global Super Store Project]..Global_Superstore
Group by Country
Order by SalesPerCountry desc

-- Top product profit making based on yearly

ALTER TABLE [Global Super Store Project]..Global_Superstore
Drop Column OrderYear

Drop Table if exists #OrderYearTable
CREATE TABLE #OrderYearTable
(
OrderID nvarchar(255),
OrderYear int,
)

Insert into #OrderYearTable
Select [Order ID], Year([Order Date])
From [Global Super Store Project]..Global_Superstore

Select*
From #OrderYearTable


With TopProduct(OrderYear, ProductName, TotalProductProfit, TopProductforEachYear)
as
(
Select OrderYear, [Product Name], SUM(Profit), Rank () OVER (PARTITION BY OrderYear Order By SUM(Profit) desc) as TopProductPerYear
From #OrderYearTable OYT
JOIN [Global Super Store Project]..Global_Superstore GSSP
	ON OYT.OrderID = GSSP.[Order ID]
Group by OrderYear, [Product Name]
)
Select OrderYear, ProductName, TotalProductProfit, TopProductforEachYear
From TopProduct
Where TopProductforEachYear <= 5


















