CREATE TABLE IF NOT EXISTS data_academy_content.t_livia_crhova_project_SQL_primary_final AS
WITH cte_pay AS (
	SELECT 
		payroll_year AS year,
		CONCAT(cpib.name,'-',cpc.name) AS branch,
		ROUND(AVG(value)::NUMERIC,2) AS "avg_pay"
	FROM data_academy_content.czechia_payroll cp
	JOIN data_academy_content.czechia_payroll_industry_branch cpib 
		ON cp.industry_branch_code=cpib.code
	JOIN data_academy_content.czechia_payroll_calculation cpc 
		ON cp.calculation_code=cpc.code
	WHERE value_type_code = 5958				--kód 5958 = průměrná hrubá mzda
	GROUP BY 
		cpc.name
		,cpib.name
		,payroll_year
),
cte_price AS (
	SELECT 
		EXTRACT(YEAR FROM cp.date_from) AS YEAR
		,cpc."name" AS "foodstuff"
		,value AS "avg_price"
	FROM data_academy_content.czechia_price cp 
	JOIN data_academy_content.czechia_price_category cpc 
		ON cp.category_code = cpc.code 
	WHERE
		region_code IS NULL						--záznam s region_code NULL je průměrnou hodnotou za všechny regiony v daném časovém úseku za danou potravinu
		AND cpc."name" <> 'Jakostní víno bílé'	--nutnost vyloučit tuto položku pro zajištění konzistentnosti dat pro meziroční srovnávání
)
SELECT 
	cte_pay.year,
	cte_pay."branch",
	cte_pay."avg_pay",
	cte_price."foodstuff",
	cte_price."avg_price"
FROM cte_pay
JOIN cte_price 
	ON cte_pay.year = cte_price.year  


