-- Elias Hilliard
-- Data Cleaning 

select * 
from layoffs

-- 1. Remove Duplicates (without unique ID)
-- 2. Standardize the Data
-- 3. Null Values


-- 1. Remove Duplicates 

-- Creating a duplicate table to avoid making changes to the raw data  

select * into layoffs_staging
from layoffs
where 1 = 0

select * 
from layoffs_staging

insert layoffs_staging
select *
from layoffs;

select *,
row_number() over (
  partition by company, industry, total_laid_off, percentage_laid_off, layoffs_staging.[date]
  order by layoffs_staging.[date]) as row_num
from layoffs_staging;

-- Query tells us the duplicates in the table

with duplicates_cte as (
select *,
row_number() over (
  partition by company, layoffs_staging.location, industry, total_laid_off, percentage_laid_off, stage, country, funds_raised_millions, layoffs_staging.[date]
  order by layoffs_staging.[date]) as row_num
from layoffs_staging
)
select *
from duplicates_cte
where row_num > 1;

-- Copying the same table to remove the duplicates, but added the row_num as a column

USE [global_layoffs]
GO

/****** Object:  Table [dbo].[layoffs_staging]    Script Date: 7/25/2025 6:44:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[layoffs_staging2](
	[company] [nvarchar](50) NULL,
	[location] [nvarchar](50) NULL,
	[industry] [nvarchar](50) NULL,
	[total_laid_off] [nvarchar](50) NULL,
	[percentage_laid_off] [nvarchar](50) NULL,
	[date] [nvarchar](50) NULL,
	[stage] [nvarchar](50) NULL,
	[country] [nvarchar](50) NULL,
	[funds_raised_millions] [nvarchar](50) NULL,
	[row_num] [int]
) ON [PRIMARY]
GO

-- Remove Duplicates
select *
from layoffs_staging2
where row_num > 1;

insert into layoffs_staging2
select *,
row_number() over (
  partition by company, layoffs_staging.location, industry, total_laid_off, percentage_laid_off, stage, country, funds_raised_millions, layoffs_staging.[date]
  order by layoffs_staging.[date]) as row_num
from layoffs_staging;

delete
from layoffs_staging2
where row_num > 1; 

-- 2. Standardizing Data
-- Looking for errors in the data and updating the table
select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct(industry)
from layoffs_staging2
order by 1;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country, trim(Trailing '.' from country)
from layoffs_staging2
order by 1

update layoffs_staging2
set country = trim(Trailing '.' from country)
where country like 'United States%';

-- 3. Null Values 
-- Removing Null Values
select *
from layoffs_staging2
where total_laid_off = 'NULL'
and percentage_laid_off = 'NULL';

select *
from layoffs_staging2
where industry is null

select *
from layoffs_staging2
where company like 'Airbnb'

update layoffs_staging2
set industry = 'NULL'
where industry = ''

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
	and t1.location = t2.location
where t1.industry is null 
and t2.industry is not null;

update t1
set t1.industry = t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
  on t1.company = t2.company
where t1.industry is null 
  and t2.industry is not null;

select * 
from layoffs_staging2
where total_laid_off = 'null'
and percentage_laid_off = 'null';

delete 
from layoffs_staging2
where total_laid_off = 'null'
and percentage_laid_off = 'null';

-- Final Cleaned Data
select *
from layoffs_staging2




