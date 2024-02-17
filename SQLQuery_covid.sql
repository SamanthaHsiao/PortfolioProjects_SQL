SELECT *
FROM Project_civid..covid_death
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM Project_civid..covid_vaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
		FROM Project_civid..covid_death
			ORDER BY 3,4

--total cases vs total deaths
SELECT location, date, total_deaths, total_cases, (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 as deathpercentage
		FROM Project_civid..covid_death
			WHERE location like '%state%'
			ORDER BY 1,2

SELECT location,  population, MAX(total_cases) as highinfectioncount, MAX(CAST(total_cases AS float) / CAST(population AS float))*100 as infectioncountpercentage
		FROM Project_civid..covid_death
			--WHERE location like '%state%'
			GROUP BY location, population
			ORDER BY infectioncountpercentage desc

SELECT continent, MAX(CAST(total_deaths AS int)) as highdeathcount
		FROM Project_civid..covid_death
			--WHERE location like '%state%'
			where continent is not null
			GROUP BY continent
			ORDER BY highdeathcount desc

SELECT location, MAX(CAST(total_deaths AS int)) as highdeathcount
		FROM Project_civid..covid_death
			--WHERE location like '%state%'
			where continent is null
			GROUP BY location
			ORDER BY highdeathcount desc

-- GLOBAL NUMBERS
SELECT SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases) *100
		FROM Project_civid..covid_death
			WHERE continent is not null
			ORDER BY 1,2

--cte
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevac)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
			FROM Project_civid..covid_death dea
				JOIN Project_civid..covid_vaccinations vac
				on dea.location = vac.location and dea.date = vac.date
				WHERE dea.continent is not null
				-- ORDER BY 2,3
)

select *,  (rollingpeoplevac/population)*100
from popvsvac

--temp table
drop table if exists #percectpopulationvac
CREATE TABLE #percectpopulationvac

(continent nvarchar(255),
location  nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeopelevac numeric
)
insert into #percectpopulationvac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
			FROM Project_civid..covid_death dea
				JOIN Project_civid..covid_vaccinations vac
				on dea.location = vac.location and dea.date = vac.date
				WHERE dea.continent is not null
				-- ORDER BY 2,3

select *,  (rollingpeoplevac/population)*100
from #percectpopulationvac


create view percectpopulationvac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevac
			FROM Project_civid..covid_death dea
				JOIN Project_civid..covid_vaccinations vac
				on dea.location = vac.location and dea.date = vac.date
				WHERE dea.continent is not null


select *
from percectpopulationvac
