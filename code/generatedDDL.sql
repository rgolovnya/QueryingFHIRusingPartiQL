#  the generated DDL creating external table on redshift cluster

create external table fhir.Claims(
	"resourceType" varchar(6),
	"id" varchar(43),
	"status" varchar(7),
	"use" varchar(9),
	"patient" struct<"reference": varchar(52)>,
	"billablePeriod" struct<"start": varchar(30),"end": varchar(30)>,
	"organization" struct<"reference": varchar(58)>,
	"diagnosis" array<struct<"sequence": double precision,"diagnosisReference": struct<"reference": varchar(55)>>>,
	"item" array<struct<"sequence": double precision,"encounter": array<varchar(55)>,"diagnosisLinkId": array<double precision>,"informationLinkId": array<double precision>,"net": struct<"value": double precision,"system": varchar(24),"code": varchar(3)>,"procedureLinkId": array<double precision>>>,
	"total" struct<"value": double precision,"system": varchar(24),"code": varchar(3)>,
	"information" array<struct<"sequence": double precision,"category": struct<"coding": array<struct<"system": varchar(52),"code": varchar(4)>>>,"valueReference": struct<"reference": varchar(58)>>>,
	"procedure" array<struct<"sequence": double precision,"procedureReference": struct<"reference": varchar(55)>>>,
	"prescription" struct<"reference": varchar(64)>
)
row format serde 'org.openx.data.jsonserde.JsonSerDe'
with serdeproperties ('dots.in.keys' = 'true','mapping.requesttime' = 'requesttimestamp','strip.outer.array' = 'true')
location 's3://demo-partiql-zutfcihjex/fhir/claims'
;

## Querying External Table

SELECT c.id,c.status,c.patient.reference as patient_ref,SPLIT_PART(c.patient.reference,’/’,2) as patient_key,
d.sequence as diag_seq,d.diagnosisReference.reference as diag_ref
FROM fhir.Claims as c, c.diagnosis as d
WHERE c.status = ‘active’


SELECT c.status,count(*) as cnt, sum(c.total.value) as total
FROM fhir.Claims as c
GROUP BY c.status,c.patient.reference
