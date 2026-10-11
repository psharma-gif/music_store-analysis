# music_store-analysis
SQL analysis of a sample music-store database, exploring sales trends, customer purchases, and unsold tracks using SQLite.
# Music Store Analysis with SQL

I created this project while learning SQL through LinkedIn Learning. I used the sample `WSDA_Music.db` database to practice answering questions about sales, customers, and music tracks.

My background is in forestry and ecosystem modeling, where I mainly use R. I wanted to learn SQL to work with data stored in databases and build skills for data analysis and resource planning.

## What I worked on

Some of the questions I explored were:

- What are total sales and the average invoice value?
- How many invoices fall within a particular price range?
- How does average invoice value vary by city and country?
- Who is each customer's assigned support representative?
- Which customers and representatives are associated with the largest invoices?
- Which tracks have no recorded sales?

I also practiced formatting customer names and addresses, working with dates, and categorizing purchases using CASE.

## Files

- `music_store_analysis.sql` — my queries, organized by topic, with the question written above each query.
- `README.md` — a short introduction to the project.

## SQL concepts I practiced

- Filtering with WHERE, BETWEEN, IN, and LIKE
- Sorting with ORDER BY
- Joining tables with INNER JOIN and LEFT JOIN
- Summarizing data with SUM, AVG, COUNT, MIN, and MAX
- Grouping results with GROUP BY and HAVING
- Using CASE, subqueries, and CTEs
- Working with text and date functions
- Finding tracks without purchases using NOT EXISTS

## A few things I learned

Writing the question clearly matters. For example, listing invoices is different from counting them, and average invoice value is different from average spending per customer.

I also learned that an invoice total of $1.98 does not necessarily mean someone bought two songs priced at $0.99. To answer that question, I would need to check the invoice lines.

## How to run the queries

I used DB Browser for SQLite.

1. Open `WSDA_Music.db`.
2. Go to the Execute SQL tab.
3. Open `music_store_analysis.sql`.
4. Select and run the query you want to see.

The main queries read the data. I kept the view and data modification exercises commented out at the end of the file.

## Source

This is a learning project based on LinkedIn Learning course exercises and its sample music-store database. I organized and adjusted the queries for this repository.

## Author

Puja Sharma  
[GitHub](https://github.com/psharma-gif)
