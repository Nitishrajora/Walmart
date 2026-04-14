-- Walmart Database
use [walmart]

--Walmart dataset
select * from walmart
select count(*) from walmart

-- Business Questions

--What are the different payment methods, and how many transactions and
--items were sold with each method?
select payment_method,
count(invoice_id) [Count],sum(quantity) [Total quantity]
from walmart
group by payment_method


--Which category received the highest average rating in each branch?
with cte as(
select Branch,category,round(AVG(rating),2) [Average Rating],
ROW_NUMBER() over(partition by Branch order by round(AVG(rating),2) desc) [Rank]
from walmart
group by Branch,category)
select * from cte
where [Rank] = 1

--What is the busiest day of the week for each branch based on transaction
--volume?
with cte as( 
SELECT Branch,
    date,payment_method,
    DATENAME(WEEKDAY, TRY_CONVERT(DATE, date, 3)) [Weekday]
FROM walmart),
cte2 as(
select branch,Weekday,count(Weekday) [No of Trans],
ROW_NUMBER() over(partition by Branch order by count(weekday) desc) [Ranking]
from cte
group by Branch,Weekday)
select * from cte2
where [Ranking]=1

--How many items were sold through each payment method?
select payment_method,sum(quantity) [Total Quantity]
from walmart
group by payment_method

--What are the average, minimum, and maximum ratings for each category in
--each city?
select city,category,max(rating) [Max Rating],
round(AVG(rating),2) [Average Rating],
min(rating) [Min Rating]
from walmart
group by city,category

--What is the total profit for each category, ranked from highest to lowest?
with cte as(
select category, sales*profit_margin [Profits]
from walmart)
select category,round(sum(profits),2) [Total Profit]
from cte
group by category
order by [Total Profit] desc

--What is the most frequently used payment method in each branch?
with cte as(
select Branch,payment_method,count(payment_method) [Frequency],
ROW_NUMBER() over(partition by Branch order by count(payment_method) desc) [Most Common method]
from walmart
group by Branch,payment_method)
select Branch,payment_method,[Frequency] from cte
where [Most Common method] =1

--How many transactions occur in each shift (Morning, Afternoon, Evening)
--across branches?
with cte as(
SELECT 
    invoice_id,branch,time,
    CASE 
        WHEN CAST(time AS TIME) >= '05:00:00' AND CAST(time AS TIME) < '12:00:00' THEN 'Morning'
        WHEN CAST(time AS TIME) >= '12:00:00' AND CAST(time AS TIME) < '17:00:00' THEN 'Afternoon'
        WHEN CAST(time AS TIME) >= '17:00:00' AND CAST(time AS TIME) < '21:00:00' THEN 'Evening'
        ELSE 'Night'
    END AS time_category
FROM walmart)
select branch,time_category,count(invoice_id) [Count]
from cte
group by branch,time_category
order by Branch

--Which branches experienced the largest decrease in revenue compared to
--the previous year?
WITH cte AS (
    SELECT 
        Branch,
        YEAR(TRY_CONVERT(DATE, date, 3)) AS yr,
        SUM(Sales) AS revenue
    FROM walmart
    WHERE TRY_CONVERT(DATE, date, 3) IS NOT NULL
    GROUP BY Branch, YEAR(TRY_CONVERT(DATE, date, 3))
),
cte1 AS (
    SELECT 
        Branch,
        SUM(CASE WHEN yr = 2022 THEN revenue END) AS rev_2022,
        SUM(CASE WHEN yr = 2023 THEN revenue END) AS rev_2023
    FROM cte
    GROUP BY Branch
),
cte2 AS (
    SELECT 
        Branch,
        rev_2022,
        rev_2023,
        round((rev_2022 - rev_2023) * 1.0 / NULLIF(rev_2022, 0),2) AS decrease_ratio
    FROM cte1
)
SELECT TOP 5 *
FROM cte2
WHERE decrease_ratio IS NOT NULL
ORDER BY decrease_ratio DESC














































