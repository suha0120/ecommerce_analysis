use final_project_ecommerce;


-- 2.	Customer Insights
-- 2.1.	Who are the top 10 customers by total revenue spent?
select c.CustomerID,c.CustomerName, sum(od.Quantity*p.Price) as total_revenue
from customers c 
join orders o  on o.customerid = c.customerid
join orderdetails od on od.Orderid = o.Orderid
join products p on od.ProductID = p.ProductID
group by c.CustomerID,c.CustomerName
order by total_revenue desc
limit 10;



-- 2.2.	What is the repeat customer rate?  [ repeat customer rate = (customer with more than 1 order) / (customer with at least 1 order) 
select round(count(distinct case when order_count>1 then customerId end) / count(distinct customerId),2) as repeat_customer_rate
from (select CustomerId , count(OrderId) as order_count
	  from orders
	  group by CustomerId
) as T;



-- 2.3.	What is the average time between two consecutive orders for the same customer Region-wise?
with rankedorders as (
		select o.CustomerId,o.OrderDate,c.RegionID,
               row_number() over(partition by o.CustomerId order by o.OrderDate) as rn
		from orders o
        join customers c on c.customerId = o.customerId
),

OrdersPairs as (
	  select curr.customerId,curr.RegionID,datediff(curr.Orderdate,`prev`.orderdate)as daysbetween
	  from rankedorders curr
      join rankedorders `prev` on curr.customerId = `prev`.customerId and curr.rn = `prev`.rn + 1
),

Region as(
		  select customerId,RegionName,daysbetween
		  from OrdersPairs op
		  join regions r on r.RegionID = op.RegionID
)

select regionname, avg(daysbetween) as averagedaysbetween
from Region
group by regionname
order by averagedaysbetween ;


-- 2.4.	Customer Segment (based on total spend)
-- •	Platinum: Total Spend > 1500
-- •	Gold: 1000–1500
-- •	Silver: 500–999
-- •	Bronze: < 500
select c.customerid,sum(od.Quantity * p.Price) AS total_spend,
	CASE
        WHEN SUM(od.Quantity * p.Price) > 1500 THEN 'Platinum'
        WHEN SUM(od.Quantity * p.Price) BETWEEN 1000 AND 1500 THEN 'Gold'
        WHEN SUM(od.Quantity * p.Price) BETWEEN 500 AND 999 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_segment
from customers c
join  orders o on o.CustomerID=c.CustomerID
join orderdetails od on od.OrderID=o.OrderID
join products p on p.ProductID = od.ProductID
group by c.customerid;



-- 2.5.	What is the customer lifetime value (CLV)? [CLV = customerlifetimevalue = total revenue per customer ]

select  c.customerid,c.customername,sum(od.Quantity * p.Price) as CLV
from customers c
join  orders o on o.CustomerID=c.CustomerID
join orderdetails od on od.OrderID=o.OrderID
join products p on p.ProductID = od.ProductID
group by  c.customerid,c.customername
order by CLV desc;