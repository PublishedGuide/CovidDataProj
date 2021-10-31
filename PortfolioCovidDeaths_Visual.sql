-- 1st Visual for Tableau (Tabulated information for Overall affect on the world)
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM `root-territory-324315.covid19temp.c19-deaths` 
WHERE continent is not null 
ORDER BY 1,2;

-- 2nd Visual for Tableau (Comparative scaled Record)
-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe, so we exclude the Union to maintain consistency
SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM `root-territory-324315.covid19temp.c19-deaths` 
WHERE continent is null and location not in ('World','European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc;

-- 3rd Visual for Tableau (Geographical Display)
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM `root-territory-324315.covid19temp.c19-deaths`
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- 4th Visual for Tableau (Time series)
SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM `root-territory-324315.covid19temp.c19-deaths`
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc;
-- Some other queries for visualization
#-- 5.
SELECT dea.continent, dea.location, dea.date, dea.population, MAX((vac.total_vaccinations)) as RollingPeopleVaccinated
FROM `root-territory-324315.covid19temp.c19-deaths` dea
JOIN `root-territory-324315.covid19temp.c19-vaccs` vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null 
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3;

-- 6.
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `root-territory-324315.covid19temp.c19-deaths`
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;

-- 7.
SELECT location, date, population, total_cases, total_deaths
FROM `root-territory-324315.covid19temp.c19-deaths`
WHERE continent is not null 
ORDER BY 1,2;

-- 8.
WITH PopvsVac (continent, location, date, pupulation, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM `root-territory-324315.covid19temp.c19-deaths` dea
JOIN `root-territory-324315.covid19temp.c19-vaccs` vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;
