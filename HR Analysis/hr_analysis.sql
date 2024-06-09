-- explore the loaded data into hr_data
SELECT * FROM hr_data;

-- explore table structure
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'hr_data';


-- Fix column "termdate" formatting
-- format termdate datetime UTC values
-- Update date/time to date
UPDATE hr_data
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');

-- Create new column
ALTER TABLE hr_data
ADD new_termdate DATE;

-- Update termdate into new_termdate column
UPDATE hr_data
SET new_termdate = CASE
	WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1 
		THEN CAST (termdate AS DATETIME) 
		ELSE NULL 
	END;

-- Create 'age' column
ALTER TABLE hr_data
ADD age nvarchar(50);

-- Populate new column with age
UPDATE hr_data
SET age = DATEDIFF(YEAR, birthdate,GETDATE());

-- QUESTIONS TO ANSWER FROM THE DATA--

-- 1. What's the age distribution in the company?
--- Age distribution
SELECT MIN(age) AS YOUNGEST, MAX(age) as OLDEST
FROM hr_data;
--- Age group
SELECT age_group,
COUNT(*) AS count
FROM (
SELECT
CASE
	WHEN age >= 21 AND age <= 30 THEN '21-30'
	WHEN age >= 31 AND age <= 40 THEN '31-40'
	WHEN age >= 41 AND age <= 50 THEN '41-50'
	ELSE '50+'
	END AS age_group
FROM hr_data
WHERE new_termdate IS NULL) AS subquery
GROUP BY age_group
ORDER BY age_group;

--- Age group by gender
SELECT age_group, gender,
COUNT(*) AS count
FROM (
SELECT
CASE
	WHEN age >= 21 AND age <= 30 THEN '21-30'
	WHEN age >= 31 AND age <= 40 THEN '31-40'
	WHEN age >= 41 AND age <= 50 THEN '41-50'
	ELSE '50+'
	END AS age_group, gender
FROM hr_data
WHERE new_termdate IS NULL) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 2. What's the gender breakdown in the company?
SELECT gender,
COUNT(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC;

-- 3. How does gender vary across departments and job titles?
--- Departments
SELECT department, gender,
COUNT(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department, gender
ORDER BY department, gender ASC;

--- Job titles
SELECT department, jobtitle, gender,
COUNT(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender ASC;

-- 4. What's the race distribution in the company?
SELECT race,
COUNT(*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY race
ORDER BY count DESC;

-- 5. What's the average length of employment in the company?
SELECT 
AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE();

-- 6. Which department has the highest turnover rate in percentage?
SELECT
	department, total_count, terminated_count,
	(ROUND(CAST(terminated_count AS FLOAT)/total_count, 2)) * 100 AS turnover_rate
	FROM 
		(SELECT
		department, 
		COUNT(*) AS total_count,
		SUM(CASE
			WHEN new_termdate IS NOT NULL AND new_termdate <= getdate()
				THEN 1 ELSE 0
			END
		) AS terminated_count
	FROM hr_data
	GROUP BY department
	) AS Subquery
ORDER BY turnover_rate DESC;

-- 7. What's the tenure distribution for each department?
SELECT department,
AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE()
GROUP BY department
ORDER BY tenure DESC;

-- 8. What's the distribution of employess across different states?
SELECT location_state,
COUNT (*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

-- 9. How are job titles distributed in the company?
SELECT jobtitle,
COUNT (*) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;


-- 10. How have employee hiring numbers changed over time?
--- 1) calculate hires
--- 2) calculate terminations
--- 3) (hires-terminations)/hires percent hire change

SELECT 
	hire_year, 
	hires, 
	terminations,
	hires-terminations AS net_change,
	(ROUND(CAST(hires-terminations AS FLOAT)/hires, 2)) * 100 AS percent_hire_change
	FROM (
		SELECT YEAR(hire_date) AS hire_year,
			COUNT (*) as hires,
			SUM( CASE
				WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
				END
				) AS terminations
			FROM hr_data
			GROUP BY YEAR(hire_date)
	) AS subquery
ORDER BY hire_year;