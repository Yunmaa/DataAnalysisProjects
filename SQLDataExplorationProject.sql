SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;


-- Selecting Data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in each country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Nigeria' AND continent IS NOT NULL
ORDER BY 1, 2;


-- Total Cases vs Population
-- Shows the percentage of population contracted COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Countries with highest infection rate companies to population
SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY PercentPopulationInfected desc;


-- Showing Countries with highest death count per population
SELECT continent, location, population, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY HighestDeathCount desc;


-- Showing continent with highest death count
SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount desc;


-- Global Numbers
-- SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
-- the above SELECT statement can also be written in a different to allow for the use of GROUP BY fn
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


-- Global total_cases vs total_deaths
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;


-- Total population vs vaccinations
SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingvaccinations
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null --and new_vaccinations is not null
GROUP BY cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
ORDER BY 2, 3;


-- to check the total pop vs vaccination, using CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingvaccinations)
as
(
SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingvaccinations
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
GROUP BY cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
)

SELECT *, (rollingvaccinations/population)*100 AS PercPopVac
FROM PopvsVac;


-- using TEMP Table
Drop Table if exists #PercPopVac
Create Table #PercPopVac
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinations numeric
)

Insert into #PercPopVac
SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingvaccinations
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
GROUP BY cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations

SELECT *, (rollingvaccinations/population)*100 percpopvac
FROM #PercPopVac;


-- Create view to store data for later visualizations
Create View PercPopVac as
SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rollingvaccinations
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
GROUP BY cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations

SELECT *
FROM PercPopVac;