
-- -----------------------------------------------------------------------------
-- File created - January-9-2018
-- ----------------------------------------------------------------------------

-- --------------------------------------------------
-- Need to install pgTAP
-- http://pgtap.org/
-- --------------------------------------------------

BEGIN;
SELECT plan ( 5 );

SELECT results_eq
(
'
SELECT count(*) FROM admissions;
'

,
'
SELECT count(*) FROM omop.visit_occurrence;
' 
,
'Visit_occurrence table -- same number admission'
);


SELECT results_eq
(
'
SELECT cast(admission_type as TEXT) as visit_source_value, count(1) FROM admissions group by 1 ORDER BY 2,1 DESC;
'
,
'
SELECT cast (visit_source_value as TEXT), count(1) FROM omop.visit_occurrence group by 1 ORDER BY 2,1 DESC;
'
,
'Visit_occurrence table -- same distribution adm'
);


SELECT results_eq
(
'
SELECT cast(admission_location as TEXT) as admitting_source_value, count(1) FROM admissions group by 1 ORDER BY 2,1 DESC;
'
,
'
SELECT cast(admitting_source_value as TEXT), count(1) FROM omop.visit_occurrence group by 1 ORDER BY 2,1 DESC;
'
,
'Visit_occurrence table -- distribution admit source value'
);


SELECT results_eq
(
'
SELECT cast(discharge_location as TEXT) as discharge_to_source_value, count(1) FROM admissions group by 1 ORDER BY 2,1 DESC;
'
,
'
SELECT cast(discharge_to_source_value as TEXT), count(1) FROM omop.visit_occurrence group by 1 ORDER BY 2,1 DESC;
'
,
'Visit_occurrence table -- repartition discharge_to_source_value'
);


SELECT results_eq
(
'
SELECT count(visit_source_concept_id) FROM omop.visit_occurrence group by visit_source_concept_id order by 1 desc;
'
,
'
SELECT count(visit_source_value) FROM omop.visit_occurrence group by visit_source_value order by 1 desc;
'
,
'Visit_occurrence table -- links checker'
);

-- the same check with timestamp is wrong even before ETL 
SELECT results_eq
(
 '
select 0::integer;
'
,
'
WITH tmp AS
(
        SELECT visit_occurrence_id, CASE WHEN visit_end_date < visit_start_date THEN 1 ELSE 0 END AS abnormal
        FROM omop.visit_occurrence

)
SELECT max(abnormal) FROM tmp;
'
,
'Visit_occurrence table -- start_date > end_date'
);

SELECT * FROM finish();
ROLLBACK;
