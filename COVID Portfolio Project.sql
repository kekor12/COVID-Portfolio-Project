
Select * 
From [Portfolio Project]..['COVID Deaths$']
where continent is not null 
order by 3,4


--Select * 
--From [Portfolio Project]..['COVID Vaccination$']
--where continent is not null 
--order by 3,4

--Select the data you will be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..['COVID Deaths$']
where continent is not null 
order by 1,2

--Looking at the Total Cases vs Total Deaths  
--Shows likelihood of dying if you contract COVID in the United States

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..['COVID Deaths$']
where continent is not null 
where location like '%states%'
order by 1,2


--Looking at the Total Cases vs Population
--Shows what percentage of population got COVID

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..['COVID Deaths$']
where continent is not null 
where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population 

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..['COVID Deaths$']
where continent is not null 
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc




--Showing Countries with the Highest Death Count Per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['COVID Deaths$']
where continent is not null 
--where location like '%states%'
Group by location
order by TotalDeathCount desc



--BREAKING THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..['COVID Deaths$']
where continent is not null 
--where location like '%states%'
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..['COVID Deaths$']
where continent is not null 
--where location like '%states%'
Group by date
order by 1,2

--Total Global cases vs death

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..['COVID Deaths$']
where continent is not null 
--where location like '%states%'
--Group by date
order by 1,2


--Looking at Total Population VS Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated 
From [Portfolio Project]..['COVID Deaths$'] dea
Join [Portfolio Project]..['COVID Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Populatuon, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated 
From [Portfolio Project]..['COVID Deaths$'] dea
Join [Portfolio Project]..['COVID Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime
Population numeric,
RollingPeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated 
From [Portfolio Project]..['COVID Deaths$'] dea
Join [Portfolio Project]..['COVID Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Creating View to store for later visualizations 

Create View PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER ( Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated 
From [Portfolio Project]..['COVID Deaths$'] dea
Join [Portfolio Project]..['COVID Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated