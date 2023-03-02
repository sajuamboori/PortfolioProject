select * from CovidDeaths;
select * from CovidVaccinations;
drop table CovidDeaths;

-- Create tables CovidDeaths

CREATE TABLE `CovidDeaths` (
  `iso_code` varchar(50) DEFAULT NULL,
  `continent` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `total_cases` long DEFAULT NULL,
  `new_cases` long DEFAULT NULL,
  new_cases_smoothed long DEFAULT NULL,
total_deaths long DEFAULT NULL,
new_deaths long DEFAULT NULL,
new_deaths_smoothed long DEFAULT NULL,
total_cases_per_million long DEFAULT NULL,
new_cases_per_million long DEFAULT NULL,
new_cases_smoothed_per_million long DEFAULT NULL,
total_deaths_per_million long DEFAULT NULL,
new_deaths_per_million long DEFAULT NULL,
new_deaths_smoothed_per_million long DEFAULT NULL,
reproduction_rate long DEFAULT NULL,
icu_patients long DEFAULT NULL,
icu_patients_per_million long DEFAULT NULL,
hosp_patients long DEFAULT NULL,
hosp_patients_per_million long DEFAULT NULL,
weekly_icu_admissions long DEFAULT NULL,
weekly_icu_admissions_per_million long DEFAULT NULL,
weekly_hosp_admissions long DEFAULT NULL,
weekly_hosp_admissions_per_million long DEFAULT NULL,
new_tests long DEFAULT NULL,
population bigint DEFAULT NULL

)

-- Create tables CovidVacconated

CREATE TABLE `CovidVaccinations` (
  `iso_code` varchar(50) DEFAULT NULL,
  `continent` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `date` date DEFAULT NULL,
new_tests long DEFAULT NULL,
total_tests long DEFAULT NULL,
total_tests_per_thousand long DEFAULT NULL,
new_tests_per_thousand long DEFAULT NULL,
new_tests_smoothed long DEFAULT NULL,
new_tests_smoothed_per_thousand long DEFAULT NULL,
positive_rate long DEFAULT NULL,
tests_per_case long DEFAULT NULL,
tests_units long DEFAULT NULL,
total_vaccinations long DEFAULT NULL,
people_vaccinated long DEFAULT NULL,
people_fully_vaccinated long DEFAULT NULL,
new_vaccinations long DEFAULT NULL,
new_vaccinations_smoothed long DEFAULT NULL,
total_vaccinations_per_hundred long DEFAULT NULL,
people_vaccinated_per_hundred long DEFAULT NULL,
people_fully_vaccinated_per_hundred long DEFAULT NULL,
new_vaccinations_smoothed_per_million long DEFAULT NULL,	
stringency_index long DEFAULT NULL,
population_density long DEFAULT NULL,
median_age long DEFAULT NULL,
aged_65_older long DEFAULT NULL
)

Select *
from PortfolioProject.CovidDeaths 
order by 3,4 

-- Select data we are going to use

Select location, date, total_cases, new_cases, total_deaths
from PortfolioProject.CovidDeaths 

-- death percentage 
-- Likelyhood of dying if you contact covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.CovidDeaths 
where location like '%Kingdom%' ;

-- Countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PerecntPopulationInfected
from PortfolioProject.CovidDeaths
Group by location, population 
order by PerecntPopulationInfected desc;

-- Countries with highest death count compared to population

Select location, max(cast(total_deaths as decimal)) as TotaldeathtCount
from PortfolioProject.CovidDeaths
-- where continent is NOT NULL and continent <> ''
where continent <> ''
Group by location 
order by TotaldeathtCount desc;

-- Break things by continet

Select continent, max(cast(total_deaths as decimal)) as TotaldeathtCount
from PortfolioProject.CovidDeaths
-- where continent is NOT NULL and continent <> ''
where continent <> ''
Group by continent
order by TotaldeathtCount desc;

-- Showing continents with highest death counts

Select continent, max(cast(total_deaths as decimal)) as TotaldeathtCount
from PortfolioProject.CovidDeaths
-- where continent is NOT NULL and continent <> ''
where continent <> ''
Group by continent
order by TotaldeathtCount desc;

-- Global Numbers
-- Global Numbers
Select date, sum(new_cases) as TotalCases, sum(new_deaths) as totalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.CovidDeaths 
where continent <> ''
group by date
order by 1,2 ;

-- Global Numbers overall 

Select sum(new_cases) as TotalCases, sum(new_deaths) as totalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.CovidDeaths 
where continent <> ''
-- group by date
order by 1,2 ;
-- where location like '%Kingdom%' ;


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.CovidDeaths dea
join PortfolioProject.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent <> ''
order by 2, 3;

-- Total population vs vaccinations
-- CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.CovidDeaths dea
join PortfolioProject.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent <> ''
-- order by 2, 3
)
 Select * , (RollingPeopleVaccinated/Population)*100
 From PopvsVac;
 
 -- Temp table --
-- Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Date,
Population Bigint,
New_vaccinations int,
RollingPeopleVaccinated int
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.CovidDeaths dea
join PortfolioProject.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
-- where dea.continent <> ''
-- order by 2, 3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for visualisations
percentpopulationvaccinatedpercentpopulationvaccinatedCreate view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.CovidDeaths dea
join PortfolioProject.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
-- where dea.continent <> ''
-- order by 2,  3

