-- In this lab, you will be using the Sakila database of movie rentals.
use sakila;

-- Write the SQL queries to answer the following questions:

-- Select the first name, last name, and email address of all the customers who have rented a movie.
select first_name, last_name, email from sakila.customer
where active=1;

-- What is the average payment made by each customer (display the customer id, customer name (concatenated), and the average payment made)
select c.customer_id, concat(c.first_name,' ',c.last_name) as customer_name, round(avg(p.amount),3) as average_payment from sakila.customer as c 
join sakila.payment as p on c.customer_id=p.customer_id
group by c.customer_id
order by average_payment desc;

-- Select the name and email address of all the customers who have rented the "Action" movies.

-- Write the query using multiple join statements
select distinct(concat(c.first_name,' ',c.last_name)) as customer_name, c.email, ca.name as category_name from sakila.customer as c 
join sakila.rental as r on c.customer_id=r.customer_id
join sakila.inventory as i on r.inventory_id=i.inventory_id
join sakila.film_category as fc on i.film_id=fc.film_id
join sakila.category as ca on fc.category_id=ca.category_id
where ca.name='Action'
order by customer_name;

-- Write the query using sub queries with multiple WHERE clause and IN condition

/*select concat(c.first_name,' ',c.last_name) as customer_name, c.email, ca.name as category_name 
from sakila.customer as c 
join sakila.rental as r on c.customer_id=r.customer_id
join sakila.inventory as i on r.inventory_id=i.inventory_id
join sakila.film_category as fc on i.film_id=fc.film_id
join sakila.category as ca on fc.category_id=ca.category_id
where ca.category_id in (
select category_id from sakila.category 
where name='Action'
);*/
select concat(first_name,' ',last_name) as customer_name, email from sakila.customer 
where customer_id in
(
select distinct(customer_id) from sakila.rental
where customer_id in
(
select inventory_id 
from sakila.inventory
where inventory_id in 
(
select film_id
from sakila.film_category
where category_id in
(
select category_id from sakila.category 
where name='Action'
))))
order by customer_name;

-- Verify if the above two queries produce the same results or not
-- We have a part of same results 

-- Use the case statement to create a new column classifying existing columns as either or high value transactions based on the amount of payment.
-- If the amount is between 0 and 2, label should be low and if the amount is between 2 and 4, the label should be medium, and if it is more than 4,
-- then it should be high.
select customer_id, average_payment,
	   avg(case when average_payment >= 0 and average_payment < 2 then average_payment else 0 end) as low, 
	   avg(case when average_payment >= 2 and average_payment < 4 then average_payment else 0 end) as 'medium',
	   avg(case when average_payment >= 4 then average_payment else 0 end) as high
from (
select c.customer_id, concat(c.first_name,' ',c.last_name) as customer_name, round(avg(p.amount),3) as average_payment from sakila.customer as c 
join sakila.payment as p on c.customer_id=p.customer_id
group by c.customer_id
order by average_payment desc
) sub1
group by customer_id
order by customer_id;