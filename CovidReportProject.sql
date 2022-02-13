--Check if data is loaded correcly
--SELECT *
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 3,4
--SELECT *
--FROM PortfolioProject..CovidVaccination$
--ORDER BY 3,4




SELECT Location, date,population, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage, ROUND((total_cases/population)*100,4) AS 'Population Infected Percentage'
FROM PortfolioProject..CovidDeaths$
--WHERE Location = '' --insert country name inside the '' for filter the data
ORDER BY 1,2;
--Looking at total cases vs total deaths worldwide from 02/2020 to 02/2022 
--Death Percentage shows the likelihood of death if you infected by Covid-19 worldwide
--'Population Infected Percentage' shows the number of cases verse the population


--Looking at countries with highest infection reate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE Location = '' --insert country name inside the '' for filter the data
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC
;


--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as bigint)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths$
--WHERE Location = '' --insert country name inside the '' for filter the data
WHERE continent IS NOT null
GROUP BY Location
ORDER BY TotalDeathsCount DESC
;
-- Instead of by Countries, Filter by continent
SELECT continent, MAX(cast(total_deaths as bigint)) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths$
--WHERE Location = '' --insert country name inside the '' for filter the data
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC
;


-- WORLDWIDE VIEW 
SELECT date, SUM(new_cases) as 'Number of Cases', SUM(cast(new_deaths as bigint)) as TotalDeaths, ROUND((SUM(cast(new_deaths as bigint))/SUM(new_cases))*100,4) AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2;

--Looking at Total Population vs Vaccination Records
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) OVER (Partition BY d.location ORDER BY d.location, d.date) as TotalVaccinatedToDate
FROM PortfolioProject..CovidDeaths$ d
INNER JOIN PortfolioProject..CovidVaccinations$ v
ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null -- AND d.location = '' Insert location inside '' to filter to specific location
order by 2,3
;

-- Creating a TEMP TABLE to compare Population vs Vaccinations

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccinatedToDate numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) OVER (Partition BY d.location ORDER BY d.location, d.date) as TotalVaccinatedToDate
FROM PortfolioProject..CovidDeaths$ d
INNER JOIN PortfolioProject..CovidVaccinations$ v
ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null -- AND d.location = '' Insert location inside '' to filter to specific location
order by 2,3
;
SELECT *, ROUND((TotalVaccinatedToDate/Population)*100,4 ) AS PercentVaccinated
From #PercentPopulationVaccinated
;


-- CREATE VIEW to store date for later visualizations using Tableu

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as bigint)) OVER (Partition BY d.location ORDER BY d.location, d.date) as TotalVaccinatedToDate
FROM PortfolioProject..CovidDeaths$ d
INNER JOIN PortfolioProject..CovidVaccinations$ v
ON d.location = v.location AND d.date = v.date
WHERE d.continent is not null 
;
