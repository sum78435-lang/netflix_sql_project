# Netflix Movies and Tv Shows data Analysis using MySQL
![Netflix logo](https://github.com/sum78435-lang/netflix_sql_project/blob/main/Netflix_Logo_RGB.png)

## Objective
- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.
## Dataset
The data for this project is sourced from the Kaggle dataset:

-**Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

```sql

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
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```
**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

``` sql
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
```
**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)
```sql
select * from netflix
where
	type = "Movie"
	And
	release_year = 2020;
```
**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix
```sql
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
```
### use join
```sql
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
```
**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie
```sql
select * from netflix
where type ='Movie'
Order by cast(Replace(duration,'min','')as unsigned) DESC 
limit 5;
```
**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years
```sql
SELECT * 
FROM netflix
WHERE STR_TO_DATE(TRIM(date_added), '%M %e, %Y') >= DATE_SUB(NOW(), INTERVAL 5 YEAR);
-- CURRENT_DATE - INTERVAL 5 YEAR
```
**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
```sqlselect * from netflix
where lower(director) like lower('%Rajiv chilaka%');
```
**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons
```sql
select *,
	CAST(substring_index(duration, ' ',1) as unsigned) as season_count
from netflix
where 
	type = 'TV Show'
    AND CAST(substring_index(duration, ' ',1)as unsigned) > 5
order by season_count DESC,title ASC ;
```
**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
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
```
**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release
 ```sql
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
```
**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries
```sql
select * from netflix
where listed_in like '%documentaries%';
```
**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director
```sql
select * from netflix
where director is NULL;
```
**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
```sql
SELECT * 
FROM netflix
WHERE 
    cast LIKE '%Salman Khan%'
    AND 
    release_year > YEAR(CURDATE()) - 10;
```
**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
```sql
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
```
**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
```sql
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
```
**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.


