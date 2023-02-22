SELECT * FROM dbo.Sheet1$

---Erasing Unnecessary data
ALTER TABLE dbo.Sheet1$
DROP COLUMN F17,
F18,
F19,
F20,
F21,
F22,
F23,
F24,
F25,
F26,
F27,
F28,
F29,
F30,
F31,
F32,
F33,
F34,
F35,
F36,
F37,
F38,
F39,
F40,
F41,
F42,
F43,
F44,
F45,
F46,
F47,
F48,
F49,
F50,
F51,
F52,
F53,
F54,
F55,
F56,
F57,
F58,
F59,
F60,
F61,
F62,
F63;


---Profit for White shoes for 2016/Last Sale. Can also find Average for white shoes
---using AVG in Tableau
SELECT [Sneaker Name], [Jordan/NMD], [Retail Price], ([2016]-[Retail Price]) AS '2016 Profit', ([Last Sale]-[Retail Price]) AS 'Last Profit', Colorway1, Colorway2
FROM Sheet1$
CROSS APPLY (Values(REVERSE(PARSENAME(REPLACE(REVERSE(Colorway), '/', '.'), 1)),
	REVERSE(PARSENAME(REPLACE(REVERSE(Colorway), '/', '.'), 2))))S([Colorway1],[Colorway2])
WHERE S.[Colorway1] LIKE '%white%' OR S.[Colorway2] LIKE '%white%'

---Profit for Black shoes for 2016/Last Sale. Can also find Average for white shoes
---using AVG in Tableau
SELECT [Sneaker Name], [Jordan/NMD], [Retail Price], ([Last Sale]-[Retail Price]) AS 'Last Profit', ([2016]-[Retail Price]) AS '2016 Profit', Colorway1, Colorway2
FROM Sheet1$
CROSS APPLY (Values(REVERSE(PARSENAME(REPLACE(REVERSE(Colorway), '/', '.'), 1)),
	REVERSE(PARSENAME(REPLACE(REVERSE(Colorway), '/', '.'), 2))))S([Colorway1],[Colorway2])
WHERE S.[Colorway1] LIKE '%black%' OR S.[Colorway2] LIKE '%black%'


-------------Rolling Total For Last Sale Profit
SELECT [Sneaker Name], [Release Date], [Retail Price], [Last Sale], Profit,
SUM(CAST(Profit AS BIGINT)) OVER (ORDER BY [Release Date])
FROM (SELECT [Last Sale]-[Retail Price] AS Profit, *
FROM Sheet1$)
t

-------------Rolling Total For 2016 Profit
SELECT [Sneaker Name], [Release Date], [Retail Price], [2016], Profit,
SUM(CAST(Profit AS BIGINT)) OVER (ORDER BY [Sneaker Name])
FROM (SELECT [2016]-[Retail Price] AS Profit, *
FROM Sheet1$)
t

SELECT * FROM Sheet1$

---Rolling Sum for 2016 and Last Sale Profit
SELECT [Sneaker Name],[Jordan/NMD], [Release Date], [Last Sale Profit], [2016 Profit],
SUM(CAST([Last Sale Profit] AS BIGINT)) OVER (ORDER BY [Release Date]) AS 'Rolling Last',
SUM(CAST([2016 Profit] AS BIGINT)) OVER (ORDER BY [Release Date]) AS 'Rolling 2016'
FROM (SELECT [Last Sale]-[Retail Price] AS [Last Sale Profit], 
[2016]-[Retail Price] AS [2016 Profit],*
FROM Sheet1$)
t

---Top 5 Selling Jordan Brands in 2016
SELECT TOP 5 [Model ], SUM([2016]-[Retail Price]) AS 'Total SUM' FROM Sheet1$
WHERE [Sneaker Name] LIKE '%Jordan%'
Group BY [Model ]
ORDER BY [Total SUM] DESC


---Top 5 Selling Adidas Brands in 2016
SELECT TOP 5 [Model ], SUM([2016]-[Retail Price]) AS 'Total SUM' FROM Sheet1$
WHERE [Sneaker Name] LIKE '%Adidas%'
Group BY [Model ]
ORDER BY [Total SUM] DESC

---Top 5 Selling Jordan Brands in Last Sale
SELECT TOP 5 [Model ], SUM([Last Sale]-[Retail Price]) AS 'Total SUM' FROM Sheet1$
WHERE [Sneaker Name] LIKE '%Jordan%'
Group BY [Model ]
ORDER BY [Total SUM] DESC

---Top 5 Selling Adidas Brands in Last Sale
SELECT TOP 5 [Model ], SUM([Last Sale]-[Retail Price]) AS 'Total SUM' FROM Sheet1$
WHERE [Sneaker Name] LIKE '%Adidas%'
Group BY [Model ]
ORDER BY [Total SUM] DESC

---Top 20 Shoes in Last Sale
SELECT TOP 20 [Model ], [Jordan/NMD], SUM([Last Sale]-[Retail Price]) AS 'Last Sale Profit' FROM Sheet1$
Group BY [Model ], [Jordan/NMD]
ORDER BY [Last Sale Profit] DESC

---Top 20 Shoes in 2016
SELECT TOP 20 [Model ], [Jordan/NMD], SUM([2016]-[Retail Price]) AS '2016 Profit' FROM Sheet1$
Group BY [Model ], [Jordan/NMD]
ORDER BY [2016 Profit] DESC