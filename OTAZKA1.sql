--1.Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají? 
 
WITH cte_pay_analysis AS (
	SELECT 
	    pay.year
	    ,pay.branch
	    ,ROUND(AVG(pay."avg_pay")::NUMERIC, 2) AS "avg_pay"
	    ,LAG(AVG(pay."avg_pay")) OVER (PARTITION BY pay.branch ORDER BY pay.year) AS "prev_pay"
	    ,ROUND(AVG(pay."avg_pay")::NUMERIC, 2) - LAG(AVG(pay."avg_pay")) OVER (PARTITION BY pay.branch ORDER BY pay.year) AS difference
	    ,ROW_NUMBER() OVER (PARTITION BY branch ORDER BY year ASC) AS "first_year"
        ,ROW_NUMBER() OVER (PARTITION BY branch ORDER BY year DESC) AS "last_year"
	    ,CASE 																	--možnost vyhodnocení meziročního trendu mezd
	    	WHEN "avg_pay" > LAG(AVG(pay."avg_pay")) OVER (PARTITION BY pay.branch ORDER BY pay.year) THEN 'Increased'
	        WHEN "avg_pay" < LAG(AVG(pay."avg_pay")) OVER (PARTITION BY pay.branch ORDER BY pay.year) THEN 'Decreased'
	        WHEN LAG(AVG(pay."avg_pay")) OVER (PARTITION BY pay.branch ORDER BY pay.year) IS NULL THEN ''
	        ELSE 'No Change'
	    END AS "wage_trend"
	FROM data_academy_content.t_livia_crhova_project_SQL_primary_final pay
	WHERE pay.branch LIKE '%fyzický%'									--možnost změnit 'fyzický' na 'přepočtený' pro přepočet průměrné mzdy na FTE místo fyzických osob
	GROUP BY 
	    pay.year
	    ,pay.branch
	    ,pay."avg_pay"
	ORDER BY 
	    branch
	    ,YEAR    
)
SELECT 
	branch
	,MAX(CASE WHEN pa.first_year = 1 THEN pa.avg_pay END) AS pay_first_year
	,MIN(CASE WHEN pa.last_year = 1 THEN pa.avg_pay END) AS pay_last_year
	,MIN(CASE WHEN pa.last_year = 1 THEN pa.avg_pay END)-MAX(CASE WHEN pa.first_year = 1 THEN pa.avg_pay END) AS pay_difference
	,CASE
		WHEN MIN(CASE WHEN pa.last_year = 1 THEN pa.avg_pay END)-MAX(CASE WHEN pa.first_year = 1 THEN pa.avg_pay END) > 0 THEN 'Increased'
		WHEN MIN(CASE WHEN pa.last_year = 1 THEN pa.avg_pay END)-MAX(CASE WHEN pa.first_year = 1 THEN pa.avg_pay END) = 0 THEN 'No Change'
		WHEN MIN(CASE WHEN pa.last_year = 1 THEN pa.avg_pay END)-MAX(CASE WHEN pa.first_year = 1 THEN pa.avg_pay END) < 0 THEN 'Decreased'
	END AS "total_wage_trend"
FROM cte_pay_analysis AS pa
GROUP BY
	branch