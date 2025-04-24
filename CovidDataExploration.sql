
select * 
from PortofolioProject..CovidDeaths --we can use this or ".dbo."
where continent is not null
order by 3,4

--select * 
--from PortofolioProject..CovidVaccinations --we can use this or ".dbo."
--order by 3,4

-- select data from Covid Deaths DB
select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths
-- Calculate death percentage
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as death_percentage
from PortofolioProject..CovidDeaths
where location like 'Indonesia' and continent is not null
order by 1,2


-- Total Cases vs Population
-- calculate percentage of population that got infected
select location, date, total_cases, population, (total_cases/population)*100 as infection_percentage
from PortofolioProject..CovidDeaths
--where location like 'Indonesia' and continent is not null
order by 1,2


-- List of countries with infection percentage from high to low
select 
	location, 
	population, 
	MAX(total_cases) as highest_infection_count, 
	MAX((total_cases/population))*100 as infection_percentage
from PortofolioProject..CovidDeaths
--where location like 'Indonesia'
where continent is not null and continent is not null
group by location, population
order by 4 desc


-- List of countries with total death from high to low
select
	location,
	population,
	MAX(cast(total_deaths as int)) as total_death_count
from PortofolioProject..CovidDeaths
where continent is not null and continent is not null
group by location, population
order by 3 desc


-- List of continent with total death from high to low (latest data)
select 
	continent,
	SUM(cast(total_deaths as int)) as total_deaths
from PortofolioProject..CovidDeaths
where date = '2021-04-30 00:00:00.000' and continent is not null 
group by continent
order by 2 desc


-- Global death count
select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortofolioProject..CovidDeaths
--where location like 'Indonesia'
where continent is not null
--group by date
order by 1,2


-- Join 2 tables & looking at total population vs vaccinations
select 
	dea.continent, 
	dea.location, 
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as cumulative_vaccinations
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2



-- using CTE
With PopvsVac (Continent, Location, date, population, new_vaccinations, cumulative_vaccinations)
as
	(
	select 
		dea.continent, 
		dea.location, 
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as cumulative_vaccinations
	from PortofolioProject..CovidDeaths dea
	join PortofolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 1,2
	)
select *, (cumulative_vaccinations/population)*100 as pop_vs_vac_percentage
from PopvsVac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated -- use this if we want to make alterations
Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population int,
	New_vaccination int,
	Cumulative_Vaccinations int,
)

Insert into #PercentPopulationVaccinated
select 
	dea.continent, 
	dea.location, 
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as cumulative_vaccinations
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2

select *, (cumulative_vaccinations/population)*100 as pop_vs_vac_percentage
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations.
DROP VIEW IF EXISTS PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
select 
	dea.continent, 
	dea.location, 
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as cumulative_vaccinations
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2


select *
from PercentPopulationVaccinated