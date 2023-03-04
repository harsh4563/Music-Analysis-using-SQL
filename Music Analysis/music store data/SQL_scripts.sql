use  music_analysis;
SHOW TABLES;
SET sql_mode=(SELECT REPLACE( @@sql_mode,'ONLY_FULL_GROUP_BY',''));

		     -- Question Set 1 - Easy 
             
-- Q1: Who is the senior most employee based on job title ?

Select *
from employee
order by levels desc
limit 1 ;

-- Q2: Which countries have the most Invoices ?

Select billing_country , count(*) as Invoice_Count
from invoice
group by billing_country
order by Invoice_Count desc;

-- Q3: What are top 3 values of total invoice ?

Select total
from invoice
order by total desc
limit 3;

-- Q4: Which city has the best customers ? (We would like to throw a promotional 
-- Music Festival in the city we made the most money. write a query that returns one 
-- city that has the highest sum of invoice totals. Return both the city name & sum of
-- all invoice totals)

select billing_city, sum(total) as Invoice_total
from invoice
group by  billing_city
Order by Invoice_total desc;

-- Q5: Who is the best customer ? (The customer who has spent the most money
--  will be declared the best customer. Write a query that returns the person who has
--  spent the most money)
 
Select c.customer_id, c.first_name, c.last_name, Sum(i.total) as Total 
From customer as c
join invoice as i on c.customer_id = i.customer_id
group by c.customer_id
order by Total desc
limit 1;

                  -- Question Set 2 - Moderate 
                  
-- Q1: Write query to return the email, first name, last name, & Genre of all
-- Rock Music listeners. Return your list ordered alphabetically by email starting 
-- with A ?

Select distinct  c.email, c.first_name, c.last_name, g.name 
from customer as c 
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
join track as t on il.track_id = t.track_id 
join genre as g on t.genre_id = g.genre_id 
where g.name like 'Rock'
order by c.email; 

-- OR 

Select distinct  c.email, c.first_name, c.last_name
from customer as c 
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
where track_id in (
	Select track_id from track as t 
    join genre as g on t.genre_id = g.genre_id 
    where  g.name like 'Rock'
    )
order by c.email;     
    
-- Q2: Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10
-- rock bands.

select a.artist_id, a.name, Count(a.artist_id) as Number_of_songs
from track as t
join album as ab on t.album_id = ab.album_id
join artist as a on ab.artist_id = a.artist_id
join genre as g on t.genre_id = g.genre_id 
where g.name like 'Rock'
group by a.artist_id 
order by Number_of_songs desc
limit 10 ;

-- Q3: Return all the track names that have a song length longer than the average song
-- length. Return the Name and Milliseconds for each track. Order by song length with 
-- longest songs listed first.

Select  name, milliseconds 
from track
where milliseconds > (Select avg(milliseconds) as avg_track_length 
						from track )
order by milliseconds desc;          


                   -- Question Set 3 - Advance   
                   
-- Q1: Find how much amount spent by each customer on artists ? Write a query to 
-- return customer name, atrist name and total spent.

    
with best_selling_artist as (
		select a.artist_id as artist_id, a.name as artist_name,
        SUM(il.unit_price * il.quantity) as total_sales 
        from invoice_line il
		join track t on il.track_id = t.track_id
		join album ab on t.album_id = ab.album_id
		join artist a on ab.artist_id = a.artist_id
        group by 1
        Order by 3 desc
        limit 1 
)
Select c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
Sum(il.unit_price * il.quantity)
 as Total_Spent
 from customer c 
 join invoice i on c.customer_id = i.customer_id
 join invoice_line il on i.invoice_id = il.invoice_id
 join track t on il.track_id = t.track_id
 join album ab on t.album_id = ab.album_id
 join best_selling_artist bsa on bsa.artist_id = ab.artist_id
 group by 1, 2, 3, 4
 Order by 5 desc ;
 
 
 
-- Q2: We want to find out the most popular music Genre for each country. We 
-- determine the most popular genre as the genre with the highest amount of 
-- purchases. Write a query that returns each country along with the top Genre. For 
-- countries where the maximum number of purchases is shared return all Genres.

With popular_genre AS
(			
	Select count(il.quantity) as purchases, c.country, g.name,g.genre_id, 
    row_number() over(partition by c.country order by (il.quantity) desc) as Row_No
    From invoice_line as il
    join invoice i on i.invoice_id = il.invoice_id
    join customer c on c.customer_id = i.customer_id
    join track t on  t.track_id = il.track_id
    join genre g on g.genre_id = t.genre_id
    group by 2,3,4
    order by 2 asc, 1 desc
)
Select * from popular_genre where Row_No <=1;   

-- Q3:Write a query that determines the customer that has spent the most on music 
-- for each country. Write a query that returns the country along with the top 
-- customer and how much they spent. For countries where the top amount spent is
-- shared, provide all customers who spent this amount.

With Customer_with_country as 
(
		Select c.customer_id, first_name, last_name, billing_country, 
        SUM(total) as Total_spendings,
        row_number() over (partition by billing_country order by sum(total) desc)
        as Row_NO  from invoice i 
        join customer c on c.customer_id = i.customer_id
        group by 1, 2, 3, 4
        order by 4 asc, 5 desc
 )       
  Select * from Customer_with_country where Row_NO <= 1      
        
        