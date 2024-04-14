--Total deaths vs Total cases
select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS DeathPercent
from PortfolioProject.dbo.CovidDeaths
where location like 'India'
order by 1,2

--Total cases vs Population
select location, date, total_cases, population, ROUND((total_cases/population)*100, 3) AS PopulationPercent
from PortfolioProject.dbo.CovidDeaths
where location like 'India'
order by 1,2


--Countries having high infection rate respected to population
select location,  population, max(total_cases) as TotalCases, ROUND(MAX(total_cases/population)*100, 3) AS PopulationPercent
from PortfolioProject.dbo.CovidDeaths
group by location, population
order by PopulationPercent desc

--Countries having high death rates respected to population
select location,  population, max(total_deaths) as TotalCases, ROUND(MAX(total_deaths/population)*100, 3) AS DeathPercent
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by population, location
order by DeathPercent desc

--Continents having high death rates
select continent, max(total_deaths) as TotalCases, ROUND(MAX(total_deaths/population)*100, 3) AS DeathPercent
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by continent

--Total population vs Vaccination
select dea.continent, dea.location, dea.date, population, new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Creating CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
As
(
select dea.continent, dea.location, dea.date, population, new_vaccinations, SUM(new_vaccinations) over
 (Partition By dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select * from PopvsVac

--Creating Temp Table for the PopVaccPercent
Drop table if exists #VaccPerc
Create Table #VaccPerc
( Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_Vaccinations float,
RollingPeopleVaccinated float
)

Insert into #VaccPerc
select dea.continent, dea.location, dea.date, population, new_vaccinations, SUM(new_vaccinations) over
 (Partition By dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, ROUND((RollingPeopleVaccinated/Population)*100, 3) As VaccPeoplePerc
from #VaccPerc

--Global Stats
select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, round((SUM(new_deaths)/SUM(new_cases))*100, 3) as DeathPerc
from PortfolioProject..CovidDeaths
where continent is not null
order by 2,3

-- Create View
create view VaccPer as
(
select dea.continent, dea.location, dea.date, population, new_vaccinations, SUM(new_vaccinations) over
 (Partition By dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
