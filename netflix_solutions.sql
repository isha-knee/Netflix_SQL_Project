create table netflix
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

--number of movies and shows
select type,count(type) as total_count
from netflix
group by type

--most common rating for movies and shows
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
--List all movies released in a specific year (e.g., 2020)
 select title
 from netflix
 where type='Movie' and release_year=2020

 --Find the top 5 countries with the most content on Netflix
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

--Identify the longest movie
with t1 as
(select title
from netflix
where type='Movie' and duration=(select max(duration) as total_duration from netflix))
select title, (select max(duration) as total_duration from netflix)
from t1

--Find content added in the last 5 years
--to_date() is converting char datatype to timestamp
select *
from netflix
where to_date(date_added, 'Month DD Year') >= current_date-interval '5 years'

--Find all the movies/TV shows by director 'Rajiv Chilaka'!
select type, title, unnest(string_to_array(director,','))
from netflix
where director= 'Rajiv Chilaka'

--List all TV shows with more than 5 seasons
select type, title,duration
from netflix
where type='TV Show' and split_part(duration,' ',1)::INT>5

--Count the number of shows/movies each genres
select trim(unnest(string_to_array(listed_in,','))) as genre,
count(*) as total_count
from netflix
group by 1

--Find each year the average number of content release in India on netflix.
select release_year, country,
round(count(show_id)::numeric/
(select count(show_id) from netflix where country='India')::numeric*100,2) as average_release
from netflix
where country='India'
group by release_year, country
order by average_release desc

--List All Movies that are Documentaries
select title,listed_in,type
from netflix
where listed_in like '%Documentaries' and type='Movie';

--Find All Content Without a Director
select *
from netflix
where director is null

--Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
select title, release_year
from netflix
where casts ilike '%Salman Khan%' and release_year >= extract(year from current_date)-10
group by title, release_year

--Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
select unnest(string_to_array(casts,',')) as actor,count(*)
from netflix
where country='India'
group by actor
order by count(*) desc
limit 10

--Categorize Content as 'Good' based on the Presence of 'Kill' and 'Violence' Keywords and 'Good' otherwise
SELECT category, COUNT(*) AS content_count
FROM (
SELECT 
CASE 
WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad' ELSE 'Good'
END AS category
FROM netflix
) 
AS categorized_content
GROUP BY category;


