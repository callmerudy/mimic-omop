 WITH admissions AS (SELECT hadm_id as visit_occurrence_id, subject_id as person_id, admittime::date as visit_start_date, admittime as visit_start_datetime, dischtime::date as visit_end_date, dischtime as visit_end_datetime, admission_type as visit_source_value, admission_location as admitting_source_value, discharge_location as discharge_to_source_value FROM mimic.admissions) 
 INSERT INTO omop.VISIT_OCCURRENCE (visit_occurrence_id, person_id, visit_start_date, visit_start_datetime, visit_end_date, visit_end_datetime, visit_source_value, admitting_source_value, discharge_to_source_value)
 SELECT admissions.visit_occurrence_id, admissions.person_id, admissions.visit_start_date, admissions.visit_start_datetime, admissions.visit_end_date, admissions.visit_end_datetime, admissions.visit_source_value, admissions.admitting_source_value, admissions.discharge_to_source_value 
FROM admissions 