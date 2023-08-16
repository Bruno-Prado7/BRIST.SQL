-- Select the sales in 2021, region Vancouver, Order by Quarter and Line of Product. 
SELECT *
FROM [dbo].[BRI Steel Metal]
WHERE YEAR = '2021' AND REGION = 'Vancouver'
Order by QUARTER Asc, [Line of Product] Desc

-- Select one or another specific customer
SELECT *
FROM [BRI Steel Metal]
WHERE Costumer = 'Tateno Ind & Com Con' OR Costumer = ' Professional Metal Works'

-- Select Distinct Products 
SELECT COUNT(DISTINCT [Product Description])
FROM [BRI Steel Metal];

-- Changing columns’ name 
EXEC sp_rename 'dbo.[BRI Steel Metal].[Year#Month]', 'Month_Year', 'COLUMN';
EXEC sp_rename 'dbo.[BRISteelMetal$].[Line of Product]', 'Line_of_Product', 'COLUMN';
EXEC sp_rename 'All2018Year$.[Year#Month]', 'Month_Year', 'COLUMN';
EXEC sp_rename 'All2022Year$.[Year#Month]', 'Month_Year', 'COLUMN';
EXEC sp_rename 'All2018Year$.[Sales Rep#]', 'Sales_Rep', 'COLUMN';
EXEC sp_rename 'All2022Year$.[Sales Rep#]', 'Sales_Rep', 'COLUMN';

-- Updating the column Quality by removing unnecessary spaces.  
UPDATE [dbo].[BRISteelMetal$]
SET Quality = LTRIM(RTRIM(Quality));

-- Round up the values of two columns. 
UPDATE [dbo].[BRISteelMetal$]
SET SalesT = ROUND(SalesT, 2);

UPDATE [dbo].[BRISteelMetal$]
SET Mkp = ROUND (Mkp, 2)

-- Results for two specific product quality of two sales representatives.  
SELECT *
FROM [dbo].[BRI Steel Metal]
WHERE Quality IN ('Cold Rolled 1018', '6061') 
AND [Sales Rep#] IN ('Bruno Camargo', 'John Henry')

-- Select customers with the name “Generator”, Region = Vancouver and sales above 1 ton. 
SELECT *
FROM [dbo].[BRISteelMetal$]
WHERE Costumer like '%Generator%' 
and Region = 'Vancouver' 
and SalesT > '1'
Order by Customer


-- Select the sales in 2023 per region. 
SELECT Region, ROUND(SUM (SalesT), 1) as "TotalperRegion"
FROM [dbo].[BRISteelMetal$]
WHERE Year = '2023'
GROUP BY Region
ORDER BY TotalperRegion Desc


-- Select the AVG of SalesT, Line of Product = Mild Steel and Quarter = Q4
SELECT Line_of_Product, ROUND(AVG(SalesT), 1) AS "LineofProductAVG"
FROM [dbo].[BRISteelMetal$]
WHERE Line_of_Product = 'Mild Steel' AND Quarter = 'Q4'
GROUP BY Line_of_Product;

-- Select the total Sales of two specific Products (Quality)
SELECT Quality, ROUND(SUM (SalesT),0) as "Quality(Total))"
FROM [dbo].[BRISteelMetal$]
GROUP BY Quality
HAVING Quality = 'Hot Rolled' or Quality = '6061'

-- Select the total Sales of two specific Products (Quality), adding the year 2022. 
SELECT Quality, ROUND(SUM(SalesT), 0) AS "Quality(Total)"
FROM [dbo].[BRISteelMetal$]
WHERE (Quality = 'Hot Rolled' OR Quality = '6061') AND Year = '2022'
GROUP BY Quality;

-- Select the customer who had purchased in 2018 and 2022. 
SELECT *
FROM All2018Year$
INNER JOIN All2022Year$
ON All2018Year$.Custumer = All2022Year$.Customer; 

-- Select the customer who had purchased in 2018 and 2022, sorted out by column, Sales Representative and Sales. 
SELECT c.customer, c.Sales_Rep, c.Sales_T
FROM All2018Year$ as c
INNER JOIN All2022Year$ as m
ON c.customer = m.customer

-- Select the customer who had purchased in 2018 and 2022, sorted out by column, Sales Representative and Sales, also deleting “Nulls” 
SELECT Customer, Sales_Rep, Round (Sales_T,1)
FROM All2018Year$
WHERE Customer IS NOT NULL AND Sales_Rep IS NOT NULL AND Sales_T IS NOT NULL
UNION
SELECT Customer, Sales_Rep, Round (Sales_T,1)
FROM All2022Year$
AS TotalSales

-- Select only the prices over average in 2021
SELECT *
FROM BRISteelMetal$
WHERE PriceperTon > 
(SELECT AVG(PriceperTon) FROM BRISteelMetal$)
AND YEAR = '2021';

-- Select sales from 2018 for customers who purchased the 'Structural' product in 2022
SELECT Customer, Quality, Sales_Rep, Year, ROUND(Sales_T, 1)
FROM All2018Year$
WHERE Quality IN (
SELECT Quality
FROM All2022Year$
WHERE Quality = 'Structural')
ORDER BY Customer Asc

-- Remove tables that are not being used.
ALTER TABLE [dbo].[BRISteelMetal$]
DROP COLUMN [RANDOMLY - COPY 1];

ALTER TABLE [dbo].[BRISteelMetal$]
DROP COLUMN [PRODUCT "LEN" 2], [LINE - CLEAN 1], [LINE - CLEAN 2], [LINE - CLEAN 3 (FINAL)], [QUAL - CLEAN 1], [QUAL - CLEAN 2], [QUAL - CLEAN 3 (FINAL)]

-- Customer's name and region in the same column as a specific Sales Representative. 
SELECT 
CONCAT (Customer, ' ',Region) as CustomerandRegion
FROM [dbo].[BRISteelMetal$]
WHERE Year = '2022' AND [Sales Rep#] = 'Alejandra Angel'

-- Adding the average distance between the customer and the factory to better define the prices, being one of the costs = freight cost.
ALTER TABLE [dbo].[BRISteelMetal$]
ADD CalculatedDistance INT;

UPDATE [dbo].[BRISteelMetal$]
SET CalculatedDistance = 
    IIF(Region IN ('Burnaby'), 5,
    IIF(Region IN ('North Vancouver', 'Vancouver'), 10,
    IIF(Region IN ('Richmond'), 12,
    IIF(Region IN ('Delta', 'New Westminster', 'Surrey', 'West Vancouver'), 15,
    IIF(Region IN ('Port Coquitlam'), 18,
    IIF(Region IN ('Anmore', 'Belcarra', 'Coquitlam', 'Lions Bay', 'Maple Ridge', 'Pitt Meadows', 'Port Moody', 'Tsawwassen', 'White Rock'), 20,
    IIF(Region IN ('Langley'), 25, 0)))))));

-- Adding new data
INSERT INTO [dbo].[BRISteelMetal$] (Customer, Sales_Rep, Month_Year, Year, Quarter)
VALUES ('VancouverSteel', 'Mary Rogers', 'March.2023', 2023, 'Q1')

