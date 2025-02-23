CREATE TABLE IF NOT EXISTS data_academy_content.t_livia_crhova_project_SQL_secondary_final AS
WITH cte_min_year AS (
	SELECT
		MIN(cpay."payroll_year") AS min_year
	FROM data_academy_content.czechia_payroll cpay
	JOIN data_academy_content.czechia_price cprice
		ON cpay."payroll_year" = EXTRACT(YEAR FROM cprice.date_from)
),
cte_max_year AS (
	SELECT
		MAX(cpay."payroll_year") AS max_year
	FROM data_academy_content.czechia_payroll cpay
	JOIN data_academy_content.czechia_price cprice
		ON cpay."payroll_year" = EXTRACT(YEAR FROM cprice.date_from)
),
cte_european_countries AS (
	SELECT
		country
	FROM data_academy_content.countries
	WHERE
		continent = 'Europe'
)
SELECT 
	e.country
	,e.year
	,e.gdp
	,e.gini
	,population
FROM data_academy_content.economies AS e 
JOIN cte_european_countries AS ec
	ON e.country = ec.country
WHERE
	e.year BETWEEN (SELECT min_year FROM cte_min_year) AND (SELECT max_year FROM cte_max_year)

