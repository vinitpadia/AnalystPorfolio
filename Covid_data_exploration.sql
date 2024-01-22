--Select *
--From [SQL Portfolio Project]..CovidDeaths
--order by 3,4

--Select location,date,total_cases,new_cases, total_deaths,population
--from [SQL Portfolio Project]..CovidDeaths
--order by 1,2

--Shows the liklihood of dying if contract covid in your country

SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CASE
        WHEN TRY_CAST(total_cases AS FLOAT) IS NOT NULL AND TRY_CAST(total_deaths AS FLOAT) IS NOT NULL AND TRY_CAST(total_cases AS FLOAT) <> 0
            THEN TRY_CAST(total_deaths AS FLOAT) * 100.0 / TRY_CAST(total_cases AS FLOAT)
        ELSE NULL
    END AS DeathPercentage
FROM
    [SQL Portfolio Project]..CovidDeaths
Where location = 'Canada'
ORDER BY
    1, 2;

--Shows the % of population that caught covid in the country
Select location, date, total_cases, population, (total_cases/population)*100 as CaseperPopulation
from [SQL Portfolio Project]..CovidDeaths
Where location = 'Canada'
order by 1,2

--Highest Infection rate compared to population according to the contries
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)*100) as InfectionRate
from [SQL Portfolio Project]..CovidDeaths
GROUP by population, location
order by InfectionRate DESC

--Contries with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeaths
from [SQL Portfolio Project]..CovidDeaths
Where continent is not null
GROUP by location, population
order by TotalDeaths DESC

--Continents with the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
from [SQL Portfolio Project]..CovidDeaths
Where continent is not null
GROUP by continent
order by TotalDeaths DESC

--GLOBAL Numbers

Select  SUM(new_cases) as NewCases, SUM(new_deaths) as NewDeaths , (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
from [SQL Portfolio Project]..CovidDeaths
Where continent is not null
--GROUP by date
order by 1,2

-- Joining the datasets
Select d.location,d.date,v.new_vaccinations
from [SQL Portfolio Project]..CovidDeaths d
Join [SQL Portfolio Project]..CovidVaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null and d.location = 'Canada'
order by 1,2

-- Joining the datasets
Select d.location,d.date,v.new_vaccinations,
SUM(CONVERT(float,v.new_vaccinations)) over (Partition by d.location
order by d.location,d.date) as RollingCountofVacc
from [SQL Portfolio Project]..CovidDeaths d
Join [SQL Portfolio Project]..CovidVaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null
order by RollingCountofVacc ASC

--USE CTE

With PopvsVac (continent,location, date, population,new_vaccinations,RollingCountofVacc)
as 
(
Select d.continent, d.location,d.date,d.population, v.new_vaccinations,
SUM(CONVERT(float,v.new_vaccinations)) over (Partition by d.location
order by d.location,d.date) as RollingCountofVacc
from [SQL Portfolio Project]..CovidDeaths d
Join [SQL Portfolio Project]..CovidVaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null
--order by 2,3
)
SELECT *, (RollingCountofVacc/population)*100 as perentagerolling
from PopvsVac
--order by perentagerolling DESC




--TEMP TABLE
Drop Table if exists PercentPopulationvacc
Create Table PercentPopulationvacc
(
continent nvarchar(200),
location nvarchar(200),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCountofVacc numeric
)
Insert into PercentPopulationvacc

Select d.continent, d.location,d.date,d.population, v.new_vaccinations,
SUM(CONVERT(float,v.new_vaccinations)) over (Partition by d.location
order by d.location,d.date) as RollingCountofVacc
from [SQL Portfolio Project]..CovidDeaths d
Join [SQL Portfolio Project]..CovidVaccination v
on d.location=v.location and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null
--order by 2,3
SELECT *, (RollingCountofVacc/population)*100 as perentagerolling
from PercentPopulationvacc


--Create View

Create View DeathchsbyContinent as
Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
from [SQL Portfolio Project]..CovidDeaths
Where continent is not null
GROUP by continent


