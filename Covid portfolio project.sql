Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select data that we are going to be using
Select continent, date, total_cases, new_cases, total_deaths, population  
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Looking at Total Cases vs Total Deaths
--Shows what percentage of continent got Covid
Select continent, date, total_cases, Population, (total_cases/population) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%South Africa%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
 Select continent, Population, MAX(total_cases) as HighestInfectionCount, MAX ((total_cases/population)) *100 as
 PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where location like '%South Africa%'
Group by continent, population
order by PercentPopulationInfected desc

--LETS BREAK DOWN DATA BY CONTINENT


-- Showing Countries with the Highest Death Count Per Population



Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where location like '%South Africa%'
Group by location
order by TotalDeathCount desc


--Showing continents with the highest death count per population

 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%South Africa%'
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
 Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%South Africa%'
where continent is not null
Group by date
order by 1,2


--CTE
With PopvsVac(Continent,location, Date, Population, new_vaccinations, RollingPeopleVaccinated)

as
(
-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac

On  dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP Table
DROP Table if exists ##PercentPopulationVaccinated
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
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac

On  dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
On  dea.location = vac.location
and dea.date = vac.date
 where dea.continent is not null
