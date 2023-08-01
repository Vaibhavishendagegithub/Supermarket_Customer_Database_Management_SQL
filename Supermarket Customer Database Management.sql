create database Supermarket;

use Supermarket;
 drop table sales
 
create table Sales(
user_id int,
purchase_date varchar (20),
product_id int 
);

insert into sales(user_id, purchase_date, product_id) 
values
(1,"2017-04-19",2),
(3,"2019-12-18",1),
(2,"2020-07-20",3),
(1,"2019-10-23",2),
(1,"2018-03-19",3),
(3,"2016-12-20",2),
(1,"2016-11-09",1),
(1,"2016-05-20",3),
(2,"2017-09-24",1),
(1,"2017-03-11",2),
(1,"2016-03-11",1),
(3,"2016-11-10",1),
(3,"2017-12-22",2),
(3,"2016-12-15",2),
(2,"2018-11-08",2),
(2,"2018-09-10",3);


select * from Sales;

select count(purchase_date) from sales;

drop table product;

create table Product(
product_id int,
product_name varchar(30),
price int);

insert into Product(product_id, product_name, price) 
values
(1,"P1",980),
(2,"P2",870),
(3,"P3",330);

select * from product;

drop table  goldusers_signup;

create table goldusers_signup(
user_id int,
gold_signup_date varchar(20));

insert into goldusers_signup(user_id, gold_signup_date) 
values
(1, "2017-09-22"),
(3, "2017-04-21");

select * from goldusers_signup;

drop table users;

create table users(
user_id int,
signup_date varchar(20));

insert into users(user_id, signup_date) 
values
(1, "2014-09-02"),
(2, "2015-01-15"),
(3, "2014-04-11");

select * from Sales;
select * from product;
select * from goldusers_signup;
select * from users;

# 1.  What is the total amount each customer spent on Supermaket?

select a.user_id, sum(b.price) as total_amt_spent from sales as a inner join Product as b on a.product_id=b.product_id
group by a.user_id;

# 2. How many days has each customer visited Supermarket?

select user_id, count(distinct purchase_date) as distinct_days from sales group by user_id;

# 3. What was the first product purchased by each customer?

select * from 
(select *, rank() over(partition by user_id order by purchase_date) rnk from sales) a where rnk= 1;

# 4. What was the most purchased item on the menu and how many times was it purchased by all customers?

select product_id, count(product_id) from sales group by product_id order by count(product_id) desc limit 1; 
 
 # 4a. What was the most purchased item on the menu?
 
select product_id from sales group by product_id order by count(product_id) desc limit 1; 

# 5. Which item was the most popular for each customer?
  
  select * from 
  (select *,rank() over(partition by user_id order by cnt desc) rnk from
  (select user_id, product_id, count(product_id) cnt from sales group by user_id, product_id)a)b where rnk = 1;
 
 # 6. Which item was purchased first by the customer after they became a member ?
 
 select * from
 (select c.*,rank() over(partition by user_id order by purchase_date) rnk from 
 (select a.user_id, a.purchase_date, a.product_id, b.gold_signup_date from sales a inner join
 goldusers_signup b on a.user_id=b.user_id and purchase_date>=gold_signup_date) c)d where rnk=1;
 
  # 7. Which item was purchased first by the customer before they became a member ?
  
  select * from
 (select c.*,rank() over(partition by user_id order by purchase_date desc) rnk from 
 (select a.user_id, a.purchase_date, a.product_id, b.gold_signup_date from sales a inner join
 goldusers_signup b on a.user_id=b.user_id and purchase_date<=gold_signup_date) c)d where rnk=1;
 
 # 8. What is the total orders and amount spent for each member before they became a member?
 
 select user_id, count(purchase_date) order_purchased, sum(price) total_spent from
 (select c.*,d.price from
 (select a.user_id, a.purchase_date, a.product_id, b.gold_signup_date from sales a inner join
 goldusers_signup b on a.user_id=b.user_id and purchase_date<=gold_signup_date)c inner join product d on c.product_id=d.product_id)e
 group by user_id; 
 
 # 9. If buying each product  generates points for eg 5rs=2 zomato point and eah product has different purchasing points for eg for p1 5rs=1 zomato point,p2 10rs =5 zomato point and p3 5rs=1 zomato point, 
 # 9 a. Calculate points collected by each customers .
 
 select user_id, sum(total_points) from
 (select e.*, amt/points total_points from
 (select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
 (select c.user_id, c.product_id,sum(price) amt from
 (select a.*, b.price from sales a inner join product b on a.product_id=b.product_id)c
 group by user_id, product_id)d)e)f group by user_id;
 
 # 9 b. Calculate total money earn by each customers .
 
 select user_id, sum(total_points) *2.5 total_money_earned from
 (select e.*, amt/points total_points from
 (select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
 (select c.user_id, c.product_id,sum(price) amt from
 (select a.*, b.price from sales a inner join product b on a.product_id=b.product_id)c
 group by user_id, product_id)d)e)f group by user_id;
 
 # 9 c. for which product most points have been given till now.
 
select * from
(select * , rank() over(order by total_point_earned desc)rnk from
(select product_id, sum(total_points)total_point_earned from
 (select e.*, amt/points total_points from
 (select d.*, case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from
 (select c.user_id, c.product_id,sum(price) amt from
 (select a.*, b.price from sales a inner join product b on a.product_id=b.product_id)c
 group by user_id, product_id)d)e)f group by product_id)f) g where rnk=1;  
 
# 10. Rank all the transcation of the customers.

select*, rank() over(partition by user_id order by purchase_date)rnk from sales;

# 11. Rank all the transactions for each member whenever they are a zomato gold member for every for every non gold member transction mark should as NA.

select c.*, case when gold_signup_date is null then 'NA' else rank() over(partition by user_id order by purchase_date desc) end as rnk from 
(select a.user_id, a.purchase_date, a.product_id, b.gold_signup_date from sales a left join
 goldusers_signup b on a.user_id=b.user_id and purchase_date>=gold_signup_date)c;