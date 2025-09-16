------------------------------------------------------------------------------------------------------------------------------ 
-- Standardize Date Format

SELECT * 
FROM nashville_housing.`nashville housing data project`;

SELECT SaleDate 
FROM nashville_housing.`nashville housing data project`;

SELECT 
  SaleDate,
  STR_TO_DATE(SaleDate, '%M %e, %Y') AS ConvertedDate
FROM `nashville_housing`.`nashville housing data project`;

ALTER TABLE `nashville housing data project`
ADD COLUMN SaleDate2 DATE;

UPDATE `nashville housing data project`
SET SaleDate2 = STR_TO_DATE(SaleDate, '%M %e, %Y');

ALTER TABLE `nashville housing data project`
DROP COLUMN SaleDate_Formatted;

------------------------------------------------------------------------------------------------------------------------------ 

-- Populate Property Address data

SHOW COLUMNS FROM `nashville housing data project`;

ALTER TABLE `nashville housing data project`
CHANGE COLUMN `ï»¿UniqueID` `UniqueID` INT;

SELECT *
FROM `nashville housing data project`
-- WHERE PropertyAddress IS NULL
-- OR TRIM(PropertyAddress) = ''
-- OR PropertyAddress = 'NULL';
ORDER BY ParcelID;

UPDATE `nashville housing data project` a
JOIN `nashville housing data project` b
    ON a.ParcelID = b.ParcelID
    AND a.ï»¿UniqueID <> b.ï»¿UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL
   OR TRIM(a.PropertyAddress) = '';
   
--------------------------------------------------------------------

-- Breaking out Address into individual Columns (address, City, State)

SELECT *
FROM `nashville housing data project`;
-- WHERE PropertyAddress IS NULL
-- ORDER bY ParcelID;

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress)+1) AS Address
FROM `nashville housing data project`;

ALTER TABLE `nashville housing data project`
ADD COLUMN PropertySplitAddress VARCHAR(255),
ADD COLUMN PropertySplitCity VARCHAR(255);

UPDATE `nashville housing data project`
SET 
  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1),
  PropertySplitCity = TRIM(SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1));
  

SELECT OwnerAddress
FROM `nashville housing data project`;

SELECT
  SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerSplitAddress,
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS OwnerSplitCity,
  SUBSTRING_INDEX(OwnerAddress, ',', -1) AS OwnerSplitState
FROM `nashville housing data project`;

ALTER TABLE `nashville housing data project`
ADD COLUMN OwnerSplitAddress VARCHAR(255),
ADD COLUMN OwnerSplitCity VARCHAR(255),
ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE `nashville housing data project`
SET
	OwnerSplitAddress =  SUBSTRING_INDEX(OwnerAddress, ',', 1),
    OwnerSplitCity =   SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
    OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);
    
    
--------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM `nashville housing data project`
GROUP BY SoldAsVacant
ORDER BY 2;

UPDATE `nashville housing data project`
SET SoldAsVacant = 
	CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;
    
--------------------------------------------------------------------
-- Remove Duplicates

SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM `nashville housing data project`
) AS RowNumTable
WHERE row_num > 1;

DELETE t
FROM `nashville housing data project` t
JOIN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                ORDER BY UniqueID
            ) AS row_num
        FROM `nashville housing data project`
    ) AS RowNumTable
    WHERE row_num > 1
) dup
ON t.UniqueID = dup.UniqueID;

--------------------------------------------------------------------

-- Delete Unusued Columns

SELECT *
FROM `nashville housing data project`;

ALTER TABLE `nashville housing data project`
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

-------------------------------------------------------------------- 
