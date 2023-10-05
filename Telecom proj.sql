use Telecom;

select * from dbo.telecom_customer_churn;

-- Checking total entries
select count(*)Customers 
from dbo.telecom_customer_churn;

-- Checking for duplicates
SELECT Customer_ID, COUNT(Customer_ID) Count
FROM dbo.telecom_customer_churn
GROUP BY Customer_ID
HAVING COUNT(Customer_ID) > 1  -- No output, meaning no duplicates.

/*Calculate the totals 

What is the status and percentage of customers ? */

SELECT Customer_Status, 
COUNT(Customer_ID) AS Count,
CEILING((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER()) AS Rate 
FROM dbo.telecom_customer_churn
GROUP BY Customer_Status;

-- What is the total revenue? 

SELECT 
round(SUM(Total_Revenue),2) Total_revenue
FROM dbo.telecom_customer_churn; 

-- What is the revenue distribution of customer status? How many percent of revenue was lost?

SELECT Customer_Status, 
COUNT(Customer_ID) AS Count,
ROUND((SUM(Total_Revenue) * 100.0) / SUM(SUM(Total_Revenue)) OVER(), 1) AS RevenuePercent 
FROM dbo.telecom_customer_churn
GROUP BY Customer_Status; 

/* Demographics data exploration

What percentage of gender churned ?  */

SELECT gender,
COUNT(Customer_ID) AS Count,
ROUND((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER(),2) AS Percentage
FROM dbo.telecom_customer_churn
where Customer_Status = 'Churned'
GROUP BY gender;

-- What is the percentage of marital status of churned customers ?

SELECT married,
COUNT(Customer_ID) AS Count,
CEILING((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER()) AS Churn_Rate 
FROM dbo.telecom_customer_churn
where Customer_Status = 'Churned'
GROUP BY married;

-- How many of the churned customers have dependents ? 

SELECT
    CASE 
        WHEN Number_of_Dependents > 0 THEN 'Yes'
        ELSE 'No'
    END AS Dependents,
    ROUND(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER(),1) AS Churn_Percentage
FROM
dbo.telecom_customer_churn
WHERE
  Customer_Status = 'Churned'
GROUP BY
     CASE 
        WHEN Number_of_Dependents > 0 THEN 'Yes'
        ELSE 'No'
    END
ORDER BY Churn_Percentage DESC; -- 94.3% of churned customers don't have kids

--  Finding the age bracket of the data 
SELECT min(age) Min_age, max(age) Max_age
FROM dbo.telecom_customer_churn; -- 19 min and 80 max. Next create a bin of ages 

-- What is the age distribution of churned customers?

SELECT
    CASE 
        WHEN Age >= 19 and age < 25 then '19-25'
		WHEN Age >= 25 and age < 44 then '26-44'
		WHEN Age >= 44 and age < 59 then '45-59'
        ELSE '60-80'
    END as Age_bin,
    ROUND(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER(),1) AS Churn_Percentage
FROM
dbo.telecom_customer_churn
WHERE
  Customer_Status = 'Churned'
GROUP BY
      CASE 
        WHEN Age >= 19 and age < 25 then '19-25'
		WHEN Age >= 25 and age < 44 then '26-44'
		WHEN Age >= 44 and age < 59 then '45-59'
        ELSE '60-80'
    END 
ORDER BY Churn_Percentage DESC;  -- 58.3% of churned customers are within age range of 30-65 years

/* Root cause analysis. Analysis on services 

What is the tenure of churned customers? */

SELECT min(Tenure_in_Months) Min_Tenure, max(Tenure_in_Months) Max_Tenure
FROM dbo.telecom_customer_churn; -- Min and max tenure = 1:72 months 

SELECT
    CASE 
        WHEN Tenure_in_Months <= 6 THEN '6 months'
        WHEN Tenure_in_Months <= 12 THEN '1 Year'
        WHEN Tenure_in_Months <= 24 THEN '2 Years'
        ELSE '> 2 Years'
    END AS Tenure,
    ROUND(COUNT(Customer_ID) * 100.0 / SUM(COUNT(Customer_ID)) OVER(),1) AS Churn_Percentage
FROM
dbo.telecom_customer_churn
WHERE
Customer_Status = 'Churned'
GROUP BY
    CASE 
        WHEN Tenure_in_Months <= 6 THEN '6 months'
        WHEN Tenure_in_Months <= 12 THEN '1 Year'
        WHEN Tenure_in_Months <= 24 THEN '2 Years'
        ELSE '> 2 Years'
    END
ORDER BY
Churn_Percentage DESC; -- 41.9% OF churned customers are only 6 months in tenure.

-- What's distribution of contracts of churned customers ?

SELECT Contract,
COUNT(Customer_ID) AS Count,
CEILING((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER()) AS ChurnRate 
FROM dbo.telecom_customer_churn
where Customer_Status = 'Churned'
GROUP BY Contract; -- 89% of customers are on month-to-month contract

-- Which payment method were the churned customers using ?

SELECT Payment_Method,
COUNT(Customer_ID) AS Count,
CEILING((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER()) AS ChurnRate 
FROM dbo.telecom_customer_churn
where Customer_Status = 'Churned'
GROUP BY Payment_Method; -- 72% of churners used bankwithdrawals as payment method

-- How many of them were on premium tech support ?

SELECT Premium_Tech_Support,
CEILING((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER()) AS ChurnRate 
FROM dbo.telecom_customer_churn
where Customer_Status = 'Churned'
group by Premium_Tech_Support
order by ChurnRate desc;  -- 78% of churners weren't on premium tech support

-- What offers were the customers on ?

SELECT Offer,
CEILING((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER()) AS ChurnRate 
FROM dbo.telecom_customer_churn
where Customer_Status = 'Churned'
GROUP BY Offer 
order by ChurnRate desc; -- 57% of churned customers are not on any offers. 

-- What internet type did the customers use ?

SELECT Internet_Type,
CEILING((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER()) AS ChurnRate 
FROM dbo.telecom_customer_churn
where Customer_Status = 'Churned'
GROUP BY Internet_Type
order by ChurnRate desc; -- 67% of churned customers used Fiber Optic 

-- What were the main reasons of churning ?

SELECT Churn_Category,
CEILING((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER()) AS ChurnRate 
FROM dbo.telecom_customer_churn
where Customer_Status = 'Churned'
GROUP BY Churn_Category
order by ChurnRate desc; -- 45% churned due to the competitor

-- What were the reasons for churn ?

SELECT top 5 Churn_Reason,
round((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER(),2) AS ChurnRate 
FROM dbo.telecom_customer_churn
where Customer_Status = 'Churned'
GROUP BY Churn_Reason
order by ChurnRate desc; -- 17% churned because of competitor who had better devices and better offer.

-- which states were most affected?

SELECT top 5 City,
CEILING((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER()) AS ChurnRate
FROM dbo.telecom_customer_churn
where Customer_Status = 'Churned'
GROUP BY City
order by ChurnRate desc; -- San Diego with highest churn of 5%

-- What were the major reasons of churn in San Diego?

SELECT top 5 Churn_Reason,
CEILING((COUNT(Customer_ID) * 100.0) / SUM(COUNT(Customer_ID)) OVER()) AS ChurnRate, 
COUNT(Customer_ID) Count
FROM dbo.telecom_customer_churn
where Customer_Status = 'Churned' and city = 'San Diego'
GROUP BY Churn_Reason
order by ChurnRate desc; --79% churned because competitor made a better offer.
