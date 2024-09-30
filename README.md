# Sql Project: Data Analysis For Zoamto - A Food Delivery Compaany

## Overview
This Project demonstrates my Sql problem_solving Skills through the analysis of data for zomato a popular food delivery company in india the project involves setting up the database , impoting data handling null values and solving variety of business problem using complex Sql Query .
![](https://github.com/mina407/Zomato_Sql/blob/main/Zomato_1.png)

## Project Structure

* Database Setup: Creation of the `Zomato_db` database and required tables .
* Data Import: Inserting sample data into the tables .
* Data Cleaning Handl Null Values and ensuring data integrity .
* Business Problem: Solving 20 Specific business problem using sql queries .
  
![](https://github.com/mina407/Zomato_Sql/blob/main/ERD.png)

  ## Database Setup
  ```sql
  Create Database Zomato_db
  ```
## Business Problem Solved

* 1- write a query to fine the top 5 most frequently ordered dishes by customer called 'Claire Ferguson' in the last 1 year .
```sql
select customer_name , order_items , total_orders from (
			select c.customer_id ,
			c.customer_name ,
			o.order_items ,
			count(*) as total_orders,
			dense_rank() over(order by count(*) desc) as rnk
			
		from orders as o
		join customers c 
		on o.customer_id = c.customer_id
		where order_date >= current_date - interval '1 year'
			and customer_name = 'Claire Ferguson'
		group by 1,2,3 ) as temp_
where rnk <=5 ;
```
* write a query to fine popular time slots based on 2 hour .
```sql
select 
	floor(EXTRACT(hour from order_time) / 2) *2 as start_time ,
	floor(extract(hour from order_time) / 2) *2 +2  as end_time ,
	count(*) as total_orders
from orders 
GROUP by 1,2
order by  total_orders desc; 
```
* find the average orders value per customer who has palced more than 25 with respect to quantity
```sql
select c.customer_name ,
	c.customer_id ,
	floor(avg(sales_amount)) as total_revenue ,
	count(*) as total_orders
from orders o
left join customers as c
on c.customer_id = o.customer_id
group by 1,2
having count(*) > 25
order by total_orders desc;
```
* Find hight value customer greater than 25000

```sql
select c.customer_id , c.customer_name ,
	floor(sum(sales_amount)) as total_spent
from orders o
join customers as c
on c.customer_id = o.customer_id
GROUP by 1,2
having sum(sales_amount) > 25000
order by total_spent desc ;
```

* write query to find orders that placed but not delivered return each restaurant_name number of no delivered orders.
```sql
select re.restaurant_name, count(*) as total_not_deliverd
from orders o
left join restaurant re
ON re.id_restaurant = o.id_restaurant
left join delivery as d
on	d.order_id = o.order_id
where d.order_id is null
group by 1;
```
* rank restaurant by thier total revenue from the last year including thier name.
```sql
select *
from
	(select r.restaurant_name , r.city ,
	floor(sum(sales_amount)) as revenue , 
	dense_rank()over(partition by city order by sum(sales_amount) desc) as rnk 
	from orders as o
	left join restaurant as r
	ON r.id_restaurant = o.id_restaurant
	where o.order_date > current_date - interval '1 year'
	group by 1 , 2	) as temp_	
where rnk = 1 ;
```
* identfy the most 2 popular dish in each city
```sql
select * from
		(select r.city , o.order_items,
			count(*) as total_number , 
			dense_rank() over(partition by city order by count(*) desc) as rnk
		from orders as o
		left join restaurant as r
		on r.id_restaurant = o.id_restaurant
		group by 1 , 2 ) as temp_
where rnk <= 2;
```
* write a query to find customers who have orders in 2023 and have no orders in 2024
```sql
select distinct customer_id from orders
	where extract(year from order_date) = 2023
	and customer_id not in 
		(select distinct customer_id from orders where extract(year from order_date) = 2024)

-- insert customer who only order in 2023 and do not in 2024
insert into orders values(1000 ,1001,6,'1/2/2023','12:00:00 AM' ,'Aloo Tikki Burger',40 ,	3 ,	120 ,'Completed')

insert into customers values(1001 , 'Micheal' ,'Male' , '1/2/2023')
```
* write query to caculate and compare the order cancellation rate for each restaurntcurrent year and previous year 
```sql
with 
	cancel_ratio_2023 as(
		select o.id_restaurant ,
		count(o.order_id) total_orders, 
		count(case when d.delivery_id is null then 1 end) as not_delivered
		from orders as o 
		left join delivery as d
		on d.order_id = o.order_id
		where extract(year from order_date) = 2023
		group by 1 ) , 

	cancel_ratio_2024 as(
		select o.id_restaurant ,
		count(o.order_id) total_orders, 
		count(case when d.delivery_id is null then 1 end) as not_delivered
		from orders as o 
		left join delivery as d
		on d.order_id = o.order_id
		where extract(year from order_date) = 2024
		group by 1 ) , 

	last_year_data  as(select *,
		round((not_delivered::numeric / total_orders::numeric)*100 ,2 ) as ratio
		from cancel_ratio_2023 ) , 


	current_year_data  as(select *,
		round((not_delivered::numeric / total_orders::numeric)*100 ,2 ) as ratio
		from cancel_ratio_2024 )
select 
	cd.id_restaurant , 
	cd.ratio as current_year_ratio, 
	ld.ratio as last_year_retio
from current_year_data as cd
join last_year_data as ld
on cd.id_restaurant = ld.id_restaurant
order by 3 desc

-- Rider Average Delivery Time
select  o.order_id ,
		o.order_time ,
		d.delivery_time ,
		d.riders_id , 
		d.delivery_time - o.order_time as time_difference ,
		extract(epoch from (d.delivery_time - o.order_time) + case when d.delivery_time < o.order_time then interval '1 day'
		else interval '0 day' end)/60 time_difference_insec
from orders as o
left join delivery as d
on d.order_id = o.order_id
where delivery_status = 'Delivered'; 
```
* calculate each restaurnt groth ratio 
```sql
select * , round(((total_orders::numeric - pervious::numeric) / pervious::numeric )*100,2)as groth
from (select o.id_restaurant,
	to_char(order_date , 'mm-yy')as month ,
	lag(count(*)) over(partition by o.id_restaurant order by to_char(order_date , 'mm-yy')) as pervious ,
	count(*) as total_orders 
from orders as o
left join delivery as d
on d.order_id = o.order_id
where d.delivery_status = 'Delivered'
	and extract(year from order_date)  = 2024
group by 1 , 2
order by 1,2
) as temp_
```
* segment customer into gold and silver groups based on thier total spending compared to the average order value  if customers total spending exceed the aov label them as gold otherwise lable them as silver
```sql
select
	segmention ,
	floor(sum(total_spent)) as total_revenue, 
	sum(total_orders) as total_orders 
from

	(select customer_id ,
		sum(sales_amount) as total_spent,
		count(*) as total_orders ,
		case 
			WHEN sum(sales_amount) > (select avg(sales_amount) from orders) then 'Gold' else 'Silver'
		end as segmention
	from orders
	group by 1
	) as temp_
group by 1 ;
```
* calculate each riders total monthly earning , assuming they earn 8% of the orders amount .
```sql
select 
	d.riders_id , 
	to_char(order_date , 'mm-yyyy') as month ,
	sum(sales_amount) as revenue ,
	floor(sum(sales_amount) * 0.08) as earning_riders
from orders as o
left join delivery as d
on d.order_id = o.order_id
group by 1 ,2
order by 1 , 2 ;
```
* Find the number of 5_stars 4_satrs and 3_stars rating each rider has if orders delivered less than 15 min rider get 5_stars between 15 and 40 get 4 stars after 40 3 stars
```sql
select 
	riders_id , 
	stars ,
	count(*) as total_stars
from
	(
	select riders_id ,
		delivery_took_time ,
		case 
			when delivery_took_time < 15 then '5_stars'
			when delivery_took_time between 15 and 40 then '4_stars'
			else '3_stars'
		end as stars
	from
		(
		select o.order_id ,
				o.order_time ,
				d.delivery_time ,
				d.riders_id,
				extract(epoch from (d.delivery_time - o.order_time + case when d.delivery_time < o.order_time
				then interval '1 day' else interval '0 day' end ))/60 as delivery_took_time
		from orders as o
		left join delivery as d
		on d.order_id = o.order_id
		where d.delivery_status = 'Delivered'
		) as temp_1
	) as temp_2
	
group by riders_id , stars
order by riders_id ,total_stars
```
* Analyze order frequency per day of the week and identify the peak day for each restaurnt .
```sql
select 
	restaurant_name ,
	day ,
	total_orders 
from
	(
		select 
		r.restaurant_name , 
		to_char(order_date , 'Day') as day ,
		count(*) as total_orders , 
		dense_rank()over(partition by r.restaurant_name order by count(*) desc ) as rnk
		from orders as o
		left join restaurant as r
		on r.id_restaurant = o.id_restaurant
		group by 1 , 2
	) as temp_
where rnk = 1 ;

-- Customer Life Time Value 
select 
	c.customer_id , 
	c.customer_name ,
	floor(sum(o.sales_amount)) as total_revenue 
from orders as o
join customers as c
on o.customer_id = c.customer_id
group by 1 , 2
order by total_revenue desc ;
```
* Identify Sales Trends by comparing each month's total to the previous month 
```sql
select * ,
	concat(floor(((revenue - previous_month) / previous_month) * 100),'%') as groth
from

	(
		select 
			extract(year from order_date) as year ,
			extract(month from order_date) as month ,
			floor(sum(sales_amount)) as revenue ,
			lag(floor(sum(sales_amount)))over(order by extract(year from order_date) ,extract(month from order_date)) as previous_month
			from orders
		group by 1 , 2
	
	) as temp_
```
* Evaluate rider efficiency by determining average delivery time identifying thos with highest and lowest average .
```sql
with cte as
	(
		select 
				d.riders_id as rider_id,
				d.delivery_time , 
				o.order_time , 
				extract(epoch from (d.delivery_time - o.order_time + case when d.delivery_time < o.order_time 
				then interval '1 days' else interval '0 days' end)) /60 as time_deliver
				
		from orders as o
		left join delivery as d
		on d.order_id = o.order_id
		where d.delivery_status = 'Delivered'
	
	) ,
	avg_rider_time as
	(
	select 
		rider_id ,
		round(avg(time_deliver) ,2) avg_time
	from cte 
	group by 1
	)
select 
	max(avg_time) as highest ,
	min(avg_time) as lowest
from avg_rider_time
```
* Track the popularty of specific order item over time and identify seasonal demand .
```sql
select order_items ,
	seasonal ,
	count(*) as total_orders
from
	(select * ,
			extract(month from order_date) as month,
		case 
			when extract(month from order_date) between 4 and 6 then 'Spring'
			when extract(month from order_date) > 6 and extract(month from order_date) < 10 then 'summer'
			else 'Winter'
		end as seasonal
	from orders	
	) as temp_
group by order_items , seasonal
order by 1,3 desc
```
* Rank each city based on the total revenue for last year
```sql
select r.city ,
	floor(sum(o.sales_amount)) as total_revenue , 
	dense_rank()over(order by sum(o.sales_amount) desc) as rnk
from orders as o
left join restaurant as r
on r.id_restaurant = o.id_restaurant
where extract(year from order_date) = 2023
group by 1
```
