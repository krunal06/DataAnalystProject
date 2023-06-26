select * from PortfolioProject..CovidDeaths order by 3,4

select * from PortfolioProject..CovidVaccination order by 3,4

select location, date, total_cases, new_cases,total_deaths, population from PortfolioProject..CovidDeaths order by 1,2

select location, date, total_cases,total_deaths, (total_deaths/ total_cases)*100 as deathPercentage 
from PortfolioProject..CovidDeaths
where location like '%India%' 
order by 1,2

select location, date, total_cases,population,(total_cases/population)*100 as covidPercentage 
from PortfolioProject..CovidDeaths
order by 1,2

-- countries with highest infection count
select location, population, max(total_cases) as highestInfectionCount, max((total_cases/population))*100 as percentPopulationInfected 
from PortfolioProject..CovidDeaths
group by population, location
order by percentPopulationInfected desc


--continent with highest death count per population 
select location, Max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeaths where continent is NULL
group by location
order by totalDeathCount desc

--(different number output) continent with highest death count per population 
select continent, Max(cast(total_deaths as int)) as totalDeathCount
from PortfolioProject..CovidDeaths where continent is not NULL
group by continent
order by totalDeathCount desc


--global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, round(sum(cast(new_deaths as int))/sum(new_cases) * 100,3) as deathPercentage--,total_deaths, (total_deaths/ total_cases)*100 as deathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--total population vs vaccination
select dea.continent,dea.location, dea.date, population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
 ,(RollingVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac on dea.location = vac.location 
     and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE

with popVsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
as
(
select dea.continent,dea.location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
 ,(RollingVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac on dea.location = vac.location 
     and dea.date = vac.date
where dea.continent is not null
order by 2,3
)

select *, (RollingVaccinated / population) * 100 from popVsVac


--Temp Table

Drop table if exists #PercentPopVac
create table #PercentPopVac(Contintent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric)

Insert into #PercentPopVac
select dea.continent,dea.location, dea.date, population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
 ,(RollingVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac on dea.location = vac.location 
     and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingVaccinated / population) * 100 from #PercentPopVac

--create view

create view PercentpopVaccinated as
select dea.continent,dea.location, dea.date, population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingVaccinated
 ,(RollingVaccinated/population) *100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac on dea.location = vac.location 
     and dea.date = vac.date
where dea.continent is not null
order by 2,3

select * from PercentpopVaccinated
