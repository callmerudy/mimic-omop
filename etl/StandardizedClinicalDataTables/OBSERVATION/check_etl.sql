
-- -----------------------------------------------------------------------------
-- File created - January-9-2018
-- ----------------------------------------------------------------------------

-- --------------------------------------------------
-- Need to install pgTAP
-- http://pgtap.org/
-- --------------------------------------------------

BEGIN;
SELECT plan ( 10 );

SELECT results_eq
(
'
SELECT CAST(value_as_string AS TEXT) as religion
     , COUNT(1) 
FROM omop.observation 
WHERE observation_concept_id = 4052017
GROUP BY 1 ORDER BY 2, 1 DESC;
'

,
'
SELECT cast(religion as text), count(1) 
FROM admissions 
WHERE religion is not null 
and religion != ''OTHER'' and religion != ''NOT SPECIFIED'' and religion != ''UNOBTAINABLE''
GROUP BY 1 ORDER BY 2, 1 desc;
' 
,'-- 1. religion checker -- 4052017'
);

SELECT results_eq
(
'
SELECT CAST(value_as_string AS TEXT) as language
     , COUNT(1) 
FROM omop.observation 
WHERE observation_concept_id = 40758030
GROUP BY 1 ORDER BY 2, 1 DESC;
'

,
'
SELECT cast(language as TEXT), count(1) 
FROM admissions 
WHERE language is not null 
GROUP BY 1 ORDER BY 2, 1 desc;
' 
,'-- 2. language checker -- 40758030'
);

SELECT results_eq
(
'
SELECT CAST(value_as_string AS TEXT) as marital_status
     , COUNT(1) 
FROM omop.observation 
WHERE observation_concept_id = 40766231
GROUP BY 1 ORDER BY 2, 1 DESC;
'

,
'
SELECT CAST(marital_status AS TEXT), count(1) 
FROM admissions 
WHERE marital_status is not null 
GROUP BY 1 ORDER BY 2, 1 desc;
' 
,'-- 3. marital checker -- 40766231'
);

SELECT results_eq
(
'
SELECT CAST(value_as_string AS TEXT) as insurance
     , COUNT(1) 
FROM omop.observation 
WHERE observation_concept_id = 46235654
GROUP BY 1 ORDER BY 2, 1 DESC;
'

,
'
SELECT CAST(insurance AS TEXT), count(1) 
FROM admissions 
WHERE insurance is not null 
GROUP BY 1 ORDER BY 2, 1 desc;
' 
,'-- 4. insurance checker -- 46235654'
);


SELECT results_eq
(
'
SELECT CAST(value_as_string AS TEXT) as ethnicity
     , COUNT(1) 
FROM omop.observation 
WHERE observation_concept_id =  44803968
GROUP BY 1 ORDER BY 2, 1 DESC;
'

,
'
SELECT CAST(ethnicity AS TEXT), count(1) 
FROM admissions 
WHERE ethnicity is not null 
GROUP BY 1 ORDER BY 2, 1 desc;
' 
,'-- 5. ethnicity checker -- 44803968'
);

SELECT results_eq
(
'
select 0::integer;
'
,
'
SELECT count(1)::integer
FROM omop.observation
where observation_source_concept_id = 0;
'
,
'source concept described'
);

SELECT results_eq
(
'
select 0::integer;
'
,
'
select count(1)::integer from (
SELECT count(1)::integer
FROM omop.observation
group by observation_id
having count(1) > 1) as t;
'
,
'primary key checker'
);

SELECT results_eq
(
'
select count(1)::integer
from datetimeevents
where 
error is null OR error = 0;
'
,
'
select count(1)::integer
from omop.observation
where 4085802 = observation_concept_id ;
'
,
'datetimeevents number'
);

SELECT results_eq
(
'
select 0::integer;
'
,
'
SELECT count(1)::integer
FROM omop.observation
LEFT JOIN omop.concept ON observation_concept_id = concept_id
WHERE 
observation_concept_id != 0
AND standard_concept != ''S'';
'
,
'Standard concept checker'
);
SELECT pass( 'observation pass, w00t!' );

SELECT * FROM finish();
ROLLBACK;
