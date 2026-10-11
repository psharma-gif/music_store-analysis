/*
PROJECT: Music Store Analysis
AUTHOR: Puja Sharma
DATABASE ENGINE: SQLite

PURPOSE:
Explore sales, customer purchases, support representative assignments,
and music inventory using a sample music-store database.

SOURCE:
Developed from LinkedIn Learning exercises.
Add the course title and database source to the README.

NOTES:
- An invoice represents one transaction, not one unique customer.
- Average invoice value differs from total spending per customer.
- Run individual statements to inspect each result.
*/


/* ================================================================
   SECTION 1: EXPLORING CUSTOMERS AND TRACKS
   ================================================================ */


/*
Question 1:
Who are the first 10 customers when sorted by first name ascending
and last name descending?
*/

SELECT
    FirstName AS CustomerFirstName,
    LastName AS CustomerLastName,
    Email
FROM Customer
ORDER BY
    FirstName ASC,
    LastName DESC
LIMIT 10;


/*
Question 2:
What are the names and prices of the first 20 tracks by TrackId?
*/

SELECT
    TrackId,
    Name AS TrackName,
    UnitPrice AS Price
FROM Track
ORDER BY TrackId
LIMIT 20;


/* ================================================================
   SECTION 2: FILTERING AND COUNTING INVOICES
   ================================================================ */


/*
Question 3:
Which invoices have a total of $1.98?

Note:
A $1.98 total alone does not prove that two $0.99 tracks were purchased.
*/

SELECT
    InvoiceId,
    InvoiceDate,
    BillingAddress,
    BillingCity,
    Total
FROM Invoice
WHERE Total = 1.98
ORDER BY InvoiceDate, InvoiceId;


/*
Question 4:
How many invoices have totals between $1.98 and $5.00, inclusive?
*/

SELECT
    COUNT(*) AS InvoiceCount
FROM Invoice
WHERE Total BETWEEN 1.98 AND 5.00;


/*
Question 5:
How many invoices have a total of exactly $1.98 or $3.96?
*/

SELECT
    COUNT(*) AS InvoiceCount
FROM Invoice
WHERE Total IN (1.98, 3.96);


/*
Question 6:
How many invoices were billed to Brussels?
*/

SELECT
    COUNT(*) AS InvoiceCount
FROM Invoice
WHERE BillingCity = 'Brussels';


/*
Question 7:
How many invoices were billed to Brussels, Orlando, or Paris?
*/

SELECT
    COUNT(*) AS InvoiceCount
FROM Invoice
WHERE BillingCity IN ('Brussels', 'Orlando', 'Paris');


/*
Question 8:
How many invoices were billed to cities whose names start with B?
*/

SELECT
    COUNT(*) AS InvoiceCount
FROM Invoice
WHERE BillingCity LIKE 'B%';


/*
Question 9:
How many invoices were billed to cities containing the letter B?

Note:
SQLite's default LIKE comparison ignores case for ASCII letters.
*/

SELECT
    COUNT(*) AS InvoiceCount
FROM Invoice
WHERE BillingCity LIKE '%B%';


/*
Question 10:
How many invoices have the exact timestamp 2010-05-22 00:00:00?
*/

SELECT
    COUNT(*) AS InvoiceCount
FROM Invoice
WHERE InvoiceDate = '2010-05-22 00:00:00';


/*
Question 11:
How many invoices dated after May 22, 2010 have totals below $3?
*/

SELECT
    COUNT(*) AS InvoiceCount
FROM Invoice
WHERE
    DATE(InvoiceDate) > '2010-05-22'
    AND Total < 3.00;


/*
Question 12:
Which invoices were billed to cities starting with P or D?
*/

SELECT
    InvoiceId,
    InvoiceDate,
    BillingAddress,
    BillingCity,
    Total
FROM Invoice
WHERE
    BillingCity LIKE 'P%'
    OR BillingCity LIKE 'D%'
ORDER BY InvoiceDate, InvoiceId;


/*
Question 13:
Which invoices exceed $1.98 and were billed to cities
starting with P or D?
*/

SELECT
    InvoiceId,
    InvoiceDate,
    BillingAddress,
    BillingCity,
    Total
FROM Invoice
WHERE
    Total > 1.98
    AND (
        BillingCity LIKE 'P%'
        OR BillingCity LIKE 'D%'
    )
