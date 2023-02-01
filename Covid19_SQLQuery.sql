SELECT * FROM dbo.CovidDeath
WHERE continent is not null -- This gets rid of entries that refer to the continent, instead of a country
ORDER BY location, date

--SELECT * FROM dbo.CovidVac
--ORDER BY Location, date

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM dbo.CovidDeath
WHERE continent is not null
ORDER BY location, date

-- Total Cases vs Total deaths. % of dying if you get covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM dbo.CovidDeath
WHERE location LIKE '%states%' AND continent is not null
ORDER BY location, date

-- Total Cases vs Population. % of population that got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercPopulationInfective
FROM dbo.CovidDeath
--WHERE location LIKE '%states%'
ORDER BY location, date

-- Countries with high infection rate compared to population
SELECT location, MAX(total_cases) AS HighestInfection, population, MAX((total_cases/population))*100 as PercPopulationInfected
FROM dbo.CovidDeath
--WHERE location LIKE '%states%' AND continent is not null
GROUP BY location, population
ORDER BY PercPopulationInfected desc

-- Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeath, population, MAX((total_deaths/population))*100 as PercPopulationDeath
FROM dbo.CovidDeath
--WHERE location LIKE '%states%' AND continent is not null
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestDeath desc

-- Broken down by continent

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM dbo.CovidDeath
--WHERE location LIKE '%states%' AND continent is not null
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Shows the continents with the highest count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM dbo.CovidDeath
--WHERE location LIKE '%states%' AND continent is not null
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- International Numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM dbo.CovidDeath
WHERE continent is not null
--GROUP BY date


-- Rolling total of people vaccinated by each country
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated--ROLLING TOTAL
FROM covidinfo.dbo.CovidDeath AS dea
INNER JOIN dbo.CovidVac AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date


-- In the previous query we couldnt refer to a tabled created in the same "SELECT" statement
-- Instead we can use WITH to create the set table first, and then refer to it as part of an analysis
With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated) 
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated--ROLLING TOTAL
FROM covidinfo.dbo.CovidDeath AS dea
INNER JOIN dbo.CovidVac AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(Rolling_People_Vaccinated/population)*100 FROM PopvsVac


--Creating a table to store the information in the previous query
-- DROP statement at the beginning will erase any previous table, allowing one to alter the query below
DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(continent NVARCHAR(255), location NVARCHAR(255), date DATETIME, population numeric, new_vaccinations numeric, 
Rolling_People_Vaccinated numeric)

INSERT into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated--ROLLING TOTAL
FROM covidinfo.dbo.CovidDeath AS dea
JOIN covidinfo.dbo.CovidVac AS vac
ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent is not null

SELECT *,(Rolling_People_Vaccinated/population)*100 
FROM PercentPopulationVaccinated;



-- Storing data in view
CREATE VIEW PercentPopulationVaccinated2 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
AS Rolling_People_Vaccinated--ROLLING TOTAL
FROM covidinfo.dbo.CovidDeath AS dea
JOIN covidinfo.dbo.CovidVac AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null