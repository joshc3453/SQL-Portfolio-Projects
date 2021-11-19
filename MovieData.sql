-- Database of Top 5000 Movies from TMDB

USE MovieProject;

SELECT * FROM topmovies;
SELECT * FROM moviebudgets;


-- Breakdown of top movies per year. Conclusion: 2009 had the most "top" movies.
SELECT YEAR(release_date), COUNT(*)
FROM topmovies
GROUP BY YEAR(release_date)
ORDER BY COUNT(*) DESC;

-- Top year for movies pre-2000s century
SELECT YEAR(release_date), COUNT(*)
FROM topmovies
WHERE YEAR(release_date) < 2000
GROUP BY YEAR(release_date)
ORDER BY COUNT(*) DESC;

-- Top movies where original language is NOT in English
SELECT title, original_language
FROM topmovies
WHERE original_language <> 'en'

-- Average rating of english top5000 movie vs non-english top5000 movie using CTEs

WITH engmovies AS (
SELECT title, original_language, vote_average
FROM topmovies
WHERE original_language = 'en'
)
SELECT AVG(vote_average)
FROM engmovies

WITH foreignmovies AS (
SELECT title, original_language, vote_average
FROM topmovies
WHERE original_language <> 'en'
)
SELECT AVG(vote_average)
FROM foreignmovies



-- movie duration vs rating

SELECT title, vote_average, ISNULL(runtime, 0) AS runtime
FROM topmovies
WHERE ISNULL(runtime, 0) > 0
AND vote_count > 300
ORDER BY runtime



-- does higher budget mean better rating? (removed outiers via vote count)
SELECT t.title, t.vote_average, m.budget 
FROM topmovies AS t
INNER JOIN moviebudgets AS m
ON t.id = m.id
WHERE vote_count > 500
ORDER BY vote_average DESC;



-- Most Profitable Movies (Revenue - Budget)
SELECT title, (revenue - budget) AS netprofit
FROM moviebudgets
ORDER BY netprofit DESC;


-- Are movies getting longer or shorter over time?

SELECT YEAR(release_date) AS releaseyear, AVG(runtime) AS avgruntime
FROM topmovies
GROUP BY YEAR(release_date)
ORDER BY AVG(runtime) DESC;

SELECT YEAR(release_date) AS releaseyear, AVG(runtime) AS avgruntime
FROM topmovies
WHERE YEAR(release_date) >= 2000
GROUP BY YEAR(release_date)
ORDER BY YEAR(release_date)

-- Are foriegn language movies longer on average than english language movies?

SELECT AVG(runtime) AS runtime_english FROM topmovies
WHERE original_language = 'en'

SELECT AVG(runtime) AS runtime_foreign FROM topmovies
WHERE original_language <> 'en'

-- Window function showing average run time per language
SELECT DISTINCT original_language, AVG(runtime) OVER (PARTITION BY original_language ORDER BY original_language) AS avgruntimelanguage
FROM topmovies
ORDER BY avgruntimelanguage


-- Movie releases per year  *Note this dataset was uploaded in 2017 so 2016 & 2017 movie data is incomplete. Analysis from 2015 and prior
SELECT YEAR(release_date), COUNT(*)
FROM topmovies
WHERE YEAR(release_date) <= 2015
GROUP BY YEAR(release_date)
ORDER BY YEAR(release_date) DESC

-- Are movies released more frequently in certain months?

-- Select just month and year of release date // Which month/year had the most releases
SELECT CONCAT(YEAR(release_date),'-',MONTH(release_date)) AS yearmonth, COUNT(*)
FROM topmovies
GROUP BY CONCAT(YEAR(release_date),'-',MONTH(release_date))
ORDER BY COUNT(*) DESC

-- Which month has the most movie releases
SELECT MONTH(release_date) AS month, COUNT(*)
FROM topmovies
GROUP BY MONTH(release_date)
ORDER BY COUNT(*) DESC

-- The Lord of the Rings Trilogy Analysis / Creating View / Does most profitable correlate to vote average?
SELECT *
FROM topmovies
WHERE TITLE LIKE 'The Lord of the Rings%';

SELECT a.title, a.popularity, a.release_date, a.runtime, a.vote_average, b.budget, b.revenue
FROM topmovies AS a
INNER JOIN moviebudgets AS b
ON a.id = b.id
WHERE a.title LIKE 'The Lord of the Rings%';

CREATE VIEW LOTR AS
SELECT a.title, a.popularity, a.release_date, a.runtime, a.vote_average, b.budget, b.revenue
FROM topmovies AS a
INNER JOIN moviebudgets AS b
ON a.id = b.id
WHERE a.title LIKE 'The Lord of the Rings%';

SELECT title, vote_average, (revenue - budget) AS netprofit
FROM lotr
ORDER BY netprofit DESC

-- Correlated Subquery to show top movie based on voter average for each original language
SELECT title, vote_average,runtime, original_language
FROM topmovies AS t1
WHERE vote_average IN 
	(
	SELECT MAX(t2.vote_average)
	FROM topmovies AS t2
	WHERE t1.original_language = t2.original_language
	)
ORDER BY original_language;

-- Visualizations for Tableau
-- #1 movie duration vs rating
SELECT title, vote_average, ISNULL(runtime, 0) AS runtime
FROM topmovies
WHERE ISNULL(runtime, 0) > 0
AND vote_count > 300
ORDER BY runtime

-- #2 Most Profitable Movies (Revenue - Budget) (Maybe take top 5, bottom 5)
SELECT TOP 5 title, (revenue - budget) AS netprofit
FROM moviebudgets
ORDER BY netprofit DESC;

-- #3 Movie Releases Per Year
SELECT YEAR(release_date) AS year, COUNT(*) AS moviesreleased
FROM topmovies
WHERE YEAR(release_date) <= 2015
GROUP BY YEAR(release_date)
ORDER BY YEAR(release_date) DESC

-- #4 Which season has the most movie releases // Season
SELECT MONTH(release_date) AS month, COUNT(*) AS count,
CASE
WHEN MONTH(release_date) IN (12, 1, 2) THEN 'Winter'
WHEN MONTH(release_date) IN (3, 4, 5) THEN 'Spring'
WHEN MONTH(release_date) IN (6, 7, 8) THEN 'Summer'
ELSE 'Fall'
END AS season
FROM topmovies
WHERE MONTH(release_date) IS NOT NULL
GROUP BY MONTH(release_date)
ORDER BY MONTH(release_date)

-- #5 LOTR Analysis
SELECT title, vote_average, (revenue - budget) AS netprofit
FROM lotr
ORDER BY netprofit DESC

