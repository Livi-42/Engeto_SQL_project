--3.Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

WITH cte_prices_2006 AS (
    SELECT 
        year
        ,"foodstuff"
        ,AVG("avg_price") AS "avg_price"
    FROM data_academy_content.t_livia_crhova_project_SQL_primary_final
    WHERE
    	year = 2006
    GROUP BY
    	"year"
    	,"foodstuff"
    ORDER BY 	
    	"year"
),
cte_prices_2018 AS (
    SELECT 
        year
        ,"foodstuff"
        ,AVG("avg_price") AS "avg_price"
    FROM data_academy_content.t_livia_crhova_project_SQL_primary_final
    WHERE
    	YEAR = 2018
    GROUP BY
    	"year"
    	,"foodstuff"
    ORDER BY 	
    	"year"
)
SELECT 
    f."foodstuff"
    ,f."avg_price" AS price_first_year
    ,l."avg_price" AS price_last_year
    ,(l."avg_price"-f."avg_price")/f."avg_price"*100 AS percentage_price_change
FROM cte_prices_2006 f
JOIN cte_prices_2018 l
	ON f."foodstuff" = l."foodstuff"
ORDER BY
	percentage_price_change