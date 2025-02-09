USE ecomm;
SELECT * FROM customer_churn;
SET  sql_safe_updates = 0;


-- 1. Data Cleaning:
-- 1.1 Handling Missing Values and Outliers:
/* a) Impute mean for the following columns, and round off to the nearest integer if
	  required: WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear,
	  DaySinceLastOrder. */
-- WarehouseToHome 
		SELECT WarehouseToHome , COUNT(*) FROM  customer_churn WHERE WarehouseToHome IS  NULL  GROUP BY WarehouseToHome  ;   
		SET @mean_WarehouseToHome = (SELECT ROUND(AVG(WarehouseToHome)) FROM customer_churn WHERE WarehouseToHome IS NOT NULL) ;
		UPDATE customer_churn  
		SET WarehouseToHome =  @mean_WarehouseToHome                  
		WHERE WarehouseToHome IS  NULL;                
		SELECT DISTINCT WarehouseToHome FROM  customer_churn  ;  

-- HourSpendOnApp
		SET  @mean_HourSpendOnApp = (SELECT ROUND(AVG(HourSpendOnApp)) FROM customer_churn  WHERE WarehouseToHome IS NOT NULL) ;
		UPDATE customer_churn
		SET HourSpendOnApp = @mean_HourSpendOnApp 
		WHERE HourSpendOnApp IS  NULL;
		SELECT DISTINCT HourSpendOnApp FROM  customer_churn  ; 

-- OrderAmountHikeFromlastYear
		SET  @mean_OrderAmountHikeFromlastYear = (SELECT ROUND(AVG(OrderAmountHikeFromlastYear)) FROM customer_churn WHERE OrderAmountHikeFromlastYear IS NOT NULL);
		UPDATE customer_churn
		SET OrderAmountHikeFromlastYear = @mean_OrderAmountHikeFromlastYear
		WHERE OrderAmountHikeFromlastYear IS NULL;
		SELECT DISTINCT OrderAmountHikeFromlastYear FROM  customer_churn  ; 

-- DaySinceLastOrder
		SET  @mean_DaySinceLastOrder  = (SELECT ROUND(AVG(DaySinceLastOrder)) FROM customer_churn WHERE DaySinceLastOrder IS NOT NULL);
		UPDATE customer_churn
		SET DaySinceLastOrder = @mean_DaySinceLastOrder
		WHERE DaySinceLastOrder IS NULL;
		SELECT DISTINCT DaySinceLastOrder FROM  customer_churn  ; 


/* b) Impute mode for the following columns: Tenure, CouponUsed, OrderCount.*/
-- Impute mode for Tenure
		SET @mode_Tenure = (SELECT Tenure FROM customer_churn WHERE Tenure IS NOT NULL
							GROUP BY Tenure ORDER BY COUNT(*) DESC LIMIT 1);
		UPDATE customer_churn
		SET Tenure = @mode_Tenure
		WHERE Tenure IS NULL;
		SELECT DISTINCT Tenure FROM  customer_churn  ; 

-- Impute mode for CouponUsed
		SET @mode_CouponUsed = (SELECT CouponUsed FROM customer_churn WHERE CouponUsed IS NOT NULL
								GROUP BY CouponUsed ORDER BY COUNT(*) DESC LIMIT 1);
		UPDATE customer_churn
		SET CouponUsed = @mode_CouponUsed
		WHERE CouponUsed IS NULL;
		SELECT DISTINCT CouponUsed FROM  customer_churn  ; 

-- Impute mode for OrderCount
		SET @mode_OrderCount = (SELECT OrderCount FROM customer_churn WHERE OrderCount IS NOT NULL
								GROUP BY OrderCount ORDER BY COUNT(*) DESC LIMIT 1);
		UPDATE customer_churn
		SET OrderCount = @mode_OrderCount
		WHERE OrderCount IS NULL;
		SELECT DISTINCT OrderCount FROM  customer_churn  ; 

