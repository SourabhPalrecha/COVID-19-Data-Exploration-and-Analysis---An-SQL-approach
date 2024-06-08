Select *
from Portfolio_project..covid_deaths
where continent is NOT null

Select location, date, total_cases, total_deaths, new_cases, population
from Portfolio_project..covid_deaths

-- Look at Total Cases Vs Total Death and analyze and find the percentage of deaths occurred.
-- Check for UnitedStates

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio_project..covid_deaths
where location like '%states%'
order by 1,2

-- Look at Total Cases Vs Population and analyse and find the percentage of people who contracted COVID

Select location, date, total_cases, population, (total_cases/population)*100 as Percent_Population_Infected
from Portfolio_project..covid_deaths
where location like '%states%'
order by 1,2

-- Look at Countries with highest infection rate comapred to population size
-- also analyze the most infected Continent

Select continent,location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as Percent_Population_Infected
from Portfolio_project..covid_deaths
group by continent, location, population
order by Percent_Population_Infected desc

-- Look at countrie with highest death count per population

Select location, max(cast(total_deaths as int)) as DeathCount 
from Portfolio_project..covid_deaths
where continent is NOT null
group by location
order by DeathCount desc

-- Look at continent with highest death count per population

Select continent, max(cast(total_deaths as int)) as DeathCount 
from Portfolio_project..covid_deaths
where continent is NOT null
group by continent
order by DeathCount desc

-- look at Global Numbers of cases and death across the globe

Select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolio_project..covid_deaths
where continent is not NULL
group by date
order by 1,2

-- look at Total number of new cases and death cases recorded globally

Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Portfolio_project..covid_deaths
where continent is not NULL
--order by 1,2

-- look at total Population Vs Vaccinations(Vaccinated Population) and give insights in form of percentage

	-- Use of CTE:- Common Table Expression(CTE) is a temporary result table of a query which exists only for that duration of the query.
	--				Thus, CTE "PopVsVac" created containing the calculated window function column i.e. RollingPeopleVaccinated
	--
	-- Use of Row_number:- indicates the row number given to each set of rows for one window partion. For better Visualization 
	--					   i.e. Row number begins from 1 as the "Location" changes
	--					   Usage: row_number() over (Partition by dea.Location order by dea.location, dea.date) as Row_Number

	

-- Use CTE
with PopVsVac(Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated, Row_Number)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated,
row_number() over (Partition by dea.Location order by dea.location, dea.date) as Row_Number
from Portfolio_project..covid_deaths dea
join Portfolio_project..covid_vaccinations vac
	on dea.location=vac.location and
	dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3
)
select Location, max(Population) as Population, max(RollingPeopleVaccinated/Population*100) as PercentVaccinated
from PopVsVac
group by Location
order by Location

-- Use of Temp Table ------------------------------------------------------------------------------------------------------
Drop table if exists #Percent_Population_Vaccinated
create table #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
Row_Number numeric
)

insert into #Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated,
row_number() over (Partition by dea.Location order by dea.location, dea.date) as Row_Number
from Portfolio_project..covid_deaths dea
join Portfolio_project..covid_vaccinations vac
	on dea.location=vac.location and
	dea.date=vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3

select Location, max(Population) as Population, max(RollingPeopleVaccinated/Population*100) as PercentVaccinated
from #Percent_Population_Vaccinated
group by Location
order by Location


-- create a view for the above query output

Create View Percent_PopulationVaccinated as
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated,
	row_number() over (Partition by dea.Location order by dea.location, dea.date) as Row_Number
	from Portfolio_project..covid_deaths dea
	join Portfolio_project..covid_vaccinations vac
		on dea.location=vac.location and
		dea.date=vac.date
	where dea.continent is not null and vac.new_vaccinations is not null
	--order by 2,3

-- Query the view
select Location, max(Population) as Population, max(RollingPeopleVaccinated/Population*100) as PercentVaccinated
from Percent_PopulationVaccinated
group by Location
order by Location