ORDER BY InvoiceDate, InvoiceId;


/* ================================================================
   SECTION 3: PURCHASE AND PRICE CATEGORIES
   ================================================================ */


/*
Question 14:
Which invoices fall into the Top Performer purchase category?

Categories:
- Baseline Purchase: Below $2
- Low Purchase: $2 to below $7
- Target Purchase: $7 through $15
- Top Performer: Above $15

Sequential thresholds avoid gaps between categories.
A CTE allows the category to be filtered in the outer query.
*/

WITH CategorizedInvoices AS (
    SELECT
        InvoiceId,
        InvoiceDate,
        BillingAddress,
        BillingCity,
        Total,
        CASE
            WHEN Total < 2.00 THEN 'Baseline Purchase'
            WHEN Total < 7.00 THEN 'Low Purchase'
            WHEN Total <= 15.00 THEN 'Target Purchase'
            ELSE 'Top Performer'
        END AS PurchaseType
    FROM Invoice
)
SELECT
    InvoiceId,
    InvoiceDate,
    BillingAddress,
    BillingCity,
    Total,
    PurchaseType
FROM CategorizedInvoices
WHERE PurchaseType = 'Top Performer'
ORDER BY BillingCity, InvoiceId;


/*
Question 15:
How are tracks classified by unit price?

Categories:
- Budget: $0.99 or less
- Regular: Above $0.99 to below $1.50
- Premium: $1.50 to below $2
- Exclusive: $2 or more
*/

SELECT
    TrackId,
    Name AS TrackName,
    Composer,
    UnitPrice AS Price,
    CASE
        WHEN UnitPrice <= 0.99 THEN 'Budget'
        WHEN UnitPrice < 1.50 THEN 'Regular'
        WHEN UnitPrice < 2.00 THEN 'Premium'
        ELSE 'Exclusive'
    END AS PriceCategory
FROM Track
ORDER BY UnitPrice, TrackId;


/* ================================================================
   SECTION 4: JOINING RELATED TABLES
   ================================================================ */


/*
Question 16:
Which customers are associated with each invoice?

An INNER JOIN includes invoices with a matching customer.
*/

SELECT
    c.CustomerId,
    c.LastName,
    c.FirstName,
    i.InvoiceId,
    i.InvoiceDate,
    i.Total
FROM Invoice AS i
INNER JOIN Customer AS c
    ON i.CustomerId = c.CustomerId
ORDER BY c.CustomerId, i.InvoiceId;


/*
Question 17:
How can all invoices be retained when joining customer details?

This LEFT JOIN keeps every invoice, even if its customer record
does not match. With valid customer references, its results may
be identical to the INNER JOIN above.
*/

SELECT
    i.InvoiceId,
    i.CustomerId,
    c.LastName,
    c.FirstName,
    i.InvoiceDate,
    i.Total
FROM Invoice AS i
LEFT JOIN Customer AS c
    ON i.CustomerId = c.CustomerId
ORDER BY i.CustomerId, i.InvoiceId;


/*
Question 18:
Which support representatives are assigned to the customers
associated with the 10 largest individual invoices?

Note:
Assignment does not establish that the representative caused the sale.
*/

SELECT
    e.EmployeeId,
    e.FirstName AS SupportRepFirstName,
    e.LastName AS SupportRepLastName,
    c.CustomerId,
    c.FirstName AS CustomerFirstName,
    c.LastName AS CustomerLastName,
    i.InvoiceId,
    i.Total AS InvoiceTotal
FROM Invoice AS i
INNER JOIN Customer AS c
    ON i.CustomerId = c.CustomerId
INNER JOIN Employee AS e
    ON c.SupportRepId = e.EmployeeId
ORDER BY i.Total DESC, i.InvoiceId
LIMIT 10;


/*
Question 19:
Who is each customer's assigned support representative?
*/

SELECT
    c.FirstName AS CustomerFirstName,
    c.LastName AS CustomerLastName,
    e.FirstName AS SupportRepFirstName,
    e.LastName AS SupportRepLastName
FROM Customer AS c
INNER JOIN Employee AS e
    ON c.SupportRepId = e.EmployeeId
ORDER BY e.LastName, c.LastName, c.CustomerId;


/* ================================================================
   SECTION 5: TEXT AND DATE FUNCTIONS
   ================================================================ */


