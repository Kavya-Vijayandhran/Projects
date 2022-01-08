

SELECT * FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4;

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY 1,2;

--Looking at Total cases VS total deaths
-- Shows the likelihood of dying if you get Covid in your country
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%india%'
ORDER BY 1,2;

--Looking at total cases VS population
-- Shows what % of population got covid
Select location, date, total_cases, population,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY 1,2;


--Looking at countries with highest infection rate compared to populations
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
group by location, population
ORDER BY PercentPopulationInfected desc;

 
-- Showing countries with Highest Death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by location 
ORDER BY TotalDeathCount desc;

-- Viewing by continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is null
group by location
ORDER BY TotalDeathCount desc;

-- Showing continents with the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
group by continent
ORDER BY TotalDeathCount desc;

-- Global Numbers
select date, SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
group by date
order by 1,2 


--Joining both tables

Select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location AND dea.date=vac.date

-- Looking at total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location AND dea.date=vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations,RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location AND dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location AND dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select * 
from PercentPopulationVaccinated;