Use DAProjct
--Looking at Covid Deaths

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM DAProjct..CovidDeaths$
ORDER BY 1,2;


--Likelyhood of death from covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM DAProjct..CovidDeaths$
WHERE location = 'india'
ORDER BY 1,2;


--Infection rate by population
SELECT location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
FROM DAProjct..CovidDeaths$
WHERE location like 'india'
ORDER BY 1,2;

--Infection rate by population: Overall
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfected
FROM DAProjct..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY PopulationInfected desc


--Death rate: Overall
SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount 
FROM DAProjct..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--Death rate by population: Overall
SELECT location, MAX(cast(total_deaths as bigint)) as TotalDeathCount, MAX(total_deaths/population)*100 as PopulationDeaths
FROM DAProjct..CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY PopulationDeaths desc


--Deaths by continent
SELECT continent, MAX(cast( total_deaths as bigint)) as TotalDeathCount 
FROM DAProjct..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers

SELECT SUM(cast(new_cases as bigint)) as totalCases, SUM(cast(new_deaths as bigint)) as totalDeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathsPercentage
FROM DAProjct..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;


--Looking at Covid Vaccinations

SELECT *
FROM DAProjct..CovidDeaths$ cdea
JOIN DAProjct..CovidVaccinations$ cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date


--Total vaccinations: Overview

SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cast(cvac.new_vaccinations as bigint)
FROM DAProjct..CovidDeaths$ cdea
JOIN DAProjct..CovidVaccinations$ cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
WHERE cdea.continent is not null AND cvac.new_vaccinations is not null
ORDER BY cast(cvac.new_vaccinations as bigint) desc


--Total vaccinations over population, rolling totals

SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cast(cvac.new_vaccinations as bigint) AS newVaccinations, SUM(cast(cvac.new_vaccinations as bigint)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS RollingVaccinated
FROM DAProjct..CovidDeaths$ cdea
JOIN DAProjct..CovidVaccinations$ cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
WHERE cdea.continent is not null --AND cvac.new_vaccinations is not null
ORDER BY 2, 3 --cast(cvac.new_vaccinations as bigint) desc


-- Using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
as
(
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, SUM(cast(cvac.new_vaccinations as bigint)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS RollingVaccinated
FROM DAProjct..CovidDeaths$ cdea
JOIN DAProjct..CovidVaccinations$ cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
WHERE cdea.continent is not null --AND cvac.new_vaccinations is not null
)
SELECT *, (RollingVaccinated/population)*100
from PopvsVac
--WHERE cdea.continent is not null
WHERE location = 'india' -- and (date between '2021-06-01' and '2021-06-30') -- vaccines made free on 2021-06-21
ORDER BY date


-- Using Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(50),
	location nvarchar(50),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, SUM(cast(cvac.new_vaccinations as bigint)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS RollingVaccinated
FROM DAProjct..CovidDeaths$ cdea
JOIN DAProjct..CovidVaccinations$ cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
WHERE cdea.continent is not null
SELECT *, (RollingVaccinated/population)*100 as RollingPercentVaccinated
from #PercentPopulationVaccinated
where New_vaccinations is not null 
ORDER BY Continent, location


-- Creating View for visualization

GO
CREATE VIEW PercentPopulationVaccinated
as
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, SUM(cast(cvac.new_vaccinations as bigint)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS RollingVaccinatedNon
  FROM DAProjct..CovidDeaths$ cdea
JOIN DAProjct..CovidVaccinations$ cvac
	ON cdea.location = cvac.location
	AND cdea.date = cvac.date
	where cdea.continent is not null

--Looking at the view
SELECT * from PercentPopulationVaccinated