/*
Question 20:
How can US customer information be formatted as a mailing list?

COALESCE prevents a missing address field from making the entire
concatenated mailing address NULL.
*/

SELECT
    CustomerId,
    FirstName,
    LastName,
    Address,
    FirstName || ' ' || LastName || ' '
        || COALESCE(Address, '') || ', '
        || COALESCE(City, '') || ' '
        || COALESCE(State, '') || ' '
        || COALESCE(PostalCode, '') AS MailingAddress,
    LENGTH(PostalCode) AS PostalCodeLength,
    SUBSTR(PostalCode, 1, 5) AS FiveDigitPostalCode,
    UPPER(FirstName) AS FirstNameUppercase,
    LOWER(LastName) AS LastNameLowercase
FROM Customer
WHERE Country = 'USA'
ORDER BY LastName, FirstName, CustomerId;


/*
Question 21:
What is each employee's age as of the date the query is run?

The birthday adjustment prevents age from being overstated
when the employee's birthday has not yet occurred this year.
*/

SELECT
    EmployeeId,
    LastName,
    FirstName,
    DATE(BirthDate) AS BirthDate,
    CAST(STRFTIME('%Y', 'now') AS INTEGER)
        - CAST(STRFTIME('%Y', BirthDate) AS INTEGER)
        - (
            STRFTIME('%m-%d', 'now')
            < STRFTIME('%m-%d', BirthDate)
        ) AS Age
FROM Employee
ORDER BY LastName, FirstName, EmployeeId;


/*
Question 22:
What are the full names and first five postal-code characters
of US customers?

This formats postal codes; it does not validate them.
*/

SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS CustomerFullName,
    SUBSTR(c.PostalCode, 1, 5) AS StandardizedPostalCode
FROM Customer AS c
WHERE c.Country = 'USA'
ORDER BY CustomerFullName, c.CustomerId;


/* ================================================================
   SECTION 6: SALES SUMMARY AND GROUPED ANALYSIS
   ================================================================ */


/*
Question 23:
What are total recorded sales, average invoice value,
largest and smallest invoices, and the number of invoices?
*/

SELECT
    ROUND(SUM(Total), 2) AS TotalSales,
    ROUND(AVG(Total), 2) AS AverageInvoiceValue,
    MAX(Total) AS LargestInvoice,
    MIN(Total) AS SmallestInvoice,
    COUNT(*) AS InvoiceCount
FROM Invoice;


/*
Question 24:
What is the average invoice value by billing city?

This groups identical city names together across countries.
Question 28 distinguishes cities by country.
*/

SELECT
    BillingCity,
    ROUND(AVG(Total), 2) AS AverageInvoiceValue
FROM Invoice
GROUP BY BillingCity
ORDER BY BillingCity;


/*
Question 25:
What is the average invoice value for cities starting with L?
*/

SELECT
    BillingCity,
    ROUND(AVG(Total), 2) AS AverageInvoiceValue
FROM Invoice
WHERE BillingCity LIKE 'L%'
GROUP BY BillingCity
ORDER BY BillingCity;


/*
Question 26:
Which cities have an average invoice value greater than $5?
*/

SELECT
    BillingCity,
    ROUND(AVG(Total), 2) AS AverageInvoiceValue
FROM Invoice
GROUP BY BillingCity
HAVING AVG(Total) > 5.00
ORDER BY BillingCity;


/*
Question 27:
Which cities starting with B have an average invoice value
greater than $5?
*/

SELECT
    BillingCity,
    ROUND(AVG(Total), 2) AS AverageInvoiceValue
FROM Invoice
WHERE BillingCity LIKE 'B%'
GROUP BY BillingCity
HAVING AVG(Total) > 5.00
ORDER BY BillingCity;


/*
Question 28:
What is the average invoice value by billing country and city?
*/

SELECT
    BillingCountry,
    BillingCity,
    ROUND(AVG(Total), 2) AS AverageInvoiceValue
FROM Invoice
GROUP BY BillingCountry, BillingCity
ORDER BY BillingCountry, BillingCity;


/* ================================================================
   SECTION 7: SUBQUERIES AND COMPARISONS
   ================================================================ */


/*
Question 29:
Which invoices have totals below the global average invoice value?
*/

SELECT
    InvoiceId,
    InvoiceDate,
    BillingAddress,
    BillingCity,
    Total
