Select *
	From CovidProject..CovidDeaths
	where continent is not null
	Order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population
	From CovidProject..CovidDeaths
	where continent is null
	Order by location, date;

--% chance of dying if contracted covid in the US
Select Location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) as DeathPercentage
	From CovidProject..CovidDeaths
	Where location like '%states%'
	Order by location, date;

--% of US population that has covid
Select Location, date, total_cases, population, Round((total_cases/population)*100, 4) as CovidPercentage
	From CovidProject..CovidDeaths
	Where location like '%states%'
	Order by location, date;

--continents with highest population infection %
Select Location, population, MAX(total_cases) as HighestInfectionCount, Round(Max((total_cases/population))*100, 4) as PercentPopulationInfected
	From CovidProject..CovidDeaths
	where continent is null
	Group by location, population
	Order by PercentPopulationInfected desc

--countries with highest death count
Select Location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, Round((MAX(cast(total_deaths as int))/population)*100, 5) as PercentagePopulationDead
	From CovidProject..CovidDeaths
	where continent is not null
	Group by location, population
	Order by TotalDeathCount desc

--Continents with highest death count
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
	From CovidProject..CovidDeaths
	where continent is null
	Group by location
	Order by TotalDeathCount desc



Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Round((SUM(cast(new_deaths as int)))/SUM(new_cases)*100,2) as DeathPercentage
	From CovidProject..CovidDeaths
	Where continent is not null
	Order by 1,2;

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from covidproject..coviddeaths dea
	join covidproject..covidvaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
	Order by 2,3;


With PopVsVac (Continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
	as(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from covidproject..coviddeaths dea
	join covidproject..covidvaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
	)
	Select *, (rollingpeoplevaccinated/population)*100 as PercentVaccinated
	from popvsvac;


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255), 
	location nvarchar(255), 
	date datetime, population numeric, 
	New_Vaccinations numeric, 
	RollingPeopleVaccinated numeric
	)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from covidproject..coviddeaths dea
	join covidproject..covidvaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
Select *, (rollingpeoplevaccinated/population)*100 as PercentVaccinated
	from #PercentPopulationVaccinated;

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from covidproject..coviddeaths dea
	join covidproject..covidvaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null

Select *
From PercentPopulationVaccinated