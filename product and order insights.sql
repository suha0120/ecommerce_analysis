use final_project_ecommerce;


-- 3.	Product & Order Insights
-- 3.1.	What are the top 10 most sold products (by quantity)?

SELECT 
    P.ProductId, 
    P.ProductName, 
    SUM(OD.Quantity) AS TotalQty
FROM orderdetails OD
JOIN Products P 
    ON P.ProductId = OD.ProductId
GROUP BY 
    P.ProductId, 
    P.ProductName
ORDER BY TotalQty DESC
LIMIT 10;




-- 3.2.	What are the top 10 most sold products (by revenue)?
SELECT 
    P.ProductId, 
    P.ProductName, 
    SUM(OD.Quantity*P.Price) AS TotalRevenue
FROM orderdetails OD
JOIN Products P 
    ON P.ProductId = OD.ProductId
GROUP BY 
    P.ProductId, 
    P.ProductName
ORDER BY TotalRevenue DESC
LIMIT 10;





-- 3.3.	Which products have the highest return rate? [ highest return rate = Returned Quantity / Total Quantity]


WITH Sold AS (
    SELECT ProductId, SUM(Quantity) AS TotalQty
    FROM orderdetails
    GROUP BY ProductId
),

Returned AS (
    SELECT OD.ProductId, SUM(OD.Quantity) AS TotalQtyReturned
    FROM orderdetails OD
    JOIN orders O 
        ON O.OrderId = OD.OrderId
    WHERE O.isReturned = 1
    GROUP BY OD.ProductId
)

SELECT 
    P.ProductName,
    round(R.TotalQtyReturned / S.TotalQty,2) AS ReturnRate
FROM Products P
JOIN Sold S 
    ON S.ProductId = P.ProductId
JOIN Returned R 
    ON R.ProductId = P.ProductId

order by ReturnRate desc
limit 10;


-- 3.4.	Return Rate by Category

WITH Sold AS (
    SELECT category, SUM(Quantity) AS TotalQty
    FROM orderdetails od
    join products p on p.productid = od.productid
    GROUP BY category
),

Returned AS (
    SELECT category, SUM(OD.Quantity) AS TotalQtyReturned
    FROM orderdetails OD
    JOIN orders O ON O.OrderId = OD.OrderId
    join products p on p.productid = od.productid
    WHERE O.isReturned = 1
    GROUP BY category
)

SELECT s.category,round(R.TotalQtyReturned / S.TotalQty,2) AS ReturnRate
from Sold s 
join Returned r on r.category = s.category
order by ReturnRate desc
limit 10;



-- 3.5.	What is the average price of products per region? [ avg price = total revenue \ total qty ]
select RegionName, round(sum(od.quantity * p.price) / sum(od.quantity),2) as avg_price 
from orders o 
join customers c on c.customerid = o.customerid
join regions r on r.regionid = c.regionid
join orderdetails od on od.orderid = o.orderid
join products p on p.productid = od.productid
group by RegionName
order by avg_price desc;






-- 3.6.	What is the sales trend for each product category?
select date_format(orderdate,"%Y-%m") as period, category,sum(od.quantity*p.price) as revenue
from orders o 
join orderdetails od on od.orderid = o.orderid
join products p on p.productid = od.productid
group by period ,category
order by period,category desc;