FROM Invoice
WHERE Total < (
    SELECT AVG(Total)
    FROM Invoice
)
ORDER BY Total DESC, InvoiceId;


/*
Question 30:
How does each city's average invoice value compare
with the global average?
*/

SELECT
    BillingCountry,
    BillingCity,
    ROUND(AVG(Total), 2) AS CityAverageInvoiceValue,
    ROUND(
        (SELECT AVG(Total) FROM Invoice),
        2
    ) AS GlobalAverageInvoiceValue
FROM Invoice
GROUP BY BillingCountry, BillingCity
ORDER BY BillingCountry, BillingCity;


/*
Question 31:
Which invoices occurred after the timestamp of Invoice 251?

If Invoice 251 does not exist, this query returns no rows.
*/

SELECT
    InvoiceId,
    InvoiceDate,
    BillingAddress,
    BillingCity
FROM Invoice
WHERE InvoiceDate > (
    SELECT InvoiceDate
    FROM Invoice
    WHERE InvoiceId = 251
)
ORDER BY InvoiceDate, InvoiceId;


/*
Question 32:
Which invoices share an exact timestamp with Invoice 251, 252, or 254?
*/

SELECT
    InvoiceId,
    InvoiceDate,
    BillingAddress,
    BillingCity
FROM Invoice
WHERE InvoiceDate IN (
    SELECT InvoiceDate
    FROM Invoice
    WHERE InvoiceId IN (251, 252, 254)
)
ORDER BY InvoiceDate, InvoiceId;


/*
Question 33:
Which tracks have no recorded sales?

NOT EXISTS checks for the absence of a matching invoice line.
*/

SELECT
    t.TrackId,
    t.Composer,
    t.Name AS TrackName
FROM Track AS t
WHERE NOT EXISTS (
    SELECT 1
    FROM InvoiceLine AS il
    WHERE il.TrackId = t.TrackId
)
ORDER BY t.Name, t.TrackId;


/*
Question 34:
Which tracks have no recorded sales, and what are their genres?
*/

SELECT
    t.TrackId,
    t.Name AS TrackName,
    t.Composer,
    g.Name AS Genre
FROM Track AS t
LEFT JOIN Genre AS g
    ON t.GenreId = g.GenreId
WHERE NOT EXISTS (
    SELECT 1
    FROM InvoiceLine AS il
    WHERE il.TrackId = t.TrackId
)
ORDER BY t.Name, t.TrackId;


/* ================================================================
   SECTION 8: OPTIONAL VIEW AND DATA MODIFICATION EXERCISES

   These statements are commented out.
   Run them separately on a practice copy of the database.

   CREATE VIEW changes the database schema.
   INSERT, UPDATE, and DELETE change stored data.
   ================================================================ */


/*
Exercise 1:
Create a reusable view of average invoice value.

CREATE VIEW IF NOT EXISTS V_AvgTotal AS
SELECT
    ROUND(AVG(Total), 2) AS AverageInvoiceValue
FROM Invoice;

SELECT *
FROM V_AvgTotal;
*/


/*
Exercise 2:
Create a view connecting purchased tracks with track details.

CREATE VIEW IF NOT EXISTS V_Tracks_InvoiceLine AS
SELECT
    il.InvoiceId,
    il.TrackId,
    il.UnitPrice,
    il.Quantity,
    t.Name AS TrackName,
    t.Composer,
    t.Milliseconds
FROM InvoiceLine AS il
INNER JOIN Track AS t
    ON il.TrackId = t.TrackId;

SELECT *
FROM V_Tracks_InvoiceLine;
*/


/*
Exercise 3:
Remove the average invoice view.

DROP VIEW IF EXISTS V_AvgTotal;
*/


/*
Exercise 4:
Practice inserting, updating, and deleting an artist.

Run this entire block together in a practice database.
last_insert_rowid() uses the inserted ID rather than assuming it is 276.
ROLLBACK reverses the changes at the end.

BEGIN TRANSACTION;

INSERT INTO Artist (Name)
VALUES ('Practice Artist');

SELECT last_insert_rowid() AS InsertedArtistId;

UPDATE Artist
SET Name = 'Updated Practice Artist'
WHERE ArtistId = last_insert_rowid();

SELECT ArtistId, Name
FROM Artist
WHERE ArtistId = last_insert_rowid();

DELETE FROM Artist
WHERE ArtistId = last_insert_rowid();

ROLLBACK;
*/