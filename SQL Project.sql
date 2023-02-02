/*
First SQL project - Covid Data Exploration 
Skills used: Basic functions, Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


--Looking at the table
Select *
From DataBaseProjects.dbo.CovidDeaths$
where continent is not null
order by 3,4


--Selecting columns that will be used further
Select location, date, total_cases, new_cases, total_deaths, population
From DataBaseProjects.dbo.CovidDeaths$
where continent is not null
order by 1,2


-- Looking at the Total Cases vs Total Deaths
-- Looking at the percentage of death in a specific country (ex, in the United States)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From DataBaseProjects.dbo.CovidDeaths$
where location like '%states%' and continent is not null
order by 5 Desc


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From DataBaseProjects.dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2


--Looking at the countries with the highest infection rates compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as CasesPercentage
From DataBaseProjects.dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
group by location, population
order by 4 desc


--looking at the countries wih the highest death count per population
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From DataBaseProjects.dbo.CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by HighestDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT

-- Continents with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From DataBaseProjects.dbo.CovidDeaths$
where continent is null
group by location
order by HighestDeathCount desc


-- Global numbers
Select SUM(new_cases) as total_NewCases , SUM(CAST(new_deaths as int))as total_NewDeaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as NewDeathPercentage
From DataBaseProjects.dbo.CovidDeaths$
where continent is not null 
order by 2


--Joining two tables
select *
from DataBaseProjects.dbo.CovidDeaths$ dea
join DataBaseProjects.dbo.CovidVaccinations$ vac 
on dea.location = vac.location and dea.date = vac.date


-- Rolling vaccination
Select dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location,
dea.date) as RollingVaccination
from DataBaseProjects.dbo.CovidDeaths$ dea
join DataBaseProjects.dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Looking at the Total Population vs Total Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location,
dea.date) as RollingVaccination
from DataBaseProjects.dbo.CovidDeaths$ dea
join DataBaseProjects.dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE
with POPvsVAC (continent, location, date, population, new_vaccinations
, RollingVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location,
dea.date) as RollingVaccination
--, (RollingVaccination/dea.population)*100
from DataBaseProjects.dbo.CovidDeaths$ dea
join DataBaseProjects.dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select*, (RollingVaccination/population)*100 as RollingVacPercentage
from POPvsVAC


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
datw datetime,
population numeric,
new_vaccinations numeric,
RollingVaccination numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location,
dea.date) as RollingVaccination
--, (RollingVaccination/dea.population)*100
from DataBaseProjects.dbo.CovidDeaths$ dea
join DataBaseProjects.dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*, (RollingVaccination/population)*100 as RollingVacPercentage
from #PercentPopulationVaccinated


--creating view to store data for later visualizations
create view PercentPopulationVaccinated
as
Select dea.continent, dea.location, dea.date, dea.population
, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location,
dea.date) as RollingVaccination
--, (RollingVaccination/dea.population)*100
from DataBaseProjects.dbo.CovidDeaths$ dea
join DataBaseProjects.dbo.CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

exec sp_refreshview [PercentPopulationVaccinated]
go
select * from [PercentPopulationVaccinated]
go





