SELECT *
FROM PortfolioProject..CovidVaccinations

--exec sp_rename 'Sheet1$', 'CovidVaccinations'

SELECT *
FROM PortfolioProject..Coviddeaths
--WHERE Continent is not null
order by 3, 4

SELECT *
FROM PortfolioProject..Covidvaccinations
order by 3, 4

---select data i am going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


---Looking at Total Cases vs Total Deaths
---Shows the likelyhood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%kenya%'
ORDER BY 1, 2

---Looking at Total Cases vs Population
---Shows what percentage of population got covid 

SELECT Location, date, total_cases,population, (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location like '%kenya%'
ORDER BY 1, 2

---Looking at countries with the highest infection rates

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%kenya%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


---Countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
--WHERE Location like '%kenya%'
GROUP BY Location
ORDER BY TotalDeathCount DESC

---Highest death count by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
--WHERE Location like '%kenya%'
GROUP BY continent
ORDER BY TotalDeathCount DESC

---Global covid numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as TotalDeathCount, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
--WHERE Location like '%kenya%'
--GROUP BY date
ORDER BY 1, 2

---Total population vs total vaccination

SELECT cvd.continent, cvd.location, cvd.population, cvd.date, cvv.new_vaccinations
		, SUM(cast(cvv.new_vaccinations as float)) OVER (partition by cvd.location order by cvd.location, cvd.date ROWS UNBOUNDED PRECEDING)
		as RollingPeopleVaccinated--gives me an error if command ROWS UNBOUNDED PRECEDING is not included
FROM PortfolioProject..CovidDeaths as cvd 
JOIN PortfolioProject..Covidvaccinations as cvv
	ON cvd.location = cvv.location
	AND cvd.date = cvv.date
WHERE cvd.continent is not null
ORDER BY 2, 3


---Use CTE

With PopvsVac (continent, location, population, date, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT cvd.continent, cvd.location, cvd.population, cvd.date, cvv.new_vaccinations
		, SUM(cast(cvv.new_vaccinations as float)) OVER (partition by cvd.location order by cvd.location, cvd.date ROWS UNBOUNDED PRECEDING)
		as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as cvd 
JOIN PortfolioProject..Covidvaccinations as cvv
	ON cvd.location = cvv.location
	AND cvd.date = cvv.date
WHERE cvd.continent is not null
--ORDER BY 2, 3

)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


---Temp Table

DROP TABLE if exists #PercentPoulationVaccinated
CREATE TABLE #PercentPoulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPoulationVaccinated
SELECT cvd.continent, cvd.location, cvd.population, cvd.date, cvv.new_vaccinations
		, SUM(cast(cvv.new_vaccinations as float)) OVER (partition by cvd.location order by cvd.location, cvd.date ROWS UNBOUNDED PRECEDING)
		as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as cvd 
JOIN PortfolioProject..Covidvaccinations as cvv
	ON cvd.location = cvv.location
	AND cvd.date = cvv.date
--WHERE cvd.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPoulationVaccinated


---Creating views to store for later visualisations

CREATE VIEW PercentPoulationVaccinated as
SELECT cvd.continent, cvd.location, cvd.population, cvd.date, cvv.new_vaccinations
		, SUM(cast(cvv.new_vaccinations as float)) OVER (partition by cvd.location order by cvd.location, cvd.date ROWS UNBOUNDED PRECEDING)
		as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as cvd 
JOIN PortfolioProject..Covidvaccinations as cvv
	ON cvd.location = cvv.location
	AND cvd.date = cvv.date
--WHERE cvd.continent is not null
--ORDER BY 2, 3

CREATE VIEW HighestInfectionRates as
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%kenya%'
GROUP BY Location, population
--ORDER BY PercentPopulationInfected DESC

CREATE VIEW HighestDeathCountsPop as
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
--WHERE Location like '%kenya%'
GROUP BY Location
--ORDER BY TotalDeathCount DESC

CREATE VIEW HighestDeathCountCont as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent is not null
--WHERE Location like '%kenya%'
GROUP BY continent
--ORDER BY TotalDeathCount DESC

