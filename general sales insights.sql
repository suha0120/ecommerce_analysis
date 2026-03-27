

-- 1.	General Sales Insights

-- 1.1.	What is the total revenue generated over the entire period? ( revenue is nothing but quantity * price)
select sum(od.quantity*p.price) as total_revenue
from orderdetails od
join products p
on od.ProductID = p.ProductID;

-- 1.2.	Revenue Excluding Returned Orders
select sum(od.quantity *p.price) as Revenue_excluding_return 
from orders o
join orderdetails od
on od.OrderID = o.OrderID
join products p 
on p.ProductID = od.ProductID
where o.IsReturned = False;


-- 1.3.	Total Revenue per Year / Month(extract year and extract month and then group by) 
select year(OrderDate) as `year`,
	   month(OrderDate) as `month`,
       sum(od.quantity * p.price) as MonthlyRevenue
from orders o
join orderdetails od
on od.OrderID = o.OrderID
join products p 
on p.ProductID = od.ProductID
group by `year`,`month`
order by `year`,`month`;




-- 1.4.	Revenue by Product / Category( generate a revenue along with productName and category)
select p.ProductName as `product_name`,p.Category `category`,sum(od.quantity*p.price) as Revenue_By_Category
from orderdetails od
join products p
on od.ProductID = p.ProductID
group by `product_name`,`category`
order by `category`,Revenue_By_Category desc;




-- 1.5.	What is the average order value (AOV) across all orders?(AOV = Total Revenue / Number of Orders)

 SELECT AVG(TotalOrderValue)
 FROM (
		SELECT O.OrderId,
           SUM(OD.quantity * P.Price) AS TotalOrderValue
    FROM orders O
    JOIN orderdetails OD 
        ON OD.OrderId = O.OrderId
    JOIN products P 
        ON P.ProductId = OD.ProductId
    GROUP BY O.OrderId
 ) T;

-- 1.6.	AOV per Year / Month


 SELECT year(T.OrderDate) as `year`,
	   month(T.OrderDate) as `month`,
       AVG(TotalOrderValue)
 FROM (
		SELECT O.OrderId, O.OrderDate,SUM(OD.quantity * P.Price) AS TotalOrderValue
        FROM orders O
        JOIN orderdetails OD 
        ON OD.OrderId = O.OrderId
        JOIN products P 
        ON P.ProductId = OD.ProductId
        GROUP BY O.OrderId
 ) T
 group by `year`,`month`
 order by `year`,`month`;








-- 1.7.	What is the average order size by region? meaning--->Find total value of each order Group orders by region Find average order value for each region
select RegionName,avg(total_order_size) as average_order_size
from (
        select o.orderID,c.RegionID, sum(od.quantity) as total_order_size 
		from orders o
		join customers c
		on c.CustomerID = o.CustomerID
		join orderdetails od
		on od.OrderID = o.OrderID
		group by o.OrderID,c.RegionID

) as ordersizes

join regions r on r.RegionID = ordersizes.RegionID
group by RegionName
order by average_order_size desc;