-- 1. A. Which prescriber had the highest total number of claims (totaled over all drugs)? 
------ Report the npi and the total number of claims.
--NPI# 1881634483  Total Claims 99707

SELECT *
FROM prescription;

SELECT npi, SUM(total_claim_count) AS total_claims
FROM prescription
GROUP BY npi
ORDER BY total_claims DESC;

-------------------------------------
-- 1. B. Repeat the above, but this time report the nppes_provider_first_name, 
--nppes_provider_last_org_name,  
--specialty_description, and the total number of claims.
--Total Claims 99707 By BRUCE PENDLEY, Family Practice

SELECT prescription.npi, SUM(total_claim_count) AS total_claims,
nppes_provider_last_org_name AS last_name, nppes_provider_first_name AS first_name,
prescriber.specialty_description AS practice
FROM prescription INNER JOIN prescriber ON prescription.npi = prescriber.npi
GROUP BY prescription.npi, last_name, first_name, practice
ORDER BY total_claims DESC;


--2. A. Which specialty had the most total number of claims (totaled over all drugs)?
-----A. Family Practice 9752347

SELECT prescriber.specialty_description, SUM(total_claim_count) AS TCC
FROM prescription 
INNER JOIN prescriber ON prescriber.npi = prescription.npi
GROUP BY prescriber.specialty_description
ORDER BY TCC DESC;


-----B. Which specialty had the most total number of claims for opioids?
-----B. Nurse Practitioner 900845

SELECT drug.opioid_drug_flag AS opioid, prescriber.specialty_description AS specialty, SUM(total_claim_count) AS total_claims
FROM drug
INNER JOIN prescription
USING(drug_name)
INNER JOIN prescriber
ON prescription.npi = prescriber.npi
WHERE opioid_drug_flag = 'Y'
GROUP BY opioid, specialty
ORDER BY total_claims DESC;


--C. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT DISTINCT(specialty_description) AS SD, drug_name
FROM prescriber
FULL JOIN prescription USING(npi)
FULL JOIN drug USING(drug_name)
GROUP BY SD, drug_name
ORDER BY SD;

SELECT SUM(total_claim_count) AS TCC, drug_name, specialty_description
FROM prescription FULL JOIN prescriber USING(npi)
WHERE drug_name IS NULL
GROUP BY drug_name, specialty_description
ORDER BY TCC DESC;
---except, set theory
-----------------------------------------------------------------------------------------

--3. A. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, SUM(total_drug_cost) AS TDC
FROM drug
INNER JOIN prescription USING(drug_name)
GROUP BY generic_name
ORDER BY TDC DESC;

---B. Which drug (generic_name) has the hightest total cost per day? 
--**Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, SUM(total_drug_cost/365.25)::money AS cost_day
FROM drug
INNER JOIN prescription USING(drug_name)
GROUP BY generic_name
ORDER BY cost_day DESC;

---4. A. For each drug in the drug table, return the drug name and 
--then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', 
--says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and 
--says 'neither' for all other drugs.


SELECT drug_name,
		CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
			 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			 ELSE 'Neither' END AS drug_type
FROM drug
ORDER BY drug_type;


--B. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. 
--Hint: Format the total costs as MONEY for easier comparision.

SELECT
			(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
			 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			 ELSE 'Neither' END) AS drug_type,
			  SUM(total_drug_cost)::money AS tdc

FROM drug INNER JOIN prescription USING(drug_name)
GROUP BY drug_type
ORDER BY tdc DESC;


--5. A. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT DISTINCT cbsa, cbsaname
FROM cbsa
WHERE cbsaname LIKE '%TN%';

-------------------------------------------

--B. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
--LARGEST: Nashville-Davidson--Murfreesboro--Franklin, TN, 1,830,410
--SMALLEST: Morristown, TN, 116,352

SELECT cbsaname, SUM(population) AS total_pop
FROM cbsa INNER JOIN fips_county USING(fipscounty)
		  INNER JOIN population USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_pop DESC;


SELECT cbsaname, SUM(population) AS total_pop
FROM cbsa INNER JOIN fips_county USING(fipscounty)
		  INNER JOIN population USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_pop ASC;


--C. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
-- SHELBY, #47157, population 937847

SELECT county, fipscounty, population
FROM population INNER JOIN fips_county USING(fipscounty)
ORDER BY population DESC;

SELECT *
FROM cbsa
ORDER BY cbsa DESC;


--6. A. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.


SELECT drug_name, total_claim_count 
FROM prescription
WHERE total_claim_count >= 3000;


--B. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

WITH tcc AS (SELECT *
				  FROM prescription
	  			  WHERE total_claim_count >= 3000)
	  
SELECT	drug_name,
			(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
			 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			 ELSE 'Neither' END) AS drug_type
			 
FROM tcc INNER JOIN drug USING(drug_name)
ORDER BY drug_name;


--C. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.


WITH tcc AS (SELECT *
				  FROM prescription
	  			  WHERE total_claim_count >= 3000)
	  
SELECT	nppes_provider_first_name, nppes_provider_last_org_name, drug_name,
			(CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
			 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
			 ELSE 'Neither' END) AS drug_type
			 
FROM tcc INNER JOIN drug USING(drug_name)
		 INNER JOIN prescriber USING(npi)
ORDER BY drug_name;

--7 A cross join
--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. 
-----**Hint:** The results from all 3 parts will have 637 rows.


SELECT drug_name, total_claim_count, specialty_description

FROM prescriber INNER JOIN prescription USING(npi)
				INNER JOIN drug USING(drug_name)
WHERE specialty_description ILIKE 'Pain Management'
ORDER BY total_claim_count;

--a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), 
--where the drug is an opioid (opioid_drug_flag = 'Y'). 
--**Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.


SELECT npi, specialty_description, nppes_provider_city, opioid_drug_flag
FROM prescriber CROSS JOIN drug
WHERE nppes_provider_city = 'NASHVILLE' AND specialty_description = 'Pain Management'
										AND opioid_drug_flag = 'Y';


--B. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. 
-----You should report the npi, the drug name, and the number of claims (total_claim_count).
									

SELECT prescriber.npi, drug_name, total_claim_count
FROM prescriber CROSS JOIN drug
				LEFT JOIN prescription USING(drug_name, npi)
WHERE nppes_provider_city ILIKE 'NASHVILLE' AND specialty_description ILIKE 'Pain Management'
											AND opioid_drug_flag = 'Y'
ORDER BY total_claim_count DESC;


--C. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.


SELECT prescriber.npi, drug_name, 
COALESCE (total_claim_count, 0)
FROM prescriber CROSS JOIN drug
				LEFT JOIN prescription USING(drug_name, npi)
WHERE nppes_provider_city ILIKE 'NASHVILLE' AND specialty_description ILIKE 'Pain Management'
											AND opioid_drug_flag = 'Y'
ORDER BY total_claim_count DESC;












