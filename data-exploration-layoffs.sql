/* Select all records from the 'layoffs_staging2' table. */
SELECT *
FROM layoffs_staging2;

/* Determine the maximum number of layoffs and the highest percentage of layoffs. */
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

/* Find companies that laid off 100% of their workforce, ordered by the total number of employees laid off. */
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

/* Find companies that laid off 100% of their workforce, ordered by the amount of funds raised. */
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

/* Aggregate the total number of layoffs per company. */
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

/* Find the earliest and latest dates of layoffs in the dataset. */
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

/* Aggregate the total number of layoffs by industry. */
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

/* Fetch all records from the 'layoffs_staging2' table again for further exploration. */
SELECT *
FROM layoffs_staging2;

/* Aggregate the total number of layoffs by country. */
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

/* Aggregate the total number of layoffs by year. */
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 1 DESC;

/* Aggregate the total number of layoffs by the stage of the company. */
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

/* Calculate the average percentage of layoffs per company. */
SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

/* Aggregate total layoffs by month. */
SELECT SUBSTRING(`date`,6,2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`;

/* Aggregate total layoffs by year-month format. */
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

/* Calculate a rolling sum of total layoffs over time. */
WITH Rolling_Total AS
(
  SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
  FROM layoffs_staging2
  WHERE SUBSTRING(`date`,1,7) IS NOT NULL
  GROUP BY `MONTH`
  ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
  SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

/* Aggregate total layoffs by company, ordered by the total number of layoffs. */
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1
ORDER BY 2 DESC;

/* Aggregate total layoffs by company and year, ordered by company name. */
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1, 2
ORDER BY company ASC;

/* Aggregate total layoffs by company and year, ordered by total layoffs descending. */
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY 1, 2
ORDER BY 3 DESC;

/* Rank companies by total layoffs per year and display all records. */
WITH Company_Year (company, years, total_laid_off) AS
(
  SELECT company, YEAR(`date`), SUM(total_laid_off)
  FROM layoffs_staging2
  GROUP BY 1, 2
)
SELECT *
FROM Company_Year;

/* Rank companies by total layoffs per year and select the top records based on ranking. */
WITH Company_Year (company, years, total_laid_off) AS
(
  SELECT company, YEAR(`date`), SUM(total_laid_off)
  FROM layoffs_staging2
  GROUP BY 1, 2
), Company_Year_Rank AS
(
  SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
  FROM Company_Year
  WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;