/* c) Handle outliers in the 'WarehouseToHome' column by deleting rows where the
	  values are greater than 100.*/
		SELECT DISTINCT WarehouseToHome , COUNT(*) FROM  customer_churn  GROUP BY WarehouseToHome ; 
		DELETE FROM customer_churn
		WHERE WarehouseToHome > 100;
		SELECT DISTINCT WarehouseToHome FROM  customer_churn  ; 
  

-- 1.2 Dealing with Inconsistencies:
/* a) Replace occurrences of “Phone” in the 'PreferredLoginDevice' column and
	  “Mobile” in the 'PreferedOrderCat' column with “Mobile Phone” to ensure
	  uniformity. */
-- 	  Replace "Phone" with "Mobile Phone" in 'PreferredLoginDevice'
		UPDATE customer_churn
		SET PreferredLoginDevice = 'Mobile Phone'
		WHERE PreferredLoginDevice = 'Phone';
		SELECT DISTINCT PreferredLoginDevice FROM  customer_churn  ; 

-- 	  Replace "Mobile" with "Mobile Phone" in 'PreferedOrderCat'
		UPDATE customer_churn
		SET PreferedOrderCat = 'Mobile Phone'
		WHERE PreferedOrderCat = 'Mobile';
		SELECT DISTINCT PreferedOrderCat FROM  customer_churn  ; 


/* b) Standardize payment mode values: Replace "COD" with "Cash on Delivery" and
      "CC" with "Credit Card" in the PreferredPaymentMode column.*/
		UPDATE customer_churn
		SET PreferredPaymentMode = REPLACE(PreferredPaymentMode, 'COD', 'Cash on Delivery'),
			PreferredPaymentMode = REPLACE(PreferredPaymentMode, 'CC', 'Credit Card');
		SELECT DISTINCT PreferredPaymentMode FROM  customer_churn  ; 



-- 2. Data Transformation:
-- 2.1 Column Renaming:
-- a) Rename the column "PreferedOrderCat" to "PreferredOrderCat".
		ALTER TABLE customer_churn
		RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;
-- b) Rename the column "HourSpendOnApp" to "HoursSpentOnApp".
		ALTER TABLE customer_churn
		RENAME COLUMN HourSpendOnApp TO HoursSpendOnApp;

-- 2.2 Creating New Columns:
/* a) Create a new column named ‘ComplaintReceived’ with values "Yes" if the
	  corresponding value in the ‘Complain’ is 1, and "No" otherwise. */
		ALTER TABLE customer_churn
		ADD COLUMN ComplaintReceived VARCHAR(10);
		UPDATE customer_churn
		SET ComplaintReceived = IF(Complain = 1, 'Yes', 'No');
		SELECT DISTINCT ComplaintReceived  FROM  customer_churn  ; 
		
/* b) Create a new column named 'ChurnStatus'. Set its value to “Churned” if the
      corresponding value in the 'Churn' column is 1, else assign “Active”. */
		ALTER TABLE customer_churn
		ADD COLUMN ChurnStatus VARCHAR(10);
        UPDATE customer_churn
		SET ChurnStatus = IF(Churn = 1, 'Churned', 'Active');
		SELECT  ChurnStatus  FROM  customer_churn  ;
		
-- 2.3 Column Dropping:
-- a) Drop the columns "Churn" and "Complain" from the table.     
		ALTER TABLE customer_churn
		DROP COLUMN Churn,
		DROP COLUMN Complain;
        
        
        
-- 3. Data Exploration and Analysis:
-- 3.1 Retrieve the count of churned and active customers from the dataset.
		SELECT ChurnStatus, COUNT(*) Count  FROM customer_churn GROUP BY ChurnStatus;
        
