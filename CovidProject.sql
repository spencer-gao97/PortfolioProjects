select * 
FROM CovidDeaths
order by [location], [date]


select * 
FROM CovidVaccinations
order by [location], [date]

select location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY [location], [date]

-- Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY [location], [date]

select location, date, Population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY [location], [date]

-- Looking at countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM coviddeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per population

SELECT Location, MAX(cast(Total_deaths as INT)) as TotalDeathCount 
FROM coviddeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Total DeathCount by Continent

SELECT continent, MAX(cast(Total_deaths as INT)) as TotalDeathCount 
FROM coviddeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths 
where continent is not null
--GROUP BY date
order by 1, 2

SELECT * 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date

-- Looking at total population vs. vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN CovidVaccinations vac
on dea.iso_code = vac.iso_code 
and dea.date = vac.date
Where dea.continent is not null
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
order by 2, 3 



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER by dea.location, dea.date) as Rollingpeoplevaccinated
FROM coviddeaths dea
Join covidvaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
order by 2, 3

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER by dea.location, dea.date) as Rollingpeoplevaccinated
FROM coviddeaths dea
Join covidvaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
)
Select continent, location, date, population, CAST(new_vaccinations as INT) AS NewVaccinations, rollingpeoplevaccinated, 
(Rollingpeoplevaccinated/Population*100) AS PercentofPopulationVaccinated
FROM PopvsVac
Group by continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated 

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER by dea.location, dea.date) as Rollingpeoplevaccinated
FROM coviddeaths dea
Join covidvaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

Select continent, location, date, population, new_vaccinations, rollingpeoplevaccinated, 
(Rollingpeoplevaccinated/Population*100) AS PercentofPopulationVaccinated
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN CovidVaccinations vac
on dea.iso_code = vac.iso_code 
and dea.date = vac.date
Where dea.continent is not null
GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
