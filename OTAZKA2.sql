--2.Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

WITH cte_first_last_prices AS (
    SELECT 
        year
        ,"foodstuff"
        ,AVG("avg_price") AS "avg_price"
        ,ROW_NUMBER() OVER (PARTITION BY "foodstuff" ORDER BY year ASC) AS "first_year"
        ,ROW_NUMBER() OVER (PARTITION BY "foodstuff" ORDER BY year DESC) AS "last_year"
    FROM data_academy_content.t_livia_crhova_project_SQL_primary_final
    WHERE 
    	LOWER("foodstuff") LIKE '%ml_ko%' 
    	OR LOWER("foodstuff") LIKE '%chl_b%'
    GROUP BY
    	"year"
    	,"foodstuff"
),
cte_first_last_pays AS (
	SELECT 
        year
        ,ROUND(AVG("avg_pay")::NUMERIC, 2) AS "avg_pay"
        ,ROW_NUMBER() OVER (ORDER BY year ASC) AS "first_year"
        ,ROW_NUMBER() OVER (ORDER BY year DESC) AS "last_year"
    FROM data_academy_content.t_livia_crhova_project_SQL_primary_final
    WHERE
    	branch LIKE '%fyzický%'						--možnost změnit 'fyzický' na 'přepočtený' pro přepočet průměrné mzdy na FTE místo fyzických osob
    GROUP BY
    	"year"
)
SELECT 
    price."foodstuff"
    ,MIN(CASE WHEN price."first_year" = 1 THEN price.year END) AS "first_year"
    ,MIN(CASE WHEN price."first_year" = 1 THEN price."avg_price" END) AS "price_first_year"
    ,MAX(CASE WHEN pay."first_year" = 1 THEN pay."avg_pay" END) AS "pay_first_year"
    ,FLOOR(MAX(CASE WHEN pay."first_year" = 1 THEN pay."avg_pay" END) / 
    	MIN(CASE WHEN price."first_year" = 1 THEN price."avg_price" END)) AS "purchase_first_year"					
    ,MIN(CASE WHEN price."last_year" = 1 THEN price.year END) AS "last_year"
    ,MIN(CASE WHEN price."last_year" = 1 THEN price."avg_price" END) AS "price_last_year"
    ,MAX(CASE WHEN pay."last_year" = 1 THEN pay."avg_pay" END) AS "pay_last_year"
    ,FLOOR(MAX(CASE WHEN pay."last_year" = 1 THEN pay."avg_pay" END) / 
    	MIN(CASE WHEN price."last_year" = 1 THEN price."avg_price" END)) AS "purchase_last_year"					
FROM cte_first_last_prices AS price
JOIN cte_first_last_pays AS pay
	ON price.year = pay.YEAR
GROUP BY price."foodstuff";
