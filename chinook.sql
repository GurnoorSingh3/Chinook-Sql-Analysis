-
--DROP DATABASE IF EXISTS chinook;
--CREATE DATABASE chinook;
--SELECT COUNT(*) FROM customer;

select * from customer limit 10;
select * from invoice limit 10;
select * from track limit 5;

select first_name as fname , last_name as lname from customer limit 10;

select first_name as fname , last_name as lname , country
from customer 
where country = 'Brazil' or country = 'Germany';

select invoice_id , total

from invoice 
order by total Desc
limit 10;

select distinct country , city
from customer  
order by country , city 
limit 10;

select * from customer 
where country in ('Brazil','Australia','Canada') limit 10;

select * from invoice 
where total between 5 and 10
order by total;

select name from track 
where name like '%love%';

select first_name from customer c
where c.first_name like 'J%';

select first_name from customer c
where c.first_name like 'J___';

select * from customer c where state is null;

select * from customer c where state is not null;

select * from customer c where state = null;

---------------------------------------------------------------------

select count(*) from customer;
select sum(total) from invoice;
select AVG(total) , min(total) , max(total) from invoice;

select count(*) as all_rows , count(state) as has_state from customer;

select country , count(*) as customers
from customer c 
group by c.country 
order by customers desc;

select billing_country , sum(total) as revenue, count(*) as orders
from invoice 
group by billing_country 
order by revenue desc;

select billing_country , sum(total) as revenue, count(*) as orders
from invoice 
group by billing_country 
having count(*) > 10
order by revenue desc;

select billing_country , sum(total) as revenue, count(*) as orders
from invoice 
where billing_country <> 'USA'
group by billing_country 
having count(*) > 10
order by revenue desc;

select invoice_id , total ,
	case 
		when total>=10 then 'Large'
		when total<5 then 'Small'
		else 'medium' 
	end as size_band
from invoice 
limit 20;

-------------------------------------------------------------------------------------------

select c.first_name , i.invoice_id , i.total 
from customer c 
inner join invoice i on c.customer_id = i.customer_id 
limit 20;	

select c.country , SUM(i.total) as revenue , count(*) as orders  
from customer c
inner join invoice i on c.customer_id = i.customer_id
group by c.country 
order by revenue desc ;

select c.first_name , i.invoice_id , i.total 
from customer c 
left join invoice i on c.customer_id = i.customer_id 
limit 20;	

select t.name
from track t 
left join playlist_track pt on t.track_id = pt.track_id
where pt.track_id is null;

SELECT COUNT(*) FROM track;                    -- 3503
SELECT COUNT(DISTINCT track_id) FROM playlist_track;   -- should also be 3503


select c.first_name , i.total 
from customer c
left join invoice i on c.customer_id = i.customer_id 
where i.total > 20;


select c.first_name , i.total 
from customer c
left join invoice i on c.customer_id = i.customer_id and i.total >20;




select e.first_name as employee , m.first_name as manager 
from employee e 
left join employee m on e.reports_to = m.employee_id ;

select e.first_name as employee , m.first_name as manager 
from employee e 
inner join employee m on e.reports_to = m.employee_id ;



select a2.name as artist, SUM(il.unit_price * il.quantity ) as revenue 
from invoice_line il 
join track t on il.track_id = t.track_id
join album a on t.album_id = a.album_id
join artist a2 on a.artist_id = a2.artist_id 
group by artist 
order by revenue desc
limit 25;


select c.first_name , i.total
from customer c 
full outer join invoice i on c.customer_id = i.customer_id
limit 20;

select g.name as genre  , mt.name as media
from genre g 
cross join media_type mt;

select il.invoice_line_id , t.name 
from invoice_line il 
join track t 
on il.track_id = t.track_id 
and il.unit_price = t.unit_price 
limit 50;


select c.first_name  , c.last_name , COALESCE(SUM(i.total), 0) as total_spent 
from customer c
left join invoice i on c.customer_id = i.customer_id
group by c.customer_id , c.first_name , c.last_name
order by total_spent desc;


SELECT g.name, SUM(il.unit_price * il.quantity) AS total_revenue
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY total_revenue DESC
LIMIT 5;

select e.first_name as Name , m.first_name as manager 
from employee e
left join employee m on m.employee_id = e.reports_to;


select  i.billing_country , i.billing_city ,sum(total) as revenue
from invoice i 
group by billing_country , billing_city 
order by billing_country , revenue desc;


select count(*) as invoice_lines,
count(distinct invoice_id) as invoices,
count(distinct track_id) as tracks
from invoice_line il ;

