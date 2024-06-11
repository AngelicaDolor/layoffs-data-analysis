# Layoffs Data Analysis

This repository contains the project for data cleaning, exploratory data analysis (EDA), and data visualization on layoffs data.

## Project Overview

This project focuses on cleaning and analyzing a dataset containing information about company layoffs. The primary goals are to ensure the dataset is clean and standardized, perform exploratory data analysis to uncover insights, and visualize the results for better understanding.

## Table of Contents

- [Project Overview](#project-overview)
- [Dataset](#dataset)
- [Steps for Data Cleaning](#steps-for-data-cleaning)
  - [1. Identifying and Removing Duplicates](#1-identifying-and-removing-duplicates)
  - [2. Standardizing Data](#2-standardizing-data)
  - [3. Handling Missing Values](#3-handling-missing-values)
  - [4. Removing Unnecessary Columns](#4-removing-unnecessary-columns)
- [Exploratory Data Analysis (EDA)](#exploratory-data-analysis-eda)
- [Data Visualization](#data-visualization)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Dataset

The dataset used in this project contains information on company layoffs, including company names, locations, industries, total laid off, percentage laid off, dates, stages, countries, and funds raised.

The dataset used in this project can be found on [Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022).

## Steps for Data Cleaning

The full SQL code for the data cleaning process can be found in the [data-cleaning-layoffs.sql](https://github.com/AngelicaDolor/layoffs-data-analysis/blob/main/data-cleaning-layoffs.sql) file in this repository.

### 1. Identifying and Removing Duplicates

The first step is to identify and remove duplicate records from the dataset. Duplicates can skew analysis and lead to incorrect insights. 

```sql
-- Identifying duplicates
WITH duplicate_cte AS
(
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location, 
        industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Removing duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

```
### 2. Standardizing Data

Standardization ensures consistency in data entries. This involves trimming whitespace, standardizing industry names, handling location data, and formatting date fields.

#### a. Trimming Company Names

Remove any leading or trailing whitespace from company names to ensure consistency.

```sql
-- Trimming company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Verifying the change
SELECT DISTINCT company
FROM layoffs_staging2;
```

#### b. Standardizing Industry Names

Unify the industry names for consistency. For example, if there are variations in the way an industry is named, standardize them to a single format.

``` sql
-- Identifying industry names
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Standardizing 'Crypto' industry names
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Verifying the change
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;
```

#### c. Handling Location Data

Ensure consistency in location data by standardizing country names.
```sql
-- Identifying distinct countries
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Standardizing country names by trimming trailing periods
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Verifying the change
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;
```
#### d. Formatting Date Fields

Convert the date fields to a standard date format.
```sql
-- Converting date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Verifying the change
SELECT `date`
FROM layoffs_staging2;

-- Changing date column type to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
```

### 3. Handling Missing Values

Handling missing values is crucial for maintaining the integrity of the dataset. This includes filling in missing values and removing records with insufficient information.


``` sql
-- Removing records with insufficient layoff information
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Filling missing industry data
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
```

### 4. Removing Unnecessary Columns
Remove columns that are no longer needed for analysis to keep the dataset clean and manageable.
``` sql
-- Dropping the 'row_num' column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```
## Exploratory Data Analysis (EDA)

EDA involves examining the dataset to summarize its main characteristics, often using visual methods. This step includes generating descriptive statistics, identifying patterns, and visualizing distributions and relationships.

## Data Visualization

TBA

## Usage
To use this project, follow these steps:

1. Clone the repository:
``` bash
git clone https://github.com/AngelicaDolor/layoffs-data-analysis.git
```
2. Navigate to the project directory:
``` bash
cd layoffs-data-analysis
```
3. Run the SQL scripts to clean the data and perform analysis.

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/AngelicaDolor/layoffs-data-analysis/blob/main/LICENSE) file for details.


