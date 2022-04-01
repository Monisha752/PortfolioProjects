select *
from Portfolioproject..['Covid-death$']
where continent is not null
order by 3,4 ;

select *
from Portfolioproject..['Covid-vaccination$']
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from Portfolioproject..['Covid-death$']
order by 1,2

-- Total_cases vs total_deaths in India

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_Percentage
from Portfolioproject..['Covid-death$']
where location like '%India%'
order by 1,2

-- Total_cases vs Popuation 
select location,date,population,total_cases,(total_cases/population)*100 as covidcase_Percentage
from Portfolioproject..['Covid-death$']
--where location like '%India%'
order by 1,2

--Country with highest covid_case_count

select location,population,max(total_cases) as max_covid_case_count ,max((total_cases/population))*100 as max_covid_case_Percentage
from Portfolioproject..['Covid-death$']
group by location, population
order by max_covid_case_Percentage desc

--Country with highest death_case_count continent-wise

select continent,max(cast(total_deaths as int)) as max_death_case_count
from Portfolioproject..['Covid-death$']
where continent is not null
group by continent
order by max_death_case_count desc
 
 --Global numbers
select  date,sum(new_cases) as total_new_cases,sum(cast(new_deaths as int)) as total_new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from Portfolioproject..['Covid-death$']
--where location like '%India%'
where continent is not null
group by date
order by 1,2

--checking Total population vs Vaccinations
With Popvsvac as
(
select d.continent,d.location,d.date, d.population,v.new_vaccinations,
	sum(convert(decimal,v.new_vaccinations)) over(partition by d.location order by d.location, v.date) as running_count_of_vaccinated
	
from Portfolioproject..['Covid-death$'] d 
join Portfolioproject..['Covid-vaccination$'] v 
	on d.location = v.location
	and d.date = v.date
--where d.continent is not null 
--order by 2,3 
)
select *,(running_count_of_vaccinated/population)*100,location
from Popvsvac

--creating temp table
drop table if exists #pop_vaccinated_percent
create table #pop_vaccinated_percent
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
running_count_of_vaccinated numeric
)


insert into #pop_vaccinated_percent
select d.continent,d.location,d.date, d.population,v.new_vaccinations,
	sum(convert(decimal,v.new_vaccinations)) over(partition by d.location order by d.location, v.date) as running_count_of_vaccinated
	
from Portfolioproject..['Covid-death$'] d 
join Portfolioproject..['Covid-vaccination$'] v 
	on d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3 

select *,(running_count_of_vaccinated/population)*100 as vaccinated_percent
from #pop_vaccinated_percent

---Creating View
create view population_vaccinated_percent as
select d.continent,d.location,d.date, d.population,v.new_vaccinations,
	sum(convert(decimal,v.new_vaccinations)) over(partition by d.location order by d.location, v.date) as running_count_of_vaccinated

from Portfolioproject..['Covid-death$'] d 
join Portfolioproject..['Covid-vaccination$'] v 
	on d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3

--Checking the view table
select * from population_vaccinated_percent














