--Write a CTE called top_gold_winter to find the top 5 gold-medal-winning countries for winter games in the database. 
--Then write query to select the countries and the number of medals from the CTE where the total gold medals won is greater than or equal to 5.


WITH top_gold_winter AS (SELECT country_id, COUNT(gold) AS top_gold_winter
					  	 FROM winter_games
					 	 WHERE gold IS NOT NULL
					 	 GROUP BY country_id, gold
					 	 ORDER BY top_gold_winter DESC)
					  
SELECT *
FROM top_gold_winter INNER JOIN countries ON countries.id = top_gold_winter.country_id
WHERE top_gold_winter >= '5'
ORDER BY top_gold_winter DESC;


--Write a CTE called "tall_athletes" to find the athletes in the database who are taller than the average height for all athletes in the database. 
--Next query that data to get just the female athletes who are taller than the average height for all athletes and are over the age of 30.


WITH tall_athletes AS (SELECT name, height AS tall_athletes
					   FROM athletes
					   WHERE height > (SELECT AVG(height)
			    	   FROM athletes)
					   ORDER BY height DESC)

SELECT name, gender, age, height
FROM athletes INNER JOIN tall_athletes USING(name)
WHERE age > '30' AND gender = 'F'
ORDER BY height DESC;

--Write a CTE called tall_over30_female_athletes that returns the final results of exercise 2 above. Next query the CTE to find the average weight for the over 30 female athletes

WITH tall_over30_female_athletes AS (SELECT name, height AS tall_over30_female_athletes
					   				 FROM athletes
					   				 WHERE height > (SELECT AVG(height)
			    	   				 FROM athletes)
					   				 ORDER BY weight DESC)

SELECT ROUND(AVG(weight), 2)
FROM athletes INNER JOIN tall_over30_female_athletes USING(name)
WHERE age > '30' AND gender = 'F'