select invoice_id , total ,
	case when total > 15 then 'large'
		 when total < 5 then 'small'
		 else 'med'
	end
from invoice 
;


SELECT CASE WHEN total >= 15 THEN 'Large'
            WHEN total >= 8  THEN 'Medium'
            ELSE 'Small'
       END AS size_band,
       COUNT(*) AS invoices,
       SUM(total) AS revenue
FROM invoice
GROUP BY 1
ORDER BY revenue DESC;


select billing_country , count(*) as invoices ,
sum(case when total >= 10 then 1 else 0 end) as large_invoices ,
sum(case when total < 10 then 1 else 0 end) as small_invoices
from invoice i 
group by billing_country 
order by invoices desc;

SELECT billing_country,
       SUM(CASE WHEN total >= 15 THEN total ELSE 0 END) AS large_revenue,
       SUM(CASE WHEN total <  15 THEN total ELSE 0 END) AS small_revenue,
       Sum(total) total_revenue
FROM invoice
GROUP BY billing_country
order by total_revenue desc;

select first_name , coalesce (state , 'unknown') as state 
from customer c  
limit 25;


SELECT 10 / NULLIF(0, 0);




SELECT COUNT(*)        AS all_rows,
       COUNT(state)    AS state_present,
       COUNT(DISTINCT state) AS distinct_states
FROM customer;

select 5/2;
select 5.0/2;
select 5::numeric/2;
select cast(5 as numeric)/2;


-- wrong
SELECT COUNT(*) / (SELECT COUNT(*) FROM invoice) FROM invoice WHERE total > 10;

-- right
SELECT ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM invoice), 2)
FROM invoice WHERE total > 10;


select distinct extract (year from invoice_date)  from invoice i ;

select billing_country ,
sum(case when extract (year from invoice_date) = 2021 then total else 0 end) as rev_2021,
sum(case when extract (year from invoice_date) = 2022 then total else 0 end) as rev_2022,
sum(case when extract (year from invoice_date) = 2023 then total else 0 end) as rev_2023,
sum(case when extract (year from invoice_date) = 2024 then total else 0 end) as rev_2024,
sum(case when extract (year from invoice_date) = 2025 then total else 0 end) as rev_2025
from invoice 
group by billing_country
order by billing_country;



select invoice_id , total ,
	(select avg(total) from invoice) as avg_total
from invoice
limit 10;


select invoice_id , total 
from invoice 
where total > (select avg(total) from invoice)
order by total desc;

SELECT invoice_id, total,
       (SELECT AVG(total) FROM invoice) AS avg_total,
       total - (SELECT AVG(total) FROM invoice) AS diff
FROM invoice
WHERE total > (SELECT AVG(total) FROM invoice)
ORDER BY diff DESC
LIMIT 10;


select first_name , last_name , total
from customer c 
join invoice ic on c.customer_id = ic.customer_id 
where c.customer_id in
	(select i.customer_id from invoice i where i.total>20);

select first_name , last_name 
from customer c 
where c.customer_id in
	(select i.customer_id from invoice i where total>20);

select first_name , last_name 
from customer c
where exists (
	select 1 from invoice i
	where i.customer_id = c.customer_id and total>20
);


select name from track 
where composer not in (select composer from track where composer is not null);


select name from track 
where composer not in (select composer from track);




select t1.name from track t1
where not exists(
	select 1 from track t2 where t1.composer  = t2.composer  and t1.track_id <> t2.track_id 
);

select composer, count(*) as tracks
from track
where composer is not null
group by composer
having count(*) = 1;

	select customer_id , sum(total) as customer_total
	from invoice i 
	group by customer_id 

select round(avg(customer_total),2) as customer_avg 
from (
	select customer_id , sum(total) as customer_total
	from invoice i 
	group by customer_id 
)sub;


with customer_total as (
	select customer_id , sum(total) as customer_total
	from invoice i 
	group by customer_id
)
select round(avg(customer_total),2) as avg_customer_spend
from customer_total ;

with customer_total as (
	select customer_id , sum(total) as spend
	from invoice i 
	group by customer_id
),
banded as (
	select customer_id , spend ,
	case when spend >= 45 then 'high' 
	when spend >= 39 then 'medium'
	else 'low' end as band
	from customer_total
)
select band , count(*)as customers , ROUND(avg(spend) ,2) as avg_spend
from banded 
group by band 
order by avg_spend desc;





with customer_total as(
	select customer_id , sum(total) as spend 
	from invoice
	group by customer_id
)
select customer_id , spend
from customer_total 
where spend > (select avg(spend) from customer_total)
order by spend desc
;