-- 3.2 Display the average tenure and total cashback amount of customers who churned.
		SELECT  *  FROM  customer_churn  ;
        SELECT ROUND(AVG(tenure)) Avg_tenure , SUM(CashbackAmount) TotalCashbackAmount
        FROM customer_churn WHERE ChurnStatus = 'Churned';
        
-- 3.3 Determine the percentage of churned customers who complained.
		SELECT CONCAT(ROUND(SUM(IF(ComplaintReceived = 'Yes', 1,0))/ COUNT(*)*100,2),'%') AS ComplainedPercentage
		FROM customer_churn WHERE ChurnStatus = 'Churned';
        SELECT DISTINCT  ComplaintReceived , COUNT(*) FROM customer_churn WHERE ChurnStatus = 'Churned' GROUP BY ComplaintReceived ;
        
-- 3.4 Find the gender distribution of customers who complained.   
		SELECT Gender, COUNT(*) AS Count FROM customer_churn
        WHERE ComplaintReceived = 'Yes' GROUP BY Gender; 
        
/* 3.5 Identify the city tier with the highest number of churned customers whose
	   preferred order category is Laptop & Accessory. */
       SELECT CityTier, COUNT(*) ChurnedCustomers  FROM customer_churn
       WHERE ChurnStatus = 'Churned' AND PreferredOrderCat = 'Laptop & Accessory'
       GROUP BY CityTier ORDER BY ChurnedCustomers DESC LIMIT 1;
       
-- 3.6 Identify the most preferred payment mode among active customers.
		SELECT PreferredPaymentMode , COUNT(*) ActiveCustomers FROM customer_churn WHERE ChurnStatus = 'Active' 
        GROUP BY PreferredPaymentMode ORDER BY ActiveCustomers DESC  LIMIT 1;
        
/* 3.7 Calculate the total order amount hike from last year for customers who are single
	   and prefer mobile phones for ordering. */
       SELECT SUM(OrderAmountHikeFromlastYear) TotalHike FROM customer_churn 
       WHERE MaritalStatus ='Single' AND PreferredOrderCat = 'Mobile Phone' ;
       
/* 3.8 Find the average number of devices registered among customers who used UPI as
	   their preferred payment mode. */
       SELECT FLOOR(AVG(NumberOfDeviceRegistered)) AvgDevices  FROM customer_churn 
       WHERE PreferredPaymentMode = 'UPI';
       
-- 3.9 Determine the city tier with the highest number of customers.
	   SELECT CityTier , COUNT(*) CustomerCount FROM customer_churn 
       GROUP BY CityTier ORDER BY CustomerCount DESC LIMIT 1;
       
-- 3.10 Identify the gender that utilized the highest number of coupons.
		SELECT Gender, SUM(CouponUsed) TotalCoupons FROM customer_churn 
        GROUP BY Gender ORDER BY TotalCoupons DESC LIMIT 1;
        
/* 3.11 List the number of customers and the maximum hours spent on the app in each
	    preferred order category.*/
        SELECT   PreferredOrderCat, COUNT(*) CustomerCount, MAX(HoursSpendOnApp) maximum_hours_spent FROM customer_churn
        GROUP BY PreferredOrderCat ;
        
/* 3.12 Calculate the total order count for customers who prefer using credit cards and
	    have the maximum satisfaction score. */
        SELECT SUM(OrderCount) TotalOrders FROM customer_churn 
        WHERE PreferredPaymentMode = 'Credit Card' 
        AND SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn) ;
        
/* 3.13 How many customers are there who spent only one hour on the app and days
	    since their last order was more than 5? */
		SELECT COUNT(*) CustomerCount FROM customer_churn
        WHERE HoursSpendOnApp = 1 AND DaySinceLastOrder > 5;
        
-- 3.14 What is the average satisfaction score of customers who have complained?
		SELECT FLOOR(AVG(SatisfactionScore)) CustomerCount FROM customer_churn
        WHERE ComplaintReceived = 'Yes';
        
