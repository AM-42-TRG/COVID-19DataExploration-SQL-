-- Tutorial URL: https://youtu.be/qfyynHBFOsM

/*
Portfolio Project by Alex Freberg:
SQL Data Exploration
*/

select *
from PortfolioProject.dbo.CovidDeaths

select *
from PortfolioProject.dbo.CovidVaccinations

--Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like 'Namibia'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1, 2

-- Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by TotalDeathCount desc


-- Showing the continents with the highest death count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc







-- GLOBAL NUMBERS
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
-- where location like '%states%'
where continent is not null
group by date
order by 1, 2


-- GLOBAL NUMBERS2
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
-- where location like '%states%'
where continent is not null
--group by date
order by 1, 2

-- Video at 50:00
-- https://www.youtube.com/watch?v=qfyynHBFOsM

-- Joining the two tables (Join = Inner Join)

SELECT *
FROM PortfolioProject..CovidDeaths dea -- 'dea' is the alias
Join PortfolioProject..CovidVaccinations vac -- 'vac' is the alias
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Video at 56:11

-- Video at 1:01:23

-- Doing a rolling count
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using a CTE
WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- Using a temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPercentVaccinated
FROM #PercentPopulationVaccinated




-- Creating a view to store data for later visualisations
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

-- Viewing the view
SELECT *
FROM PercentPopulationVaccinated

-- https://www.sqlservertutorial.net/sql-server-views/
-- "A view is a named query stored in the database catalog that allows you to refer to it later."