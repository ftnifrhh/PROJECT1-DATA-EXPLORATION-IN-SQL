--| PROJECT : DATA EXPLORATION IN SQL|---------------------------

-- |* what we are doing here in sql, we are going to visualize it later |---

---------select data that we are going to be using--------
select continent,date,total_cases,new_cases,total_deaths,population
from CovidDeaths$
where continent is null
order by 1,2

--------- aim : looking at total cases vs total deaths-----
---------- *it shows the likelihood of dying if you contract covid in your country--
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$\
where continent is not null
where location like '%states%'
order by 1,2

--LET's BREAK THINGS DOWN BY LOCATION. YOU MAY CHANGE IT TO CONTINENT TOO IF YOU WANT  --

--------- aim : looking at total cases vs population-----
--------------*shows what percentage of population got covid based on location--
Select Location, date, total_cases, population, (total_cases/population)*100 as 'Percentage of Population got covid/infected'
From CovidDeaths$
where location like '%states%'
order by 1,2

--------- aim: what country get highest infection rate compared to population-------------
--- note : a group by is needed kalau kat bahagian select kita ada aggregate function
Select Location,  population, max(total_cases) as HighestNumberOfCasesForThisCountry, Max (  (total_cases/population) ) *100 as 'Highest percentage of people got Covid'
From CovidDeaths$
where continent is null
group by location,population
order by 'Highest percentage of people got Covid' desc

--------- aim: what country with highest death count per population-------------
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

-------- aim : to know the total_cases,total_deaths and Death Percentage for global ( not count based on location/ continent)-----
select 
sum(new_cases) as 'Total Cases',
sum( cast(new_deaths as int) ) as 'Total Deaths',
(sum( cast(new_deaths as int) ) / sum (New_Cases) )*100 as DeathPercentage
from CovidDeaths$
where continent is null
order by 1,2

-------- aim : looking at total population vs vaccinations (per/day)------------------
-------- * this sql query shows us that every new vaccinations on that day will be added into total new vaccine--------
select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum ( convert( int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as TotalNewVaccine
from CovidDeaths$ dea
join CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

----- aim : looking at the percentage of people get vaccinated (global) using CTE----
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as ' percentage of people get vaccinated'
From PopvsVac


----- aim : looking at the percentage of people get vaccinated (global) using TEMP TABLE----
DROP Table if exists #PercentPopulationVaccinatedO
Create Table #PercentPopulationVaccinatedO
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinatedO
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as ' percentage of people get vaccinated'
From #PercentPopulationVaccinatedO


