Select *
From [Data Analyst Portfolio Project].dbo.CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From [Data Analyst Portfolio Project].dbo.CovidVaccinations$
--order by 3,4

--Selecting Data that we will use:
Select Location, date, total_cases, new_cases, total_deaths, population
From [Data Analyst Portfolio Project].dbo.CovidDeaths$
where continent is not null
order by 1,2

--Looking at Total Cases vs. Total Deaths:
--Shows likelihood of dying if you contact covid in your ocuntry
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From [Data Analyst Portfolio Project].dbo.CovidDeaths$
Where location like '%states%'
where continent is not null
order by 1,2

--looking at the total cases vs. the population
--Shows what percentage of population got Covid
Select Location, date, Population, total_cases,  (Total_cases/Population)*100 as PercentPopulationInfected
From [Data Analyst Portfolio Project].dbo.CovidDeaths$
Where location like '%states%'
where continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/Population))*100 as PercentPopulationInfected
From [Data Analyst Portfolio Project].dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


--Showing countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Data Analyst Portfolio Project].dbo.CovidDeaths$
--Where location like '%states%'
--have to add 'where continet is not null' - data input error (inputed in country column is continent when continent column is null )ex:asia) 
where continent is not null
Group by Location, Population
order by TotalDeathCount desc

--Breaking things down by continent



--Showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Data Analyst Portfolio Project].dbo.CovidDeaths$
--Where location like '%states%'
--have to add 'where continet is not null' - data input error (inputed in country column is continent when continent column is null )ex:asia) 
where continent is not null
Group by Continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Data Analyst Portfolio Project].dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location)
From [Data Analyst Portfolio Project].dbo.CovidDeaths$ dea
Join [Data Analyst Portfolio Project].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Data Analyst Portfolio Project].dbo.CovidDeaths$ dea
Join [Data Analyst Portfolio Project].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_VAccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Data Analyst Portfolio Project].dbo.CovidDeaths$ dea
Join [Data Analyst Portfolio Project].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVAc


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Data Analyst Portfolio Project].dbo.CovidDeaths$ dea
Join [Data Analyst Portfolio Project].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Data Analyst Portfolio Project].dbo.CovidDeaths$ dea
Join [Data Analyst Portfolio Project].dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated