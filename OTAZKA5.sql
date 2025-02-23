--5.Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
--projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

WITH cte_yearly_changes AS(	
	SELECT 
		year
		,AVG("avg_pay") AS avg_pay
		,(SELECT AVG("avg_pay") 
     		FROM data_academy_content.t_livia_crhova_project_sql_primary_final 
     		WHERE "year" = 2006 AND branch LIKE '%fyzický%') AS "avg_pay_first_year"
		,AVG("avg_price") AS avg_price							
		,(SELECT AVG("avg_price") 
     		FROM data_academy_content.t_livia_crhova_project_sql_primary_final 
     		WHERE "year" = 2006) AS "avg_price_first_year"
	FROM data_academy_content.t_livia_crhova_project_sql_primary_final AS primary_table 
	WHERE
		branch LIKE '%fyzický%'							--možnost změnit 'fyzický' na 'přepočtený' pro přepočet průměrné mzdy na FTE místo fyzických osob
	GROUP BY
		year
),
cte_gdp_changes AS (
	SELECT
		year
		,gdp
		,(SELECT gdp 
     		FROM data_academy_content.t_livia_crhova_project_sql_secondary_final 
     		WHERE "year" = 2006 AND country = 'Czech Republic') AS "gdp_first_year"
	FROM data_academy_content.t_livia_crhova_project_sql_secondary_final
	WHERE 
		country = 'Czech Republic'
)
SELECT 
	yc.year
	,ROUND(((avg_pay - avg_pay_first_year)/avg_pay_first_year *100)::NUMERIC, 2) AS percentage_pay_growth
	,ROUND(((avg_price - avg_price_first_year)/avg_price_first_year *100)::NUMERIC, 2) AS percentage_price_growth
	,ROUND(((gdp - gdp_first_year)/gdp_first_year *100)::NUMERIC, 2) AS percentage_gdp_growth
FROM cte_yearly_changes AS yc
JOIN cte_gdp_changes AS gc
	ON yc.year = gc.year