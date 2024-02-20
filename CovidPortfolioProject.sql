USE ProjectPortfolio

SELECT * FROM CovidDeaths ORDER BY 3,4


-- Select Data that we are going to be using

Select  location,date,total_cases,new_cases,total_deaths,population
From CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths

Select  location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
From CovidDeaths
Where location like 'Portugal'
Order by 1,2

-- Percentage of Population that got covid
Select  location,date,total_cases,population,(total_cases/population) * 100 as CasesPercentage
From CovidDeaths
Where location like 'Portugal'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select  location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population) * 100) as CasesPercentage
From CovidDeaths
Group by location,population
Order by 4 DESC

-- Showing Countries with Highest Death Count per Population

Select  location,MAX(cast(total_deaths as Int)) as TotalDeathCount
From CovidDeaths
Where Continent is not null
Group by location
Order by TotalDeathCount Desc


--Break down by Continent
Select continent,MAX(cast(total_deaths as Int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount Desc

--Showing Continents with the highest death count per population

Select  location,MAX(cast(total_deaths as Int)) as TotalDeathCount
From CovidDeaths
Where Continent is not null
Group by location
Order by TotalDeathCount Desc



-- GLOBAL NUMBERS per day

Select Cast(date as DATE) as Date, SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Overall Global numbers
Select  SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From CovidDeaths
Where continent is not null
Order by 1,2



--Looking at total population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
AND dea.location like 'Portugal'
order by 1,2,3





--Use CTE

With PopvsVac (Continent,Location,Date,Population,NewVaccinations,RollingPeopleVaccinated) AS
(
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as INT)) Over (Partition by dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
 On dea.location=vac.location
 And dea.date =vac.date
 Where dea.continent is not null
 AND dea.location like 'Portugal'
)
Select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac



--USE TempTable
DROP table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)


Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as INT)) Over (Partition by dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
 On dea.location=vac.location
 And dea.date =vac.date
 Where dea.continent is not null
 AND dea.location like 'Portugal'


 Select *,(RollingPeopleVaccinated/Population)*100  from #PercentPopulationVaccinated Order by (RollingPeopleVaccinated/Population)*100 DESC


 --Create View to store data for later visualizations


 Create View PercentPopulationVaccinated as
 Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as INT)) Over (Partition by dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
from CovidDeaths dea
Join CovidVaccinations vac
 On dea.location=vac.location
 And dea.date =vac.date
 Where dea.continent is not null
