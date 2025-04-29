# Netflix Movies and TV Shows Data Analysis-PostgresSQL

![Netflix Logo](https://github.com/isha-knee/Netflix_SQL_Project/blob/main/logo.png)

## Overview
This project presents an in-depth analysis of Netflix's movie and TV show catalog using SQL. The objective is to uncover meaningful insights and address key business questions through structured data exploration. This repository includes a comprehensive overview of the project's goals, the business problems tackled, solutions implemented, key findings, and final conclusions.

## Objectives

-Examine the distribution between movies and TV shows on the platform
-Identify the most frequently assigned ratings for both content types
-Analyze content trends based on release year, country of origin, and duration
-Categorize and explore content using specific criteria and keyword-based filtering

## Dataset

The data for this project is sourced from Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select type,count(type) as total_count
from netflix
group by type
```

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
with RatingCounts as(
select 
	type, rating, count(*) as rating_count
	from netflix
	group by type, rating
),
RankedRatings as(
select 
	type, rating, rating_count,
	rank() over (partition by type order by rating_count desc) as rank
	from RatingCounts
)
select 
	type,rating as most_frequent_rating
	from RankedRatings
	where rank=1;
```

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select title
 from netflix
 where type='Movie' and release_year=2020
```

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
with t1 as
 (select 
 	trim(unnest(string_to_array(country,','))) as country,
	count(*) as total_count
	from netflix
	where country is not null
	group by 1
	order by total_count desc
	limit 5) 
		select country 
		from t1;
```

### 5. Identify the Longest Movie

```sql
with t1 as
(select title
from netflix
where type='Movie' and duration=(select max(duration) as total_duration from netflix))
select title, (select max(duration) as total_duration from netflix)
from t1
```

### 6. Find Content Added in the Last 5 Years

```sql
select *
from netflix
where to_date(date_added, 'Month DD Year') >= current_date-interval '5 years'
```

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select type, title, unnest(string_to_array(director,','))
from netflix
where director= 'Rajiv Chilaka'
```

### 8. List All TV Shows with More Than 5 Seasons

```sql
select type, title,duration
from netflix
where type='TV Show' and split_part(duration,' ',1)::INT>5
```

### 9. Count the number of Shows/Movies in Each Genre

```sql
select trim(unnest(string_to_array(listed_in,','))) as genre,
count(*) as total_count
from netflix
group by 1
```

### 10.Find each year and the average numbers of content release in India on netflix. 

```sql
select release_year, country,
round(count(show_id)::numeric/
(select count(show_id) from netflix where country='India')::numeric*100,2) as average_release
from netflix
where country='India'
group by release_year, country
order by average_release desc
```

### 11. List All Movies that are Documentaries

```sql
select title,listed_in,type
from netflix
where listed_in like '%Documentaries' and type='Movie';
```

### 12. Find All Content Without a Director

```sql
select *
from netflix
where director is null
```

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select title, release_year
from netflix
where casts ilike '%Salman Khan%' and release_year >= extract(year from current_date)-10
group by title, release_year
```

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
select unnest(string_to_array(casts,',')) as actor,count(*)
from netflix
where country='India'
group by actor
order by count(*) desc
limit 10
```

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
select category, count(*) as content_count
from (
select
case
when description ilike '%kill%' or description ilike '%violence%' then 'Bad' else 'Good'
end as category
from netflix
) 
as categorized_content
group by category
```

*This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.*
