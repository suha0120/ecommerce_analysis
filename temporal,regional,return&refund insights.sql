use final_project_ecommerce;

-- 4.	Temporal Trends

-- 4.1.	What are the monthly sales trends over the past year?
select year(orderdate) as `year`,
       month(orderdate) as `month`,
       sum(od.quantity*p.price) as revenue
from orders o
join orderdetails od on od.orderid = o.orderid 
join products p on p.productid = od.productid 
where orderdate >= current_date() - interval 12 month
group by `year`,`month`
order by `year`,`month`;



-- 4.2.	How does the average order value (AOV) change by month or week?

select date_format(orderdate,"%Y-%m") as period ,
        round(sum(od.quantity*p.price)/count(distinct(o.orderid)),2) as AOV
from orders o
join orderdetails od on od.orderid = o.orderid 
join products p on p.productid = od.productid 
group by period
order by period;

        












-- 5.	Regional Insights
-- 5.1.	Which regions have the highest order volume and which have the lowest?
select Regionname, count(orderid) as ordervolume
from orders o 
join customers c on c.customerid = o.customerid 
join regions r on r.regionid = c.regionid
group by Regionname
order by ordervolume desc;






-- 5.2.	What is the revenue per region and how does it compare across different regions?
select Regionname, sum(od.quantity*p.price) as totalrevenue
from orders o 
join customers c on c.customerid = o.customerid 
join regions r on r.regionid = c.regionid
join orderdetails od on od.orderid = o.orderid
join products p on p.productid = od.productid
group by Regionname
order by totalrevenue desc;


-- bonus (5.1+5.2)

with T1 as (
            select Regionname, count(orderid) as ordervolume
			from orders o 
			join customers c on c.customerid = o.customerid 
			join regions r on r.regionid = c.regionid
			group by Regionname
			order by ordervolume desc
),

T2 as (

        select Regionname, sum(od.quantity*p.price) as totalrevenue
		from orders o 
		join customers c on c.customerid = o.customerid 
		join regions r on r.regionid = c.regionid
		join orderdetails od on od.orderid = o.orderid
		join products p on p.productid = od.productid
		group by Regionname
		order by totalrevenue desc

)

select T1.RegionName,ordervolume,totalrevenue
from T1
join T2 on T2.RegionName = T1.RegionName;








-- 6.	Return & Refund Insights
-- 6.1.	What is the overall return rate by product category?
select category,
      round(sum(case when isreturned = 1 then 1 else 0 end)/count(o.orderid),2) as Returnrate
from orders o 
join orderdetails od on od.orderid = o.orderid 
join products p on p.productid = od.productid 
group by category
order by Returnrate desc;






-- 6.2.	What is the overall return rate by region?

select RegionName,
      round(sum(case when isreturned = 1 then 1 else 0 end)/count(o.orderid),2) as Returnrate
from orders o 
join customers c on c.customerid = o.customerid
join regions r on r.regionid = c.regionid 
group by RegionName
order by Returnrate desc;



-- 6.3.	Which customers are making frequent returns?
select c.CustomerID,c.CustomerName,count(o.orderid) as Returncount
from orders o 
join customers c on c.CustomerID= o.CustomerID
where isreturned = 1
group by c.CustomerID,c.CustomerName
order by Returncount desc
limit 10;


