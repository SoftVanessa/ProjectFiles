select * 
from ProjectDatabase..CovidDeaths$
order by 3,4

--select * 
--from ProjectDatabase..CovidVaccinations$
--order by 3,4

select location, date, total_cases,new_cases,total_deaths, population	
from ProjectDatabase..CovidDeaths$
order by 1,2

-- total cases vs total deaths


select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathPercent
from ProjectDatabase..CovidDeaths$
where location like '%portu%'
order by 1,2

--looking at total case vs populatiion
--Percentagem de popul que apanhou covid

select location, date, total_cases,total_deaths, (total_deaths/population)*100 as PercentPoupoinf
from ProjectDatabase..CovidDeaths$
where location like '%portu%'
order by 1,2

-- looking at the countries with the highest infection rate

select location, population, max(total_cases) as highestInfectionCount, 
max((total_deaths/population))*100 as deathPercent
from ProjectDatabase..CovidDeaths$
group by location, population
order by highestInfectionCount desc

-- looking at highest death count per population

select location, max(cast(total_cases as int)) as totalDeathCount 
from ProjectDatabase..CovidDeaths$
group by location
order by totalDeathCount desc

-- Breaking down by continent

select continent, max(cast(total_cases as int)) as totalDeathCount 
from ProjectDatabase..CovidDeaths$
where continent is not null
group by continent
order by totalDeathCount desc

-- showing continent with highest death count

select continent, max(cast(total_cases as int)) as totalDeathCount 
from ProjectDatabase..CovidDeaths$
where continent is not null
group by continent
order by totalDeathCount desc

-- global numbers buy date 

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as globalDeathPercent
from ProjectDatabase..CovidDeaths$
where continent is not null
group by date
order by 1,2

-- global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as globalDeathPercent
from ProjectDatabase..CovidDeaths$
where continent is not null
order by 1,2

-- total amount of people in the world with vac 


with PopvsVac (continent, location, date, population, acumlated_vac, new_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as acumlated_vac
from ProjectDatabase..CovidDeaths$ dea
join ProjectDatabase..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  )
  select *, (acumlated_vac/population)*100
  from PopvsVac


  --temptable

  drop table if exists #PercentPopVac
  create table #PercentPopVac
  (
  continent nvarchar(255),
  location nvarchar (255),
  Date datetime,
  Population numeric,
  new_vaccinations numeric,
  acumlated_vac numeric,
  )
  insert into #PercentPopVac
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as acumlated_vac
from ProjectDatabase..CovidDeaths$ dea
join ProjectDatabase..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

   select *, (acumlated_vac/population)*100
  from #PercentPopVac


  -- views for later visualization
  
  Create view acumlated_vac as 
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as acumlated_vac
from ProjectDatabase..CovidDeaths$ dea
join ProjectDatabase..CovidVaccinations$ vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

  select * from acumlated_vac
