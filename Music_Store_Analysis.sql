/* who is the senior most employee based on job title */
SELECT * FROM employee
ORDER BY levels DESC
OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY

/* Which country has the most invoice */
SELECT count(total) as total_invoice, billing_country FROM invoice
group by billing_country
order by total_invoice desc
OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY

/* what are the top three values of total invoices */
SELECT * FROM invoice
order by total desc
OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY

/* Which city has the best customers */
SELECT billing_city, sum(total) as totals from invoice
GROUP BY billing_city
order by totals desc
OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY

/*who is the best customer */
SELECT customer.customer_id,customer.first_name,customer.last_name,SUM(invoice.total) AS total_money 
FROM customer INNER JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id,customer.first_name, customer.last_name
ORDER BY total_money DESC
OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY

/* write query to return the email, first name, last name, and Genre of 
all Rock Music listerners  return list ordered alphabetically by email starting with A */
SELECT DISTINCT first_name, last_name,email FROM customer
inner join invoice on invoice.customer_id = customer.customer_id
inner join invoice_line on invoice_line.invoice_id = invoice.invoice_id
where track_id in(
   select track_id from track
   inner join genre on genre.genre_id = track.genre_id
   where genre.name like 'Rock'
)
ORDER BY email

/* Write a query to return artist name who written most 
rock musics and count of the top 10 brands */
select artist.name, count(artist.artist_id) as number_of_songs
from artist inner join  album on   artist.artist_id = album.artist_id 
inner join track on track.album_id = album.album_id
inner join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id, artist.name
order by number_of_songs desc
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY

/* Return all the track names that has the song length longer than 
the average song length. Return the name and miliseconds of each
track. order by the song length with the longest songs listed first */

SELECT track.name,milliseconds FROM track
where milliseconds >
(
  select avg(milliseconds) as avg_length 
  from track
)
order by milliseconds desc
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY

/* Find how much amount spent by each customer on artists? write a query
to return customer name, artist name and total spent */
with best_selling_artist as(
SELECT artist.artist_id as artist_id, artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
FROM invoice_line
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
Group by artist.artist_id, artist.name
order by total_sales desc
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY
)
SELECT customer.first_name, customer.last_name, customer.customer_id,
sum(invoice_line.unit_price*invoice_line.quantity) as amount_Spent,best_selling_artist.artist_name
from invoice
join customer on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join best_selling_artist on best_selling_artist.artist_id = album.artist_id 
group by customer.first_name, customer.last_name, customer.customer_id,
best_selling_artist.artist_name
order by amount_Spent desc

/* we want to find the most popular genre for each country
we determine the most popular genre has most purchases */
WITH genre_popular AS (
SELECT COUNT(invoice_line.quantity) AS purchases,customer.country,genre.name,
genre.genre_id
FROM invoice_line 
JOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
JOIN customer ON invoice.customer_id = customer.customer_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON genre.genre_id = track.genre_id
GROUP BY customer.country,genre.name,genre.genre_id
)
SELECT
    purchases,
    country,
    name,
    genre_id,
	outer_row_id
FROM (
    SELECT
        purchases,
        country,
        name,
        genre_id,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY purchases DESC) AS outer_row_id
    FROM
        genre_popular
) AS outer_query
WHERE
    outer_row_id <= 1
ORDER BY
    purchases DESC, country ASC;
















