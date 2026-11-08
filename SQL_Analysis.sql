USE AdventureWorksDW2025;
GO

-- 1. SALES ANALYSIS USING JOINS

SELECT
    F.SalesOrderNumber,
    F.OrderDate,
    C.FirstName,
    C.LastName,
    P.EnglishProductName,
    F.OrderQuantity,
    F.SalesAmount
FROM dbo.FactInternetSales AS F
INNER JOIN dbo.DimCustomer AS C
    ON F.CustomerKey = C.CustomerKey
INNER JOIN dbo.DimProduct AS P
    ON F.ProductKey = P.ProductKey
INNER JOIN dbo.DimDate AS D
    ON F.OrderDateKey = D.DateKey
ORDER BY
    F.OrderDate;
GO


-- 2. SALES PERFORMANCE ANALYSIS

SELECT
    COUNT(DISTINCT SalesOrderNumber) AS TotalOrders,
    SUM(SalesAmount) AS TotalRevenue,
    SUM(TotalProductCost) AS TotalCost,
    SUM(SalesAmount - TotalProductCost) AS TotalProfit,
    CAST(
        SUM(SalesAmount - TotalProductCost) * 100.0 /
        NULLIF(SUM(SalesAmount), 0)
        AS DECIMAL(10,2)
    ) AS ProfitMarginPercentage
FROM dbo.FactInternetSales;
GO


-- 3. MONTHLY SALES TREND

SELECT
    D.CalendarYear,
    D.MonthNumberOfYear,
    D.EnglishMonthName,
    SUM(F.SalesAmount) AS MonthlyRevenue
FROM dbo.FactInternetSales AS F
INNER JOIN dbo.DimDate AS D
    ON F.OrderDateKey = D.DateKey
GROUP BY
    D.CalendarYear,
    D.MonthNumberOfYear,
    D.EnglishMonthName
ORDER BY
    D.CalendarYear,
    D.MonthNumberOfYear;
GO


-- 4. CTE AND WINDOW FUNCTIONS

WITH CategorySales AS
(
    SELECT
        PC.EnglishProductCategoryName AS CategoryName,
        SUM(F.SalesAmount) AS TotalRevenue
    FROM dbo.FactInternetSales AS F
    INNER JOIN dbo.DimProduct AS P
        ON F.ProductKey = P.ProductKey
    INNER JOIN dbo.DimProductSubcategory AS PS
        ON P.ProductSubcategoryKey = PS.ProductSubcategoryKey
    INNER JOIN dbo.DimProductCategory AS PC
        ON PS.ProductCategoryKey = PC.ProductCategoryKey
    GROUP BY
        PC.EnglishProductCategoryName
)
SELECT
    CategoryName,
    TotalRevenue,
    RANK() OVER (
        ORDER BY TotalRevenue DESC
    ) AS RevenueRank
FROM CategorySales
ORDER BY
    RevenueRank;
GO



