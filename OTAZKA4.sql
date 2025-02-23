--4.Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH cte_yearly_changes AS(	
	SELECT 
		year
		,AVG("avg_pay") AS "avg_pay"								-- Průměrná mzda pro daný rok a kategorii
		,LAG(AVG("avg_pay")) OVER (ORDER BY year) AS prev_pay		-- Průměrná mzda pro předchozí rok a kategorii
		,AVG("avg_price") AS "avg_price"							-- Průměrná cena potravin pro daný rok
		,LAG(AVG("avg_price")) OVER (ORDER BY year) AS prev_price	-- Průměrná cena potravin pro předchozí rok
	FROM 
		data_academy_content.t_livia_crhova_project_sql_primary_final AS primary_table 
	WHERE
		branch LIKE '%fyzický%'								-- možnost změnit 'fyzický' na 'přepočtený' pro přepočet průměrné mzdy na FTE místo fyzických osob
	GROUP BY
		YEAR
)
SELECT 
	YEAR
	,ROUND(((avg_pay - prev_pay)/prev_pay *100)::NUMERIC, 2) AS percentage_pay_growth
	,ROUND(((avg_price -prev_price)/prev_price *100)::NUMERIC, 2) AS percentage_price_growth
	,CASE
		WHEN ROUND(((avg_price -prev_price)/prev_price *100)::NUMERIC, 2)>ROUND((avg_pay - prev_pay)/prev_pay *100::NUMERIC, 2) THEN ROUND(((avg_price -prev_price)/prev_price *100)::NUMERIC, 2)-ROUND((avg_pay - prev_pay)/prev_pay *100::NUMERIC, 2)
	END AS price_growth_higher_than_pay_growth_by
FROM 
	cte_yearly_changes
WHERE
	prev_price IS NOT NULL AND prev_pay IS NOT NULL					 -- Nezahrneme první rok, protože nemáme data z předchozího roku pro porovnání