-- 3.15 List the preferred order category among customers who used more than 5 coupons.
		SELECT * FROM customer_churn;
        SELECT PreferredOrderCat , COUNT(*) CustomerCount FROM customer_churn
        WHERE CouponUsed > 5 GROUP BY PreferredOrderCat ORDER BY CustomerCount DESC;
        
-- 3.16 List the top 3 preferred order categories with the highest average cashback amount.
		SELECT PreferredOrderCat , FLOOR(AVG(CashbackAmount)) AvgCashback FROM customer_churn
        GROUP BY PreferredOrderCat ORDER BY AvgCashback DESC LIMIT 3 ;
        
/* 3.17 Find the preferred payment modes of customers whose average tenure is 10
		months and have placed more than 500 orders.  */
        SELECT  PreferredPaymentMode,  COUNT(*) CustomerCount  FROM customer_churn
        WHERE Tenure = 10 AND OrderCount > ((SELECT SUM(OrderCount)  FROM customer_churn) > 500)
        GROUP BY PreferredPaymentMode ORDER BY CustomerCount DESC ;
        
/* 3.18 Categorize customers based on their distance from the warehouse to home such
		as 'Very Close Distance' for distances <=5km, 'Close Distance' for <=10km,
		'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the
		churn status breakdown for each distance category. */ 
        SELECT * FROM customer_churn;
        ALTER TABLE customer_churn 
        ADD COLUMN DistanceCategory VARCHAR(20);
        UPDATE customer_churn
		SET DistanceCategory = 
			CASE 
				WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
				WHEN WarehouseToHome <= 10 THEN 'Close Distance'
				WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
				ELSE 'Far Distance'
			END;
        SELECT DistanceCategory, ChurnStatus, COUNT(*) AS Count FROM customer_churn
		GROUP BY DistanceCategory, ChurnStatus;  
        
/* 3.19 List the customer’s order details who are married, live in City Tier-1, and their
		order counts are more than the average number of orders placed by all customers. */  
        SELECT * FROM customer_churn
        WHERE MaritalStatus = 'Married' AND CityTier =1 AND OrderCount > (SELECT AVG(OrderCount) FROM customer_churn );
        
/* 3.20 a) Create a ‘customer_returns’ table in the ‘ecomm’ database and insert the following data:    
		   ReturnID CustomerID  ReturnDate  RefundAmount
		 1001     50022		 2023-01-01 	2130
		 1002 	  50316		 2023-01-23 	2000
		 1003 	  51099		 2023-02-14 	2290
		 1004 	  52321		 2023-03-08 	2510
		 1005 	  52928		 2023-03-20 	3000
		 1006 	  53749		 2023-04-17 	1740
		 1007 	  54206		 2023-04-21 	3250
		 1008 	  54838		 2023-04-30 	1990  */
		
        CREATE TABLE customer_returns (
        ReturnID INT PRIMARY KEY, 
        CustomerID INT,
        ReturnDate DATE ,
        RefundAmount DECIMAL(10, 2));
        INSERT INTO customer_returns 
		VALUES  (1001, 50022, '2023-01-01', 2130),
				(1002, 50316, '2023-01-23', 2000),
				(1003, 51099, '2023-02-14', 2290),
				(1004, 52321, '2023-03-08', 2510),
				(1005, 52928, '2023-03-20', 3000),
				(1006, 53749, '2023-04-17', 1740),
				(1007, 54206, '2023-04-21', 3250),
				(1008, 54838, '2023-04-30', 1990);
		SELECT * FROM customer_returns;
        
/*     b) Display the return details along with the customer details of those who have
	      churned and have made complaints.*/ 
      SELECT cr.*,cc.* FROM customer_returns AS cr
      JOIN customer_churn AS cc ON cr.CustomerID = cc.CustomerID
      WHERE  cc.ChurnStatus = 'Churned' AND cc.ComplaintReceived = 'Yes';