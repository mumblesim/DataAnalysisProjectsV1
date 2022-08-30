-- View #1

SELECT SUM(cast(new_cases as bigint)) as totalCases, SUM(cast(new_deaths as bigint)) as totalDeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathsPercentage
FROM DAProjct..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;

-- View #2

SELECT continent, MAX(cast( total_deaths as bigint)) as TotalDeathCount 
FROM DAProjct..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc 

-- View #3

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfected
FROM DAProjct..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY PopulationInfected desc

-- View #4

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfected
FROM DAProjct..CovidDeaths$
WHERE continent is not null
GROUP BY location, population, date
ORDER BY PopulationInfected desc
