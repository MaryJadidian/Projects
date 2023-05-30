

SELECT * FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Loking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM ProjectCovid..CovidDeaths
WHERE location LIKE '%Canada%'
AND continent IS NOT NULL
ORDER BY 1, 2

--Loking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM ProjectCovid..CovidDeaths
WHERE location LIKE '%Canada%'
AND continent IS NOT NULL
ORDER BY 1, 2

--Looking at Countries with hightest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM ProjectCovid..CovidDeaths
--WHERE location LIKE '%Canada%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM ProjectCovid..CovidDeaths
--WHERE location LIKE '%Canada%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC

--Showing continents with the highest death count per population 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM ProjectCovid..CovidDeaths
--WHERE location LIKE '%Canada%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--GLOBAL NUMBERS 

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as DeathPercentage
FROM ProjectCovid..CovidDeaths
--WHERE location LIKE '%Canada%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as DeathPercentage
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Looking at Total Population vs Vaccination

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(int, Vac.new_vaccinations))) OVER (PARTITION BY Dea.location ORDER BY Dea.Location, Dea.Date)
AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
FROM ProjectCovid..CovidDeaths AS Dea
JOIN ProjectCovid..CovidVaccinations AS Vac
     ON Dea.location=Vac.location
	 AND Dea.date=Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

--USE CTE 

WITH PopvsVac(continent, locavion, population, date, new_vaccination, RollingPeople)
AS (
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.Location, Dea.Date)
AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM ProjectCovid..CovidDeaths AS Dea
JOIN ProjectCovid..CovidVaccinations AS Vac
     ON Dea.location=Vac.location
	 AND Dea.date=Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3)
SELECT * , (RollingPeopleVaccinated/population)*100 FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.Location, Dea.Date)
AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM ProjectCovid..CovidDeaths AS Dea
JOIN ProjectCovid..CovidVaccinations AS Vac
     ON Dea.location=Vac.location
	 AND Dea.date=Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3)

SELECT * , (RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW #PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.Location, Dea.Date)
AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM ProjectCovid..CovidDeaths AS Dea
JOIN ProjectCovid..CovidVaccinations AS Vac
     ON Dea.location=Vac.location
	 AND Dea.date=Vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3)

SELECT * FROM PercentPopulationVaccinated

