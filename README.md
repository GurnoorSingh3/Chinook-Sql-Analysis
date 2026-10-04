# Chinook-Sql-Analysis

Chinook SQL Analysis

A collection of PostgreSQL analysis queries written against the Chinook sample database, a fictional digital music store. The queries look at customers, revenue, artists, genres and purchase behaviour.

Files
chinook.sql

Tables used:
customer
invoice
invoice_line
track
album
artist
genre
playlist_track
Analysis covered

Customers

Customers per country and per email domain
Average spend per customer and customers above that average
Customers split into spend bands and quartiles
Customers with at least one large invoice
Purchase streaks and gaps between purchases
Retention by first purchase month

Revenue

Revenue and orders by billing country, customer country, and city
Revenue per country by year
Monthly and quarterly revenue, month over month change, running total, and three month moving average
Invoice size bands and large vs small invoices per country
Each invoice as a share of its country total
Median and mean invoice total per country

Catalog

Top artists by revenue
Top genres by revenue
Top 3 tracks per genre
Tracks that are not in any playlist
Composers with only one track
How to use
Create and load the Chinook database in PostgreSQL.
Open chinook.sql in your SQL client.
Run the queries one at a time.

Notes
Revenue is calculated as unit_price * quantity from invoice_line, or from total in invoice.
Invoice dates in the data cover 2021 to 2025, which is why the yearly queries use those years.
