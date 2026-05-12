create table netflix(
show_id varchar(6),
type varchar(10),
title varchar(150),
director varchar(208),
cast varchar(1000),
country varchar(150),
date_added varchar(50),
release_year Int,
rating varchar(10),
duration varchar(15),
listed_in varchar(25),
description varchar(250)
);

select * from netflix;

SELECT 
    COUNT(*) AS total_content
FROM
    netflix;
    
select distinct type from netflix;

-- 15 business problem

-- 1. count the number of movies and tv shows
SELECT 
    type, COUNT(*) AS total_content
FROM
    netflix
GROUP BY type;

-- 2. find the most common rating for movies and shows
 
select type,rating from(

	select 
	 type,
	 rating, -- rating
	 count(*), -- max(rating)
	 rank() over(partition by type order by count(*) desc) as ranking
	 from netflix
     -- group by 1,2
     -- order by 1,3 DESC
	 group by 1 , 2 -- goup by 1
 ) as t1
 where
	ranking = 1;

-- 3. list all movies released in a specific year(e.g.,2020)
select * from netflix;
select * from netflix
where
	type = "Movie"
	And
	release_year = 2020;
    
-- 4.find the top 5 countries with the most content on netflix
select 
	country,
    count(show_id) as total_content
from
	netflix
group by 1;



WITH RECURSIVE country_split AS (
    SELECT 
        show_id,
        SUBSTRING_INDEX(country, ',', 1) AS country_name,
        SUBSTRING(country, LOCATE(',', country) + 1) AS remaining_countries
    FROM netflix
    WHERE country IS NOT NULL

    UNION ALL

    SELECT 
        show_id,
        SUBSTRING_INDEX(remaining_countries, ',', 1),
        IF(LOCATE(',', remaining_countries) > 0, 
           SUBSTRING(remaining_countries, LOCATE(',', remaining_countries) + 1), 
           '')
    FROM country_split
    WHERE remaining_countries <> ''
)
SELECT 
    TRIM(country_name) AS country, 
    COUNT(show_id) AS total_content
FROM country_split
WHERE country_name <> ''
GROUP BY 1
ORDER BY total_content DESC;

SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(n.country, ',', h.help_topic_id + 1), ',', -1)) AS new_country,
    COUNT(n.show_id) AS total_content
FROM 
    netflix n
JOIN 
    mysql.help_topic h 
    ON h.help_topic_id < (LENGTH(n.country) - LENGTH(REPLACE(n.country, ',', '')) + 1)
WHERE 
    n.country IS NOT NULL 
    AND n.country <> ''
GROUP BY 1
ORDER BY total_content DESC;


-- 5.Identify the longest movie?
select * from netflix
where type ='Movie'
Order by cast(Replace(duration,'min','')as unsigned) DESC 
limit 5;

-- 6.find content added in the last 5 year
SELECT * 
FROM netflix
WHERE STR_TO_DATE(TRIM(date_added), '%M %e, %Y') >= DATE_SUB(NOW(), INTERVAL 5 YEAR);
-- CURRENT_DATE - INTERVAL 5 YEAR

-- 7. find all  the movies/Tv shows by director 'Rajiv Chilaka'
select * from netflix
where lower(director) like lower('%Rajiv chilaka%');

-- 8. list all tv shows with more than 5 seasons

select *,
	CAST(substring_index(duration, ' ',1) as unsigned) as season_count
from netflix
where 
	type = 'TV Show'
    AND CAST(substring_index(duration, ' ',1)as unsigned) > 5
order by season_count DESC,title ASC ;

-- 9. count the number of content items in each genre
WITH RECURSIVE genre_split AS (
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
        SUBSTRING(listed_in, LOCATE(',', listed_in) + 1) AS remaining
    FROM netflix
    WHERE listed_in IS NOT NULL

    UNION ALL
    SELECT 
        show_id,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)) AS genre,
        IF(LOCATE(',', remaining) > 0, SUBSTRING(remaining, LOCATE(',', remaining) + 1), '') AS remaining
    FROM genre_split
    WHERE remaining <> ''
)

SELECT 
    genre, 
    COUNT(show_id) AS total_content
FROM genre_split
GROUP BY genre
ORDER BY total_content DESC;

-- 10. find each year and the average numbers of content release in India on netflix 
-- return top 5 year with highest avg content release!

select * from netflix;
SELECT 
    STR_TO_DATE(date_added, '%M %e %Y') AS date, netflix.*
FROM
    netflix
WHERE
    country = 'India';
SELECT 
    YEAR(STR_TO_DATE(date_added, '%M %e, %Y')) AS year,
    COUNT(*) AS yearly_content,
    ROUND(
        COUNT(*) / (SELECT COUNT(*) FROM netflix WHERE country = 'India') * 100
    , 2) AS avg_content_per_year
FROM netflix
WHERE country = 'India' AND date_added is not null
GROUP BY 1;

-- 11. list all movies  that are documentaries

select * from netflix
where listed_in like '%documentaries%';

-- 12. find all content without  a director
select * from netflix
where director is NULL;

-- 13. find how many movies actor 'Salman Khan' appeared in last ten year

SELECT * 
FROM netflix
WHERE 
    cast LIKE '%Salman Khan%'
    AND 
    release_year > YEAR(CURDATE()) - 10;
-- 14. find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT 
    actor, 
    COUNT(*) AS total_content
FROM netflix,
JSON_TABLE(
    CONCAT('["', REPLACE(cast, ',', '","'), '"]'),
    "$[*]" COLUMNS(actor VARCHAR(255) PATH "$")
) AS jt
WHERE country = 'India'
GROUP BY actor
ORDER BY total_content DESC
LIMIT 10;


-- 15. categories  the content based on the presence  of the keywords 'kill' and 'violence'
-- in the description field . label content containing these keywords as bad , and all other
-- content as good . count how many items fall into each category.alter
with new_table as(
select *,
case 
when description like '%kill%'
OR
description like '%violence%' then 'Bad_Content'
else 'Good Content'
end category
from netflix)
select category,count(*) as total_content from new_table group by category


