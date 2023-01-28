-- name: covid-queries
-- description: exploring covid deaths and covid vaccinations
-- author: Gustavo Sopena

-- Introduction

-- show table data
-- `order by` means to sort the columns with that index value
-- note that columns are 1-based
-- `limit` means to show the specified amount of rows

select *
from COVID.CovidDeaths
order by 3,4
limit 5

select *
from COVID.CovidVaccinations
order by 3,4
limit 5

-- count the number of rows in the table
-- 231,871

select count(*)
from COVID.CovidDeaths

select count(*)
from COVID.CovidVaccinations

-- Exploring COVID.CovidDeaths

-- show the unique days from the dataset

select distinct date
from COVID.CovidDeaths
where continent is not null

select distinct date
from COVID.CovidVaccinations
where continent is not null

-- we can show a select columns
-- as in the following code

select location, date, total_cases, new_cases, total_deaths, population
from COVID.CovidDeaths
order by 1,2
limit 10

-- total cases vs total deaths
-- we obtain the percentage of individuals that died from covid
-- note that we can think of this ratio as the likelihood of dying to COVID-19
-- also, we restrict the cases to rows that include "states" within their location

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from COVID.CovidDeaths
where location like '%states%'
order by 1,2

-- total cases vs population
-- we obtain the percentage of individuals that were infected by covid

select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from COVID.CovidDeaths
where location like '%states%'
order by 1,2

-- what country has the highest infection rates (compared to the population)

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as HighestInfectedPercentage
from COVID.CovidDeaths
-- where location like '%states%'
group by location, population
order by HighestInfectedPercentage desc

-- note that the following lines of code did not seemed to work at the time of working on this document
-- the code is suppose to obtain what countries have the highest death counts per population
-- we use a method called 'cast' to convert the column from 'string' to 'int'
-- this is not needed if the column was already of type 'int'

-- select location, max(cast(total_deaths as int)) as HighestDeathCount
-- from COVID.CovidDeaths
-- where continent is not null
-- group by location
-- order by HighestDeathCount desc

-- get the max death count for each continent

select continent, max(total_deaths) as HighestDeathCount
from COVID.CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

-- other lines of code that do not seem to work at the time of writing
-- this code is suppose to show the continent with the highest death count

-- select date, total_deaths, total_cases, (total_deaths/total_cases) * 100 as DeathPercentage
-- from COVID.CovidDeaths
-- where continent is not null
-- group by date
-- order by 1, 2

-- The bottom code does the following:
-- * for each unique day in table(COVID.CovidDeaths), take the sum of all values from the `new_cases` column (similar result for the `new_deaths`)
-- * in the third column, we answer the question:
--   Out of the new cases, what is the percentage of individuals that have died?
--   for that we use:
--   new_deaths / new_cases
-- * the code is ignoring rows where the `continent` column is NULL (OR we are using the rows with data in it)
-- * order the new columns by `date` and `AggregateNewCases`
-- Result:
-- We see the total new cases of COVID-19 throughout the world along with the percentage of deaths to cases.

-- put all together the total number of NEW cases per date

select date, sum(cast(new_cases as float)) as AggregateNewCases, sum(cast(new_deaths as float)) as AggregateNewDeaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as WorldDeathPercentage
from COVID.CovidDeaths
where continent is not null
group by date
order by 1, 2

-- If we remove the `date` column and the `group by` statement, we are really saying to retrieve the total new cases count from the time frame in the dataset.
-- In other words, what is the total vaccination count for the last 2 years? (the current time frame of the dataset)
-- Result:
-- We see the total new cases count, the total new deaths count, and the percentage of deaths to cases.

-- e.g.,
-- |AggregateNewCases|AggregateNewDeaths|WorldDeathPercentage|
-- |-----------------|------------------|--------------------|
-- |629211653|6554559.0|1.0417097281572438|

-- Exploring COVID.CovidVaccinations

-- The columns from the COVID.CovidVaccinations table of use are:
-- * `date`
-- * `location`
-- * `new_vaccinations`
-- * `total_vaccinations`
-- * `people_vaccinated`
-- * `people_fully_vaccinated`
-- With that, we `join` the two tables together.

-- With the two tables, we want to answer the question:
-- What is the total amount of people in the world that have been vaccinated?

-- The following query answers this question (sort of).
-- It gives us the number of new vaccinations per day for each location by joining the covid deaths and covid vaccinations tables

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from COVID.CovidDeaths dea
join COVID.CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2, 3
-- limit 100

-- Here, we use a Common Table Expression (CTE) to add a fourth column to the output table:
-- * a `sum` over each `location` (e.g., Albania, Canada) and by each location's `date`
-- * the column is named `RollingVaccinations` or `AggregateVaccinations`
-- * we can think of this as "I am going to sum the `new_vaccinations` every time there is a match in the `location`, and at the same time, start a new sum of vaccinations each time I see a new location and/or date"
-- A fifth column is also added to see the percentage of rolling vaccinations vs population
-- note that we can change columns' type with convert(datatype, column)

with rVaccTable as (
    select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
    from COVID.CovidDeaths dea
    join COVID.CovidVaccinations vac
        on dea.location = vac.location
        and dea.date = vac.date
    where dea.continent is not null
    -- order by 2, 3
    -- limit 100
)
select continent, location, date, population, new_vaccinations, RollingVaccinations, RollingVaccinations/population*100
from rVaccTable

-- In answering the above question, suppose that the population count is constant (deaths are not accounted for per day).
-- We make a temporary table to contain the rolling count of vaccinations since we cannot use it at the time of creation.
-- This is done with the `with` clause.
-- This code answers the question by looking at the percentage.
-- Since it creates a rolling percentage value, we can look at the max vaccinated people count in ratio with the population count.
-- For example,
-- |rVacc|population|percent|
-- |---|---|---|
-- |60| 12345| ~0.48|
-- |161| 12345| ~1.30|

-- note that some percentages exceed 100 percent
-- this likely means that there was an over count of individuals that receive multiple vaccinations
