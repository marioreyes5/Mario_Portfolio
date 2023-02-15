SELECT * FROM ['Raw Data$']

---Total Sales, Retail, and Profit Price Per Region
SELECT [Buyer Region], SUM([Sale Price]) AS 'Total Sales Price', 
SUM([Retail Price]) AS 'Total Retail Price', 
SUM([Sale Price]-[Retail Price]) AS 'Total Profit'
FROM ['Raw Data$']
GROUP BY [Buyer Region]
ORDER BY SUM([Sale Price]) DESC


-------Most Common shoe
SELECT [Buyer Region],[Shoe Size], COUNT([Shoe Size]) AS 'Total Count' FROM ['Raw Data$']
GROUP BY [Shoe Size], [Buyer Region]
ORDER BY 'Total Count' DESC



---Total Profit, %, and number of sale per Shoe
SELECT [Sneaker Name], COUNT(*) AS 'Total Transactions', SUM([Sale Price]-[Retail Price]) AS 'Total Profit',
SUM([Sale Price]-[Retail Price]) * 100.0 / SUM(SUM([Sale Price]-[Retail Price])) OVER () AS Percentage
FROM ['Raw Data$']
GROUP BY [Sneaker Name] 
ORDER BY [Total Profit] DESC

---Rolling profit total per Region For Off White
SELECT [Buyer Region], [Brand], [Order Date], SUM([Sale Price]-[Retail Price])
OVER (partition by [Buyer Region] ORDER BY [Buyer Region], [Order Date])
AS 'Total Profit'  FROM ['Raw Data$']
WHERE [Brand] = 'Off-White'
ORDER BY [Buyer Region], [Order Date] ASC

---Rolling profit total per Region For Yeezy
SELECT [Buyer Region], [Brand], [Order Date], SUM([Sale Price]-[Retail Price])
OVER (partition by [Buyer Region] ORDER BY [Buyer Region], [Order Date])
AS 'Total Profit'  FROM ['Raw Data$']
WHERE [Brand] LIKE '%Yeezy%'
ORDER BY [Buyer Region], [Order Date] ASC


----Total overal Profit
SELECT (SUM([Sale Price]-[Retail Price])) FROM ['Raw Data$']


------Selecting Top Profit Region Using subqueries 
SELECT MAX(Val) AS 'Highest Profit by Region' FROM (SELECT [Buyer Region], 
SUM([Sale Price]-[Retail Price]) AS 'Val' FROM ['Raw Data$']
GROUP BY [Buyer Region]
) t

---Selecting Top Profit Region using LIMIT and adding its % using Window Functions.
SELECT top 1 [Buyer Region], 
SUM([Sale Price]-[Retail Price]) AS 'Val',
SUM([Sale Price]-[Retail Price]) * 100.0 / SUM(SUM([Sale Price]-[Retail Price])) OVER () AS Percentage
FROM ['Raw Data$']
GROUP BY [Buyer Region]
ORDER BY [Val] DESC

