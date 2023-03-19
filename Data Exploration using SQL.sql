--Covid-19 Data Exploration Project

-- Taking a look at our dataset.
SELECT * FROM project1..Covid_Deaths
ORDER BY 1,2;


-- Looking at Total Cases Vs Total Deaths
-- Shows the chance of dying if infected in a particular country.

SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 AS Death_Percentage
FROM project1..Covid_Deaths
WHERE location LIKE 'India'
ORDER BY Death_Percentage DESC;
/*
 As we can see the highest death percentage in India was 3.595%.
 Total Deaths in India as of 18-02-2023 are 5,30,757.
 Total number of cases were 4,46,86,001.
*/


-- Looking at Total Cases Vs Population
-- Shows the percentage of people infected in a particular country.

SELECT location, date,population, total_cases, 
(total_cases/population)*100 AS Infection_Percentage
FROM project1..Covid_Deaths
ORDER BY 1,2;


-- Countries with the highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count,  
Max((total_cases/population))*100 AS Percent_Population_Infected
From project1..Covid_Deaths
GROUP By location, population
ORDER BY Percent_Population_Infected DESC;


-- Countries with Highest Death Count Vs Population

SELECT location, MAX(CAST(Total_deaths as int)) as Total_Death_Count
FROM project1..Covid_Deaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY Total_Death_Count DESC;

-- Analysing things by Continent now.

-- Contintents with the highest Death count Vs Population.

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM project1..Covid_Deaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY Total_Death_Count DESC;

-- GLOBAL Statistics

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, 
SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS Death_Percentage
FROM project1..Covid_Deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER 
(PARTITION BY dea.Location ORDER BY dea.location, dea.Date) 
AS Total_People_Vaccinated
FROM project1..Covid_Deaths dea
JOIN project1..Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3;


-- Using CTE(Common Table Expression) to perform calculation on previous query result.

WITH Population_v_Vaccine (continent, location, date, population, new_vaccinations,
Total_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER 
(PARTITION BY dea.Location ORDER BY dea.location, dea.Date) 
AS Total_People_Vaccinated
FROM project1..Covid_Deaths dea
JOIN project1..Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (Total_People_Vaccinated/population)*100 AS TPV_Percentage
FROM Population_v_Vaccine;


-- Using Temp Tables

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population BIGINT,
New_vaccinations BIGINT,
Total_People_Vaccinated BIGINT
)

INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER 
(PARTITION BY dea.Location ORDER BY dea.location, dea.Date) 
AS Total_People_Vaccinated

FROM project1..Covid_Deaths dea
JOIN project1..Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


SELECT *, (Total_People_Vaccinated/Population)*100 AS TPV_Percentage
FROM #Percent_Population_Vaccinated