create database if not exists salesDataWalmart ;
CREATE TABLE IF NOT EXISTS sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(30) NOT NULL,
    unit_price DECIMAL(10 , 2 ) NOT NULL,
    quantity INT NOT NULL,
    vat FLOAT(6 , 4 ) NOT NULL,
    total DECIMAL(12 , 4 ) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10 , 2 ) NOT NULL,
    gross_margin_pct FLOAT(11 , 9 ) NOT NULL,
    gross_income DECIMAL(12 , 4 ) NOT NULL,
    rating FLOAT(2 , 1 )
);

-- -------------------------------------------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------Feature Engineering------------------------------------------------------------------------

-- Time_Of_Day

ALTER TABLE sales
RENAME COLUMN time TO time_t;

SELECT 
    time_t,
    CASE
        WHEN time_t BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time_t BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Night'
    END AS Time_Of_Day
FROM
    sales; 

ALTER TABLE SALES ADD COLUMN Time_Of_Day VARCHAR(20) ;

UPDATE SALES 
SET 
    Time_Of_Day = (CASE
        WHEN time_t BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time_t BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Night'
    END);

-- DAY_NAME 

SELECT 
    date, DAYNAME(date)
FROM
    sales;

alter table sales add column Day_name varchar(20) after date ;

UPDATE sales 
SET 
    day_name = (DAYNAME(date));

 -- Month_name 
SELECT 
    date, MONTHNAME(date) AS Month_name
FROM
    sales;
    
alter table sales add column Month_name VARCHAR(10) after date ;

UPDATE sales 
SET 
    Month_name = (MONTHNAME(date));
    
    
-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------EDA-------------------------------------------------------------------------------------------

-- Generic Question 
#How many unique city does the data have ?

select distinct city from sales ;

#In which city is each branch ?
SELECT DISTINCT
    city, branch
FROM
    sales; 

-- Product 

#How many unique product line does the data have ? 
SELECT DISTINCT
    COUNT(DISTINCT product_line)
FROM
    sales; 

#What is the most common payment method ?

SELECT 
    payment, COUNT(payment) AS CNT
FROM
    sales
GROUP BY payment
ORDER BY CNT DESC;

#What is most selling product line ?

SELECT 
    product_line, COUNT(product_line) AS CNT
FROM
    sales
GROUP BY product_line
ORDER BY CNT DESC;

#total revune by month ? 
SELECT 
    month_name AS Month, SUM(total) AS total_revune
FROM
    sales
GROUP BY Month_name
ORDER BY total_revune DESC; 

#which month has largest cogs ?

SELECT 
    month_name, SUM(cogs) AS cogs
FROM
    sales
GROUP BY month_name
ORDER BY cogs DESC; 
 
-- which product line has largest revune ?
SELECT 
    product_line, SUM(total) AS Revune
FROM
    sales
GROUP BY product_line
ORDER BY product_line DESC;
  
-- Which city has largest revune ?

SELECT 
    city, SUM(total) AS max_revune
FROM
    sales
GROUP BY city
ORDER BY max_revune DESC
LIMIT 1; 

#Product line with the VAT?
SELECT 
    product_line, AVG(VAT) AS vat_tax
FROM
    sales
GROUP BY product_line
ORDER BY vat_tax DESC; 

 # which branch sold more product than average ?

 SELECT 
    branch, AVG(quantity) AS quantity
FROM
    sales
GROUP BY branch
HAVING AVG(quantity) > (SELECT 
        AVG(fquantity)
    FROM
        sales);
 
# What is the most common product line by gender?

SELECT DISTINCT
    gender, product_line, COUNT(gender) AS total_cnt
FROM
    sales
GROUP BY product_line , gender
ORDER BY total_cnt ASC;

# What is the average rating of each product line?

SELECT 
    product_line, ROUND(AVG(rating), 1) AS Avg_rating
FROM
    sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- ----------------------------------------------SALES-----------------------------------------------------------

#Number of sales made in each time of the day per weekday ?

SELECT 
    time_of_day, COUNT(quantity) AS sales
FROM
    sales
GROUP BY time_of_day
ORDER BY time_of_day DESC; 

#Which of the customer types brings the most revenue?

SELECT 
    customer_type, SUM(total) AS Revune
FROM
    sales
GROUP BY customer_type;  

#Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT 
    city, AVG(vat) AS avg_vat
FROM
    sales
GROUP BY city
HAVING AVG(vat) > (SELECT 
        AVG(vat)
    FROM
        sales)
LIMIT 1;

#Avg VAT Payed By Customer type ?

SELECT 
    customer_type, AVG(vat) AS avg_vat
FROM
    sales
GROUP BY customer_type;

-- ---------------------------------------------CUSTOMER-------------------------------------------------------

#How many unique customer types does the data have?

SELECT DISTINCT
    customer_type
FROM
    sales; 

#What is the gender distribution per branch?

SELECT 
    gender, COUNT(*) AS gender_count
FROM
    sales
WHERE
    branch = 'B'
GROUP BY gender
ORDER BY gender DESC;


#Which time of the day do customers give most ratings?

SELECT 
    time_of_day, AVG(rating) AS Avg_rating
FROM
    sales
GROUP BY time_of_day
ORDER BY Avg_rating DESC; 


#Which time of the day do customers give most ratings per branch?

SELECT 
    branch, time_of_day, AVG(rating) AS avg_rating
FROM
    sales
WHERE
    branch = 'C'
GROUP BY time_of_day
ORDER BY avg_rating;


#Which day of the week has the best avg ratings?

SELECT 
    day_name, AVG(rating) AS avg_rating
FROM
    sales
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 1;

