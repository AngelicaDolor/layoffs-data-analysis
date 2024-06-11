/* Select all records from 'layoffs_staging' table. */

SELECT *
FROM layoffs_staging;

/* Step 1: Identify duplicates. */

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') AS row_num
FROM layoffs_staging;

-- This query identifies potential duplicates by assigning row numbers based on specified columns
-- The 'row_number' assigns a unique number to each row within the partition

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, date, stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

-- Usage of CTE to keep code organized and perform multilevel aggregations, and refine identification of duplicates
-- Select companies with duplicate rows to add row number to each record by partition and select rows where 'row_num' is greater than 1
-- row_num > 1 are duplicate rows

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Created new table to store cleaned data

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- This query selects rows from the newly created layoffs_staging2 table where row_num is greater than 1, identifying duplicate records in the new table.

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off, `date`, stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Data from layoffs_staging is inserted into layoffs_staging2 with row numbers to identify duplicates.

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Finally, duplicate rows are removed from layoffs_staging2 based on the row numbers.

/* 2. Standardizing Data */

/* Trim whitespace from company names */

SELECT DISTINCT company
FROM layoffs_staging2;

-- Select distinct company names to identify any that need trimming

SELECT DISTINCT company, TRIM(company)
FROM layoffs_staging2; 

-- Select distinct company names along with their trimmed versions for comparison

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Update the company names to remove leading and trailing whitespace

/* Standardize industry names */

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Select distinct industry names to identify variations

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Select records where industry starts with 'Crypto' to check for variations

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- Standardize all industry names starting with 'Crypto' to 'Crypto'

/* Standardize country names */

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Select distinct country names to identify variations

SELECT DISTINCT *
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;

-- Select records where country starts with 'United States' to check for variations

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- Select distinct country names along with their trimmed versions to check for trailing periods

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Update the country names to remove trailing periods

/* Standardize date format */

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Convert the date strings to date format using the pattern '%m/%d/%Y'

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Update the date column to the converted date format

SELECT `date`
FROM layoffs_staging2;

-- Select the date column to verify the conversion

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Modify the date column to the DATE data type to ensure proper date storage

/* 3. Null Values */

/* Removing Records with Insufficient Layoff Information */

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Select records where both total_laid_off and percentage_laid_off are NULL
-- These records lack sufficient information on layoffs

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete records from layoffs_staging2 where both total_laid_off and percentage_laid_off are NULL

/* Handling Missing Industry Data */

SELECT industry
FROM layoffs_staging2;

-- Select distinct industry values to identify missing or empty entries

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Select records where industry is NULL or empty

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Update records with empty industry to NULL for consistency

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Select all records for the company 'Airbnb' to inspect data for potential updates

/* Filling Missing Industry Data */

SELECT *
FROM layoffs_staging2 t1 -- records with NULL industry
JOIN layoffs_staging2 t2 -- records with NOT NULL industry
    ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Join t1 (records with NULL industry) and t2 (records with NOT NULL industry) on company and location
-- Select records where t1 industry is NULL and t2 industry is NOT NULL to fill missing data

UPDATE layoffs_staging2 t1 -- updating t1
JOIN layoffs_staging2 t2  -- with t2 table where companies and locations match
    ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Update t1 industry with t2 industry where t1 industry is NULL and t2 industry is NOT NULL

/* Verify Data After Updates */

SELECT *
FROM layoffs_staging2;

-- Select all records from layoffs_staging2 to verify data after updates


/* Step 4: Remove Columns or Rows */

/* Select all records from 'layoffs_staging2' table */

SELECT *
FROM layoffs_staging2;

-- This query selects all records from the 'layoffs_staging2' table
-- It is useful to review the current structure and data of the table

/* Drop the 'row_num' column from 'layoffs_staging2' */

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- This statement drops the 'row_num' column from the 'layoffs_staging2' table
-- The 'row_num' column was used for identifying duplicates and is no longer needed after the duplicates have been removed
