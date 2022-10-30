

Select *
From ProjectCovid19..CovidDeath
where continent is not NULL
order by 3,4


--Select *
--From ProjectCovid19..CovidDeath
--order by 3,4

-- Selecting Data

Select Location, date, total_cases, total_deaths, population
From ProjectCovid19..CovidDeath
where continent is not NULL
order by 1,2


-- Check Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectCovid19..CovidDeath
Where location like '%malays%' -- Check for Malaysia
and continent is not NULL
order by 1,2


-- Total Cases vs Populations
-- Shows the percentage of population that got covid
Select Location, date, population,total_cases,  (total_cases/population)*100 as PercentageGotCovid
From ProjectCovid19..CovidDeath
where continent is not NULL
--Where location like '%malays%' -- Check for Malaysia
order by 1,2


-- Countries with highest Infection Rate compared to Population

Select Location, population,MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From ProjectCovid19..CovidDeath
--Where location like '%malays%' -- Check for Malaysia
where continent is not NULL
GROUP BY Location, population
order by PercentPopulationInfected Desc


-- Countries with Highest Death

Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount -- Convert total_deaths into Integer/Int
From ProjectCovid19..CovidDeath
where continent is not NULL
GROUP BY Location
order by TotalDeathCount Desc


-- Show by Continent
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount -- Convert total_deaths into Integer/Int
From ProjectCovid19..CovidDeath
where continent is not NULL
GROUP BY continent
order by TotalDeathCount Desc


-- Global Numbers 


-- Death Percentage for each date
Select  date, SUM(new_cases)as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths,  (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage   -- convert form char to int 
From ProjectCovid19..CovidDeath
--Where location like '%malays%' -- Check for Malaysia
Where continent is not NULL
Group By date
order by 1,2


---Total Populations vs  Vaccinations
-- JOIN these 2 tables
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100  CANT USE THE Column that have been created just like that

From ProjectCovid19..CovidDeath death
Join ProjectCovid19..CovidVaccinations vac On death.location = vac.location and death.date = vac.date
Where death.continent is not null
Order By 2,3



-- Using CTE
-- Population vs Vaccination

with PopVSVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as

-- Inner Query against CTE
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
From ProjectCovid19..CovidDeath death
Join ProjectCovid19..CovidVaccinations vac On death.location = vac.location and death.date = vac.date
Where death.continent is not null
--Order By 2,3
)

-- Outer Query against CTE
Select *, (RollingPeopleVaccinated/Population) * 100  as PercentageVaccinated--Columns for percentage people vaccinated
From PopVSVac




-- TEMP TABLE
DECLARE @SQL nvarchar(max) -- Increase the size, due to error at code below
Drop Table if exist #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
( -- Specify the columns
Continent nvarchar(255),
Location nvarchar(255),  Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated -- insert all the data/ columns into #PercentPopulationVaccinated

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
From ProjectCovid19..CovidDeath death
Join ProjectCovid19..CovidVaccinations vac On death.location = vac.location and death.date = vac.date
Where death.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated




-- Create View to Store Data (for Visualisations)
Create View PercentPopulationVaccinated as

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 
From ProjectCovid19..CovidDeath death
Join ProjectCovid19..CovidVaccinations vac On death.location = vac.location and death.date = vac.date
Where death.continent is not null
--Order By 2,3


-- Check the views that have been created, with name PercentPopulationVaccinated
Select *
From PercentPopulationVaccinated