with customers_total as(
	select customer_id , sum(total) as spend
	from invoice
	group by customer_id
),
banded as(
	select customer_id , spend ,
	case when spend >= 45 then 'high'
	when spend >= 39 then 'medium'
	else 'low' end as band
	from customers_total
)
select band , count(*) as customers , round(avg(spend),2) as avg_spend
from banded 
group by band
order by avg_spend desc;



with track_revenue as(
	select g.name as genre , t.name as track , sum(il.unit_price * il.quantity ) as revenue
	from genre g 
	join track t on g.genre_id = t.genre_id 
	join invoice_line il on t.track_id = il.track_id 
	group by genre , track
	order by GENRE ,  revenue desc
)
select genre , track , revenue
from track_revenue tr
where revenue = (
	select max(revenue) from track_revenue where genre = tr.genre 
	)
order by revenue desc;

select current_date , now() , current_timestamp;

select current_date + interval '1 month';
select current_date - interval '5 days';

select * from invoice 
where invoice_date >= (select max(invoice_date) from invoice ) - interval '90 days';

select date_trunc('month' , invoice_date) as month , Sum(total) as revenue
from invoice 
group by 1
order by 2 desc ;

select first_name , hire_date , age(current_date , hire_date) as tenure ,
extract(year from age(current_date , hire_date)) as years
from employee e ;	


select max(invoice_date)::date - min(invoice_date)::date as days_span from invoice;	

SELECT '2025-03-17'::date;
SELECT TO_DATE('17-03-2025', 'DD-MM-YYYY');


select first_name || ' ' || last_name as fullname from customer;
select concat(first_name,' ',last_name) as fullname from customer;




SELECT email,
       UPPER(first_name),
       LOWER(email),
       LENGTH(email),
       POSITION('@' IN email) AS at_position,
       SUBSTRING(email FROM POSITION('@' IN email) + 1) AS domain,
       SPLIT_PART(email, '@', 2) AS domain_easy,
       REPLACE(phone, '+', '') AS phone_clean,
       TRIM('  padded  ') AS trimmed
FROM customer
LIMIT 10;



select split_part(email , '@' ,2) as domain , count(*) as customers
from customer c 
group by 1
order 
by customers desc;

select billing_country from invoice i 
union 
select country from customer c ;

select billing_country from invoice i 
union all
select country from customer c ;

select country from customer c
intersect 
select billing_country from invoice i ;

select country from customer c
except
select billing_country from invoice i ;

select date_trunc('month' , invoice_date) as month , sum(total) as revenue
from invoice i 
group by month ;

select split_part(email , '@' , 2) as domain , count(*) as customers
from customer c 
group by 1
order by 2 desc; 

select date_trunc('quarter' , invoice_date) as quarter , sum(total) as revenue 
from invoice i 
group by 1
order by 2 desc;

select first_name , age(current_date , hire_date) as tenure 
from employee e 
order by tenure desc;





select invoice_id , billing_country , total , 
	sum(total) over(partition by billing_country) as country_total
from invoice
order by country_total desc;



select invoice_id , total ,
	sum(total) over() as grand_total ,
	round(100.0 * total/sum(total) over() ,3) as pct
from invoice
order by total desc;


select invoice_id , total ,
row_number() over(order by total desc) as rn,
rank() over(order by total desc) as rk,
dense_rank() over(order by total desc) as dense
from invoice i 
order by total desc;


with track_rev as (
	select g.name as genre , t.name as track ,
	sum(il.unit_price * il.quantity) as revenue
	from genre g
	join track t on g.genre_id = t.genre_id
	join invoice_line il on t.track_id = il.track_id 
	group by g.name , t.name
),
ranked as(
	select genre , track , revenue,
	row_number() over(partition by genre  order by revenue desc , track) as rn
	from track_rev 
)
select genre , track , revenue
from ranked
where rn = 1
order by revenue desc;

with monthly as(
	select date_trunc('month', invoice_date) as month, sum(total) as revenue
	from invoice i 
	group by 1
)
select month , revenue ,
lag(revenue) over (order by month) as prev_month ,
revenue - lag(revenue) over(order by month) as change,
round(100.0 * (revenue - lag(revenue) over (order by month)) / lag(revenue) over(order by month ) , 2 ) as pct
from monthly 
order by month;


WITH monthly AS (
    SELECT DATE_TRUNC('month', invoice_date) AS month, SUM(total) AS revenue
    FROM invoice GROUP BY 1
)
SELECT month, revenue,
       SUM(revenue) OVER () AS grand_total,
       SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly
ORDER BY month;

