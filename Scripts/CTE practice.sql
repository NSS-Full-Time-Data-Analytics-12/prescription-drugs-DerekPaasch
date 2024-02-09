WITH first_year AS(SELECT domestic_distributor_id, MIN(release_year) AS first_year
				   FROM specs
				   WHERE domestic_distributor_id IS NOT NULL
				   Group By domestic_distributor_id)
SELECT (release_year - first_year) AS years_in_biz
		, AVG(film_budget)::money AS avg_budget
		, AVG(worldwide_gross)::money AS avg_gross
		
FROM first_year INNER JOIN specs USING (domestic_distributor_id)
				INNER JOIN revenue USING( movie_id)
GROUP BY release_year - first_year
ORDER BY years_in_biz;

--------------------------------------------------------------------------------------------------

WITH first_release AS (SELECT domestic_distributor_id, MIN(release_year) AS first_release
					   FROM specs
					   WHERE domestic_distributor_id IS NOT NULL
					   GROUP BY domestic_distributor_id)
					   
SELECT (release_year - first_release) AS years_in_biz
		, AVG(worldwide_gross)::money AS avg_gross
		, AVG(film_budget)::money AS avg_budget
FROM first_release INNER JOIN specs USING (domestic_distributor_id)
				   INNER JOIN revenue USING (movie_id)
GROUP BY years_in_biz
ORDER BY years_in_biz;
--------------------------------------------------------------------------------------------------

