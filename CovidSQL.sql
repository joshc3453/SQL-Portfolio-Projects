-- Data for this analysis was provided by https://ourworldindata.org/covid-deaths 
-- Data was downloaded in .csv format and cleaned before importing into SQL Server

USE PortfolioProject;

SELECT * FROM CovidDeaths
ORDER BY 3, 4;

--SELECT * FROM CovidVaccinations
--ORDER BY 3, 4;

-- Selecting data to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2;


-- Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in the United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2;


-- Total Cases vs. Population
-- Shows what percentage of population got Covid in the United States
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentpopulationinfected
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highestinfectioncount, MAX((total_cases/population))*100 AS percentpopulationinfected
FROM CovidDeaths
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY percentpopulationinfected DESC;



-- Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS totaldeathcount
FROM CovidDeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC;


-- Continents with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) AS totaldeathcount
FROM CovidDeaths
--WHERE location = 'United States'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC;

-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
FROM CovidDeaths
-- WHERE location = 'United States'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;

-- Global Death Percentage
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
FROM CovidDeaths
-- WHERE location = 'United States'
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Vaccination Data
SELECT * FROM CovidVaccinations;

-- Total population vs. vaccinations, Window Function
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location ORDER BY dea.location,
dea.date) AS rollingtotalvaccinated
--, (rollingtotalvaccinated/population)*100
FROM CovidDeaths AS dea
INNER JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- Using CTE
WITH popvsvac (continent, location, date, population, new_vaccinations, rollingtotalvaccinated) 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location ORDER BY dea.location,
dea.date) AS rollingtotalvaccinated
--, (rollingtotalvaccinated/population)*100
FROM CovidDeaths AS dea
INNER JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (rollingtotalvaccinated/population)*100
FROM popvsvac;


-- Temp Table
DROP TABLE  IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingtotalvaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location ORDER BY dea.location,
dea.date) AS rollingtotalvaccinated
--, (rollingtotalvaccinated/population)*100
FROM CovidDeaths AS dea
INNER JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (rollingtotalvaccinated/population)*100
FROM #PercentPopulationVaccinated;

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by  dea.location ORDER BY dea.location,
dea.date) AS rollingtotalvaccinated
--, (rollingtotalvaccinated/population)*100
FROM CovidDeaths AS dea
INNER JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT * FROM PercentPopulationVaccinated;