SELECT invoice_id, billing_country, total,
       AVG(total) OVER (PARTITION BY billing_country) AS country_avg,
       COUNT(*)   OVER (PARTITION BY billing_country) AS country_invoices,
       total - AVG(total) OVER (PARTITION BY billing_country) AS vs_avg
FROM invoice
ORDER BY billing_country;





WITH monthly AS (
    SELECT DATE_TRUNC('month', invoice_date) AS month, SUM(total) AS revenue
    FROM invoice GROUP BY 1
)
SELECT month, revenue,
       ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM monthly
ORDER BY month;


WITH cust AS (
    SELECT customer_id, SUM(total) AS spend FROM invoice GROUP BY 1
)
SELECT customer_id, spend,
       NTILE(4) OVER (ORDER BY spend DESC) AS quartile,
       FIRST_VALUE(spend) OVER (ORDER BY spend DESC) AS top_spend
FROM cust;



with first_purchase as(
	select customer_id , 
		   date_trunc('month',min(invoice_date)) as cohort_month
		   from invoice i 
		   group by customer_id 
),
activity as (
	select i.customer_id,
		   fp.cohort_month,
		   date_trunc('month' , invoice_date) as active_month
		   from invoice i 
		   join first_purchase fp on fp.customer_id = i.customer_id 
)
select TO_CHAR(cohort_month, 'YYYY-MM') AS cohort,
	   extract (year from age(active_month , cohort_month)) *12 
	   + extract (month from age(active_month , cohort_month)) as months_since,
	   count(distinct customer_id) as customers
from activity 
group by 1 , 2
order by 1 , 2;




select billing_country , 
	   count(distinct customer_id) as customers,
	   count(distinct case when total >= 5 then customer_id end) as plus_5,
	   count(distinct case when total >= 15 then customer_id end) as plus_15,
	   round(100.0 * ( count(distinct case when total >= 15 then customer_id end)) /
	   				 ( count(distinct customer_id)) ,1) as pct_reaching_15 
from invoice
group by billing_country 
order by customers desc;


with daily as(
	select distinct customer_id , invoice_date::date as date
	from invoice i 
	order by customer_id
),
grouped as(
	select customer_id , date ,
	date - (row_number() over(partition by customer_id order by date ))::int as grp
	from daily
)
select customer_id , count(*) as streak_len ,
		min(date) as start , max(date) as end
from grouped
group by customer_id , grp
--having count(*) > 1
order by streak_len desc;


WITH daily AS (
    SELECT DISTINCT customer_id, invoice_date::date AS d FROM invoice
)
SELECT customer_id, d,
       LEAD(d) OVER (PARTITION BY customer_id ORDER BY d) - d AS days_to_next
FROM daily
ORDER BY days_to_next
LIMIT 10;


SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total) AS median_invoice
FROM invoice;

-- per group
SELECT billing_country,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total) AS median,
       AVG(total) AS mean
FROM invoice
GROUP BY 1
ORDER BY median DESC;



WITH ranked AS (
    SELECT total,
           ROW_NUMBER() OVER (ORDER BY total) AS rn,
           COUNT(*) OVER () AS n
    FROM invoice
)
SELECT AVG(total) AS median
FROM ranked
WHERE rn IN ((n+1)/2, (n+2)/2);



-------------------------------------------------------------------------------------------------------------------------------------------------------------------------


select billing_country , sum(total) as revenue , count(*) as invoices
from invoice 
group by billing_country 
having count(*) >= 10
order by revenue desc;


select c.first_name , c.last_name , coalesce(sum(i.total),0) as spend
from customer c
left join invoice i on c.customer_id = i.customer_id 
group by c.customer_id 
order by spend desc;


select * from employee e ;

select e.first_name  as employee , m.first_name  as manager
from employee e 
left join employee m on m.employee_id = e.reports_to ;


--Top 10 artists by revenue (chain: invoice_line → track → album → artist)

select a2.name , sum(il.unit_price * il.quantity ) as revenue
from invoice_line il 
join track t on il.track_id = t.track_id 
join album a on a.album_id = t.album_id 
join artist a2 on a2.artist_id = a.artist_id 
group by a2.artist_id 
order by revenue desc
limit 10;

--Intermediate 5. Customers who spent more than the average customer

select customer_id ,sum(total)from invoice
group by customer_id
order by customer_id;

select first_name , last_name , sum(total) as spend
from customer c
join invoice i on c.customer_id = i.customer_id 
group by 1,2
having sum(total) > (select avg(total) from invoice);


with sum_cus as(
	select c.first_name , c.last_name ,sum(total) as spend
	from invoice i
	join customer c on c.customer_id = i.customer_id
	group by 1,2
)
select first_name , last_name , spend 
from sum_cus
where spend > (select avg(spend) from sum_cus)
order by spend desc;

