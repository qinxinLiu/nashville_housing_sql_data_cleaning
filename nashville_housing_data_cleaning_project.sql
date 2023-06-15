-- 0. Create Table
CREATE TABLE nashville_housing(
	unique_id varchar(10),
	parcel_id varchar(50),
	Land_Use	varchar(50),
	Property_Address varchar(50),
	Sale_Date date,
	Sale_Price	INT,
	Legal_Reference	varchar(50),
	Sold_As_Vacant varchar(10),
	Owner_Name varchar(50),
	Owner_Address varchar(50),
	Acreage	Numeric(10,3),
	Tax_District varchar(50),
	Land_Value	int,
	Building_Value int,
	Total_Value	int,
	Year_Built int,
	Bedrooms smallint,
	Full_Bath smallint,
	Half_Bath smallint
);

--1. Populate Property Address Data (Null)
SELECT *
FROM nashville_housing
--WHERE property_address IS NULL
ORDER BY 2;

SELECT a.parcel_id, a.property_address, b.parcel_id, b.property_address, COALESCE( b.property_address, a.property_address)
FROM nashville_housing a
INNER JOIN  nashville_housing B
ON a.parcel_id = b.parcel_id
AND a.unique_id != b.unique_id
WHERE b.property_address IS NULL;

UPDATE nashville_housing
SET property_address = COALESCE( b.property_address, a.property_address)
FROM nashville_housing a
INNER JOIN  nashville_housing B
ON a.parcel_id = b.parcel_id
AND a.unique_id != b.unique_id
WHERE b.property_address IS NULL


SELECT COUNT(*)
FROM nashville_housing
WHERE property_address IS NULL;


--2. Breaking out Address into Individual Columns (Address, City, State)

--(a) Method 1: Left(), Right()
SELECT
LEFT(property_address,POSITION(',' IN property_address)-1) AS address
,RIGHT(property_address, LENGTH(property_address)-POSITION(',' IN property_address)) AS city
FROM nashville_housing;

--(b) Method 2: Substring()
SELECT
SUBSTRING(property_address FROM 1 FOR POSITION(',' IN property_addresS )-1)  AS address
,SUBSTRING(property_address FROM POSITION(',' IN property_addresS )+1)  AS city
FROM nashville_housing

ALTER TABLE nashville_housing
ADD COLUMN property_split_address VARCHAR(255)
,ADD COLUMN property_split_city VARCHAR(255);

UPDATE nashville_housing
SET property_split_address = SUBSTRING(property_address FROM 1 FOR POSITION(',' IN property_addresS )-1);

UPDATE nashville_housing
SET property_split_city = SUBSTRING(property_address FROM POSITION(',' IN property_addresS )+1);

SELECT 
SPLIT_PART(owner_address, ',',1) AS street
,SPLIT_PART(owner_address, ',',2) AS city
,SPLIT_PART(owner_address, ',',3) AS state
FROM nashville_housing

ALTER TABLE nashville_housing
ADD COLUMN owner_split_address VARCHAR(255)
,ADD COLUMN owner_split_city VARCHAR(255)
,ADD COLUMN owner_split_state VARCHAR(255);

UPDATE nashville_housing
SET owner_split_address =SPLIT_PART(owner_address, ',',1);
UPDATE nashville_housing
SET owner_split_city = SPLIT_PART(owner_address, ',',2);
UPDATE nashville_housing
SET owner_split_state =SPLIT_PART(owner_address, ',',3);


SELECT * FROM nashville_housing;


--3. Changing Y and N to Yes and No in "Sold as Vacant" field
SELECT sold_as_vacant
,CASE WHEN sold_as_vacant = 'Y' THEN 'YES'
WHEN sold_as_vacant = 'N' THEN 'NO'
ELSE sold_as_vacant
END
FROM nashville_housing

UPDATE nashville_housing
SET sold_as_vacant =
(CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
WHEN sold_as_vacant = 'N' THEN 'N0'
ELSE sold_as_vacant
END
)


--4.Removing duplicants (Postgresql does not allow using DELETE() with CTE)
WITH row_num_cte AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY parcel_id,
				 property_address,
				 sale_price,
				 sale_date,
				 legal_reference
				 ORDER BY unique_id) row_num
FROM nashville_housing
)

DELETE 
FROM nashville_housing
WHERE unique_id in (SELECT unique_id FROM row_num_cte)

-- 5. Deleting unused columns
ALTER TABLE nashville_housing
DROP COLUMN owner_address
,DROP COLUMN tax_district 
,DROP COLUMN property_address












