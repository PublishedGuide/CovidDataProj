SELECT * 
FROM amitob1.`covid-datadeaths`
WHERE continent is not null
ORDER BY 3, 4;

#-Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM amitob1.`covid-datadeaths`
ORDER BY 1, 2;

#-Looking at Total Cases vs Total Deaths
#-Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM amitob1.`covid-datadeaths`
WHERE location like '%states%'
ORDER BY 1, 2;

#-Looking at the total cases vs population
#-Shows what percentage of the population got Covid
SELECT location, date, total_cases, population, (total_deaths/population)*100 as ContractPercentage
FROM amitob1.`covid-datadeaths`
#WHERE location like '%states%'
ORDER BY 1, 2;

#Looking at countries with highest infection rate compared to population
SELECT location, date, MAX(total_cases), population, MAX((total_deaths/population))*100 as HighestPopInfected
FROM amitob1.`covid-datadeaths`
Group by location, population
ORDER BY HighestPopInfected desc;

#-Countries with the highest death count per population
SELECT location, MAX(CONVERT(INT,total_deaths)) as TotalDeathCount
FROM amitob1.`covid-datadeaths`
WHERE continent is null
Group by location
ORDER BY TotalDeathCount desc;
-- correct way to go above 

# Showing the continents with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCountC 
FROM amitob1.`covid-datadeaths`
WHERE continent is not null
Group by location
ORDER BY TotalDeathCount desc;
-- for continuity we use the info above
-- add continent to all the queries above to get the drill down affect (help narrow down search to specific areas)

#- Lets get ready to visualize through global numbers
SELECT date, SUM(new_cases) -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM amitob1.`covid-datadeaths`
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM amitob1.`covid-datadeaths`
WHERE continent is not null
ORDER BY 1,2;

SELECT date, SUM(new_cases) as total_cases, SUM(convert(int,new_deaths)) as total_death, SUM(CONVERT(int, new_deaths))/SUM(new_cases)*100 as death percentage 
FROM amitob1.`covid-datadeaths`
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- next table for covid vaccination data, pulled from the same overall table and modified in excel to have only the most relevant columns
#- Looking at Total Population vs Vaccinations
SELECT *
FROM amitob1.`covid-datadeaths`  dea 
JOIN amitob1.`covid-datavaccs`  vac
	ON dea.location = vac.location
    AND dea.date = vac.date
ORDER BY 2,3;

-- looking at how many vaccination have been done in relation to the population accoss different locations at different days of the time span
#- Here we can find out when some new vaccionations have been heen happening and how they have progressed over time
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations)
FROM
    amitob1.`covid-datadeaths` dea
        JOIN
    amitob1.`covid-datavaccs` vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY 1 , 2 , 3;

#Getting new vaccinations per day as a rolling count of how the vaccination count aggegates
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
    amitob1.`covid-datadeaths` dea
        JOIN
    amitob1.`covid-datavaccs` vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY 1 , 2 , 3;

#Looking as total population vs population 
#Using CTE
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
FROM
    amitob1.`covid-datadeaths` dea
        JOIN
    amitob1.`covid-datavaccs` vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

#Using Temptable
-- DROP TABLE if exists PercentPopulationVaccinated -- (optional)
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated
)

INSERT INTO
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
    amitob1.`covid-datadeaths` dea
        JOIN
    amitob1.`covid-datavaccs` vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
    
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated;

#- Creating a 'View' to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
    amitob1.`covid-datadeaths` dea
        JOIN
    amitob1.`covid-datavaccs` vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
    
SELECT *
FROM PercentPopulationVaccinated;
