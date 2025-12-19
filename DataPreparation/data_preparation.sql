-- Create database for cleaning --
DROP DATABASE IF EXISTS hr_analytics;
CREATE DATABASE hr_analytics;


-- Use Database
USE hr_analytics;


-- import data from 'Table Data Import Wizard' --
SELECT * FROM hr_analytics.hr_data;


-- Copy of dataset --
DROP TABLE IF EXISTS hr_analytics.hr_data_copy;
CREATE TABLE hr_analytics.hr_data_copy AS
SELECT * FROM hr_analytics.hr_data;


-- rename column's for better understanding --
ALTER TABLE hr_analytics.hr_data
CHANGE COLUMN id Employee_ID VARCHAR(20),
CHANGE COLUMN first_name First_Name VARCHAR(100),
CHANGE COLUMN last_name Last_Name VARCHAR(100),
CHANGE COLUMN age Age INT,
CHANGE COLUMN gender Gender VARCHAR(50),
CHANGE COLUMN race Race VARCHAR(50),
CHANGE COLUMN department Department VARCHAR(50),
CHANGE COLUMN jobtitle Job_Title VARCHAR(100),
CHANGE COLUMN location Work_Location VARCHAR(20),
CHANGE COLUMN termdate Termination_Date VARCHAR(50),
CHANGE COLUMN location_city Location_City VARCHAR(100),
CHANGE COLUMN location_state Location_State VARCHAR(100);


-- Change the birthdate column '04-06-1991' to '1991-06-04' formart --
-- Add a temporary DATE column
ALTER TABLE hr_analytics.hr_data
ADD COLUMN BirthDate_temp DATE;

-- Convert DD-MM-YYYY to YYYY-MM-DD using STR_TO_DATE
UPDATE hr_analytics.hr_data
SET BirthDate_temp = STR_TO_DATE(birthdate, '%d-%m-%Y');

-- Drop old column
ALTER TABLE hr_analytics.hr_data
DROP COLUMN birthdate;

-- Rename temp column
ALTER TABLE hr_analytics.hr_data
CHANGE COLUMN BirthDate_temp BirthDate DATE;


-- Change the hire_date column '20-01-2002' to '2002-01-20' formart --
-- Add a temporary DATE column
ALTER TABLE hr_analytics.hr_data
ADD COLUMN Hire_Date_temp DATE;

-- Convert DD-MM-YYYY to YYYY-MM-DD using STR_TO_DATE
UPDATE hr_analytics.hr_data
SET Hire_Date_temp = STR_TO_DATE(hire_date, '%d-%m-%Y');

-- Drop old column
ALTER TABLE hr_analytics.hr_data
DROP COLUMN hire_date;

-- Rename temp column
ALTER TABLE hr_analytics.hr_data
CHANGE COLUMN Hire_Date_temp Hire_Date DATE;


-- Arrange the Termination_Date column for Visualization --
-- Add temp column
ALTER TABLE hr_analytics.hr_data
ADD COLUMN Termination_Date_temp DATE;

-- Convert empty strings to NULL
UPDATE hr_analytics.hr_data
SET Termination_Date = NULL
WHERE Termination_Date = '';

-- Convert valid values by removing 'UTC'
UPDATE hr_analytics.hr_data
SET Termination_Date_temp = DATE(REPLACE(Termination_Date, ' UTC', ''))
WHERE Termination_Date IS NOT NULL;

-- Drop old column
ALTER TABLE hr_analytics.hr_data
DROP COLUMN Termination_Date;

-- Rename temp column
ALTER TABLE hr_analytics.hr_data
CHANGE COLUMN Termination_Date_temp Termination_Date DATE;


-- Checking Duplicate Data --
SELECT *
FROM (
	SELECT
	ROW_NUMBER() OVER(PARTITION BY First_Name, Last_Name, Age, Gender, Race, Department, 
									Job_Title, Work_Location, Location_City, Location_State,
									BirthDate, Hire_Date, Termination_Date
					 ORDER BY Employee_ID) AS rnk,
	hr_data.*
	FROM hr_analytics.hr_data
    ) AS Duplicate_Value
WHERE rnk > 1;


-- Create Status Column For (to check employee is Active or Terminated) Visulazation --
-- Add a column
ALTER TABLE hr_analytics.hr_data
ADD COLUMN Status VARCHAR(20);

UPDATE hr_analytics.hr_data
SET Status = CASE
    WHEN Termination_Date IS NULL THEN 'Active'
    ELSE 'Terminated'
END;


-- Create a view for save the cleaned file
CREATE OR REPLACE VIEW hr_data_cleaned AS
SELECT 
	Employee_ID, First_Name, Last_Name, Age, Gender, Race, Department,
    Job_Title, Work_Location, Location_City, Location_State, 
    BirthDate, Hire_Date, Termination_Date, Status
FROM hr_analytics.hr_data;

