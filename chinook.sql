-- Customers per country
select country , count(*) as customers
from customer c
group by c.country
order by customers desc;

-- Revenue and orders per billing country
select billing_country , sum(total) as revenue, count(*) as orders
from invoice
group by billing_country
order by revenue desc;

-- Same, only countries with more than 10 orders
select billing_country , sum(total) as revenue, count(*) as orders
from invoice
group by billing_country
having count(*) > 10
order by revenue desc;

-- Revenue and orders by customer country
select c.country , SUM(i.total) as revenue , count(*) as orders
from customer c
inner join invoice i on c.customer_id = i.customer_id
group by c.country
order by revenue desc ;

-- Tracks that are not in any playlist
select t.name
from track t
left join playlist_track pt on t.track_id = pt.track_id
where pt.track_id is null;

-- Top 25 artists by revenue
select a2.name as artist, SUM(il.unit_price * il.quantity ) as revenue
from invoice_line il
join track t on il.track_id = t.track_id
join album a on t.album_id = a.album_id
join artist a2 on a.artist_id = a2.artist_id
group by artist
order by revenue desc
limit 25;

-- Total spent per customer, including customers with no invoices
select c.first_name  , c.last_name , COALESCE(SUM(i.total), 0) as total_spent
from customer c
left join invoice i on c.customer_id = i.customer_id
group by c.customer_id , c.first_name , c.last_name
order by total_spent desc;

-- Top 5 genres by revenue
SELECT g.name, SUM(il.unit_price * il.quantity) AS total_revenue
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.name
ORDER BY total_revenue DESC
LIMIT 5;

-- Revenue per billing country and city
select  i.billing_country , i.billing_city ,sum(total) as revenue
from invoice i
group by billing_country , billing_city
order by billing_country , revenue desc;

-- Invoice count and revenue by size band
SELECT CASE WHEN total >= 15 THEN 'Large'
            WHEN total >= 8  THEN 'Medium'
            ELSE 'Small'
       END AS size_band,
       COUNT(*) AS invoices,
       SUM(total) AS revenue
FROM invoice
GROUP BY 1
ORDER BY revenue DESC;

-- Large and small invoice counts per country
select billing_country , count(*) as invoices ,
sum(case when total >= 10 then 1 else 0 end) as large_invoices ,
sum(case when total < 10 then 1 else 0 end) as small_invoices
from invoice i
group by billing_country
order by invoices desc;

-- Large and small invoice revenue per country
SELECT billing_country,
       SUM(CASE WHEN total >= 15 THEN total ELSE 0 END) AS large_revenue,
       SUM(CASE WHEN total <  15 THEN total ELSE 0 END) AS small_revenue,
       Sum(total) total_revenue
FROM invoice
GROUP BY billing_country
order by total_revenue desc;

-- Revenue per country by year
select billing_country ,
sum(case when extract (year from invoice_date) = 2021 then total else 0 end) as rev_2021,
sum(case when extract (year from invoice_date) = 2022 then total else 0 end) as rev_2022,
sum(case when extract (year from invoice_date) = 2023 then total else 0 end) as rev_2023,
sum(case when extract (year from invoice_date) = 2024 then total else 0 end) as rev_2024,
sum(case when extract (year from invoice_date) = 2025 then total else 0 end) as rev_2025
from invoice
group by billing_country
order by billing_country;

-- Top 10 invoices furthest above the average total
SELECT invoice_id, total,
       (SELECT AVG(total) FROM invoice) AS avg_total,
       total - (SELECT AVG(total) FROM invoice) AS diff
FROM invoice
WHERE total > (SELECT AVG(total) FROM invoice)
ORDER BY diff DESC
LIMIT 10;

-- Customers with at least one invoice over 20
select first_name , last_name
from customer c
where exists (
	select 1 from invoice i
	where i.customer_id = c.customer_id and total>20
);

-- Composers with only one track
select composer, count(*) as tracks
from track
where composer is not null
group by composer
having count(*) = 1;

-- Average spend per customer
with customer_total as (
	select customer_id , sum(total) as customer_total
	from invoice i
	group by customer_id
)
select round(avg(customer_total),2) as avg_customer_spend
from customer_total ;

-- Customer count and average spend per spend band
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

-- Customers who spent more than the average customer
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

-- Invoices from the last 90 days of data
select * from invoice
where invoice_date >= (select max(invoice_date) from invoice ) - interval '90 days';

-- Customers per email domain
select split_part(email , '@' ,2) as domain , count(*) as customers
from customer c
group by 1
order
by customers desc;

-- Quarterly revenue
select date_trunc('quarter' , invoice_date) as quarter , sum(total) as revenue
from invoice i
group by 1
order by 2 desc;

-- Month over month revenue change
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

-- Running total of monthly revenue
WITH monthly AS (
    SELECT DATE_TRUNC('month', invoice_date) AS month, SUM(total) AS revenue
    FROM invoice GROUP BY 1
)
SELECT month, revenue,
       SUM(revenue) OVER () AS grand_total,
       SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly
ORDER BY month;

-- Three month moving average of revenue
WITH monthly AS (
    SELECT DATE_TRUNC('month', invoice_date) AS month, SUM(total) AS revenue
    FROM invoice GROUP BY 1
)
SELECT month, revenue,
       ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM monthly
ORDER BY month;

-- Customer spend quartiles
WITH cust AS (
    SELECT customer_id, SUM(total) AS spend FROM invoice GROUP BY 1
)
SELECT customer_id, spend,
       NTILE(4) OVER (ORDER BY spend DESC) AS quartile,
       FIRST_VALUE(spend) OVER (ORDER BY spend DESC) AS top_spend
FROM cust;

-- Customer retention by first purchase month
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

-- Customers reaching spend thresholds per country
select billing_country ,
	   count(distinct customer_id) as customers,
	   count(distinct case when total >= 5 then customer_id end) as plus_5,
	   count(distinct case when total >= 15 then customer_id end) as plus_15,
	   round(100.0 * ( count(distinct case when total >= 15 then customer_id end)) /
	   				 ( count(distinct customer_id)) ,1) as pct_reaching_15
from invoice
group by billing_country
order by customers desc;

-- Longest consecutive purchase day streaks per customer
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

-- Shortest gaps between purchases per customer
WITH daily AS (
    SELECT DISTINCT customer_id, invoice_date::date AS d FROM invoice
)
SELECT customer_id, d,
       LEAD(d) OVER (PARTITION BY customer_id ORDER BY d) - d AS days_to_next
FROM daily
ORDER BY days_to_next
LIMIT 10;

-- Monthly revenue trend
select to_char(date_trunc('month' , invoice_date), 'yyyy-mm') as month,
	   sum(total) as revenue
from invoice
group by 1
order by month;

-- Top 3 tracks per genre by revenue
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

-- Each invoice as a share of its country total
select invoice_id ,billing_country , total ,
	sum(total) over(partition by billing_country) as country_total,
	round(100.0 * total/sum(total) over(partition by billing_country),2) as pct_of_total
from invoice;

-- Median and mean invoice total per country
select billing_country , avg(total) as mean ,
	PERCENTILE_CONT(0.5) within group (order by total) as median
from invoice i
group by billing_country;
