-- Zomato Data Analysis Usinf SQl
-- Customers Table
create table customers
	(
	customer_id int PRIMARY key ,
	customer_name  VARCHAR(40),
	Gender VARCHAR(6),
	reg_date date
	) ;

-- create restaurant table
drop table if Exists restaurant;
create table restaurant
	(
	id_restaurant  int PRIMARY key ,
	restaurant_name VARCHAR(60),
	city VARCHAR(15),
	opining_hour VARCHAR(25)
	) ;

-- create orders table	
drop table if Exists orders;
create table orders
	(
	order_id int PRIMARY key ,
	customer_id int , -- this coming from customer table 
	id_restaurant int , -- this comin from restaurant table
	order_date date ,
	order_time TIME ,
	items VARCHAR(80),
	price float ,
	sales_qty int ,
	sales_amount float , 
	orders_status varchar(20)
	) ;

-- adding fk_customer CONSTRAINT
ALTER TABLE orders
add constraint fk_customers
FOREIGN key (customer_id)
REFERENCES customers(customer_id);

-- adding fk_restaurant constraint
ALTER TABLE orders
ADD constraint fk_restaurant
FOREIGN key(id_restaurant)
REFERENCES restaurant(id_restaurant) ;

-- create table riders
create table riders
	(
	riders_id int PRIMARY key ,
	rider_name VARCHAR(25) ,
	sign_up date
	) ;
-- create delivey table 
DROP TABLE if exists delivery ;
create table delivery
	(
	delivery_id int PRIMARY key,
	order_id int ,-- this coming from order table
	delivery_status	varchar(25),
	riders_id int ,--this coming from riders table
	delivery_time time ,
	CONSTRAINT fk_order FOREIGN key(order_id) REFERENCES orders(order_id) ,
	constraint fk_riders FOREIGN key(riders_id) REFERENCES riders(riders_id)
	);


insert into restaurant VALUEs
(1	,'8AM TIFFINS'	,'Adilabad'	,'10:00 AM - 11:00 PM') ;