with sum_cus as(
	select c.first_name , c.last_name ,sum(total) as spend
	from invoice i
	join customer c on c.customer_id = i.customer_id
	group by 1,2
)
select avg(spend) 
from sum_cus

--6. One row per country with a column per year's revenue

select * from customer;
select * from invoice;

SELECT billing_country,
       SUM(CASE WHEN EXTRACT(YEAR FROM invoice_date) = 2021 THEN total ELSE 0 END) AS year_2021,
       SUM(CASE WHEN EXTRACT(YEAR FROM invoice_date) = 2022 THEN total ELSE 0 END) AS year_2022,
       SUM(CASE WHEN EXTRACT(YEAR FROM invoice_date) = 2023 THEN total ELSE 0 END) AS year_2023,
       SUM(CASE WHEN EXTRACT(YEAR FROM invoice_date) = 2024 THEN total ELSE 0 END) AS year_2024,
       SUM(CASE WHEN EXTRACT(YEAR FROM invoice_date) = 2025 THEN total ELSE 0 END) AS year_2025,
       SUM(total) AS total
FROM invoice
GROUP BY billing_country
ORDER BY total DESC;


--7. Monthly revenue trend, chronological
select to_char(date_trunc('month' , invoice_date), 'yyyy-mm') as month,
	   sum(total) as revenue
from invoice 
group by 1
order by month;

--Windows 8. Running total of monthly revenue

with monthly as(
	select to_char(date_trunc('month' , invoice_date), 'yyyy-mm') as month,
	   sum(total) as revenue
	from invoice 
	group by 1
	order by month
)
select month , revenue ,
	   sum(revenue) over (order by month) as rn
from monthly 
order by month;


--9. Month-over-month % change

with monthly as(
	select to_char(date_trunc('month' , invoice_date), 'yyyy-mm') as month,
	   sum(total) as revenue
	from invoice 
	group by 1
	order by month
)
select month , revenue ,
	   lag(revenue) over(order by month) as prev_month ,
	   round(100.0* (revenue - lag(revenue) over(order by month))
	   / lag(revenue) over(order by month) , 2 ) as pct_change
from monthly 
order by month;
-------------------
WITH monthly AS (
    SELECT DATE_TRUNC('month', invoice_date) AS month,
           SUM(total) AS revenue
    FROM invoice
    GROUP BY 1
)
SELECT TO_CHAR(month, 'YYYY-MM') AS month,
       revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS pct_change
FROM monthly
ORDER BY month;

--------------------

--Windows 8. Running total of monthly revenue
WITH monthly AS (
    SELECT DATE_TRUNC('month', invoice_date) AS month,
           SUM(total) AS revenue
    FROM invoice
    GROUP BY 1
)
select to_char(month , 'mm-yyyy') as month ,
		revenue,
		sum(revenue) over(order by month) as runnig_total
from monthly ;
 
--10. Top 3 tracks per genre by revenue 

with top_track as( 
	select t.name as track , g.name as genre , sum(il.unit_price * il.quantity) as revenue
	from genre g
	join track t on g.genre_id = t.genre_id
	join invoice_line il on t.track_id = il.track_id	
	group by track , genre
),
ranked as(
	select track , genre , revenue ,
	row_number() over(partition by genre order by revenue desc) as rn
	from top_track
)
select track , genre , revenue 
from ranked
where rn <= 3	
order by genre ,revenue desc ;



select * from invoice_line il   ;

--11. Each invoice with its % share of its country's total

select * from invoice;

select invoice_id ,billing_country , total ,
	sum(total) over(partition by billing_country) as country_total,
	round(100.0 * total/sum(total) over(partition by billing_country),2) as pct_of_total
from invoice;


--customers by first-purchase month, tracked forward

with first_purchase as(
	select customer_id ,date_trunc('month' , min(invoice_date)) as cohort_month
	from invoice
	group by customer_id
),
activity as (
	select date_trunc('month' , invoice_date) as active_month,
	i.customer_id,
	fp.cohort_month
	from invoice i
	join first_purchase fp on fp.customer_id = i.customer_id
)
select to_char(cohort_month , 'mm-yyyy') as cohort,
	extract(year from age(active_month,cohort_month)) *12 + extract(month from age(active_month,cohort_month)) as month_since,
	count(distinct customer_id) as customers
from activity
group by 1,2;


--Median invoice total per country, next to the mean

select billing_country , avg(total) as mean ,
	PERCENTILE_CONT(0.5) within group (order by total) as median
from invoice i
group by billing_country;
















































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































;