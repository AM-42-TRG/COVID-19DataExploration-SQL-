/*
Video URL: https://youtu.be/8rO7ztF4NtU

Topic: Data Cleaning
*/

SELECT *
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------

-- Standardise Date Format

/*
SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)
*/

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted
FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data (NULL values)

SELECT PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

-- Doing a self-join:
SELECT a.ParcelID, a.[UniqueID ], a.PropertyAddress, b.ParcelID, b.[UniqueID ], b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Updating the table according to the join
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------------------------

-- Dividing Property Address into individual columns (Address, City)

-- SUBSTRING(column, starting_position_in_string, ending_position_in_string)
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

-- Creating two new columns for the Address and City
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


--------------------------------------------------------------------------------------------------------------------------------------------

-- Dividing Owner Address into individual columns (Address, City, State)

SELECT *
FROM NashvilleHousing

-- Defining the functions
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

-- Adding the Owner Address column
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

-- Adding the Owner City column
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

-- Adding the Owner State column
ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in Sold as Vacant field:

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


--------------------------------------------------------------------------------------------------------------------------------------------

-- Remove duplicates (apparantly not usually done in SQL...):
-- RANK & DENSERANK could also be used

-- Selecting all duplicates
/*
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num
FROM NashvilleHousing
-- ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
*/

-- Deleting all duplicates
/*
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num
FROM NashvilleHousing
-- ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress
*/

-- Checking if all duplicates have been deleted
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



--------------------------------------------------------------------------------------------------------------------------------------------
-- Deleting unused columns:

-- This is actually more applicable to deleting Views, because one typically does NOT delete columns in a database...

/*
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
*/

--------------------------------------------------------------------------------------------------------------------------------------------
--

SELECT [UniqueID ], ParcelID, LandUse, PropertySplitAddress, PropertySplitCity, SaleDateConverted, SalePrice, LegalReference,
SoldAsVacant, OwnerName, OwnerSplitAddress, OwnerSplitCity, Acreage, TaxDistrict, LandValue, BuildingValue, TotalValue,
YearBuilt, Bedrooms, FullBath, HalfBath
FROM NashvilleHousing

SELECT SalePrice, Acreage, (SalePrice/Acreage) AS DollarsPerAcre, PropertyAddress
FROM NashvilleHousing
WHERE Acreage IS NOT NULL
ORDER BY DollarsPerAcre

SELECT PropertySplitCity, AVG(SalePrice) AS AvgSalePrice
FROM NashvilleHousing
GROUP BY PropertySplitCity
ORDER BY AvgSalePrice

-- Checking distinct types of land use:
SELECT DISTINCT LandUse
FROM NashvilleHousing
GROUP BY LandUse
ORDER BY LandUse

-- Checking average price according to land use
SELECT LandUse, AVG(SalePrice) AS AvgSalePrice
FROM NashvilleHousing
GROUP BY LandUse
ORDER BY LandUse

-- Comparing SalePrice, LandValue, BuildingValue and TotalValue:
SELECT SalePrice, LandValue, BuildingValue, TotalValue
FROM NashvilleHousing
WHERE LandValue IS NOT NULL
	AND BuildingValue IS NOT NULL
	AND TotalValue IS NOT NULL

-- Comparing TotalValue and SalePrice:
SELECT TotalValue, SalePrice, (SalePrice-TotalValue)/SalePrice*100 AS PercentageIncrease
FROM NashvilleHousing
WHERE TotalValue IS NOT NULL
ORDER BY PercentageIncrease DESC

-- Comparing YearBuilt with Acreage:
SELECT YearBuilt, AVG(Acreage) AS AvgAcreage
FROM NashvilleHousing
WHERE Acreage IS NOT NULL
	AND YearBuilt IS NOT NULL
GROUP BY YearBuilt
ORDER BY YearBuilt

-- Comparing YearBuilt with average SalePrice:

-- Loooking at specific houses according to YearBuilt
SELECT *
FROM NashvilleHousing
WHERE YearBuilt = 1905
ORDER BY SalePrice

-- Comparing SalePrice and number of Bedrooms/Bathrooms
SELECT Bedrooms, ROUND(AVG(SalePrice),2) AS AvgSalePrice
FROM NashvilleHousing
WHERE Bedrooms IS NOT NULL
	AND Bedrooms > 0
GROUP BY Bedrooms
ORDER BY AvgSalePrice ASC

--------------------------------------------------------------------------------------------------------------------------------------------
-- Additional Practice
-----------------------

SELECT *
FROM NashvilleHousing -- 56,373 rows

-- Checking which of the IDs is the unique row identifier:
SELECT 
	COUNT(DISTINCT([UniqueID ])) AS DistinctUniqueIDs, 
	COUNT(DISTINCT(ParcelID)) AS DistinctParcelIDs
FROM NashvilleHousing

SELECT 
	SoldAsVacant,
	COUNT([UniqueID ]) AS UniqueIDs
FROM NashvilleHousing
WHERE YEAR(SaleDate) = 2014
GROUP BY SoldAsVacant

--SELECT 4669 + 51704

-- Checking SoldAsVacant: Yes vs No
SELECT 
	SoldAsVacant,
	COUNT([UniqueID ]) AS UniqueIDs
FROM 
	NashvilleHousing
WHERE 
	YEAR(SaleDate) = 2014
GROUP BY 
	SoldAsVacant

-- Checking SoldAsVacant: Yes vs No + change text displayed
SELECT 
	CASE SoldAsVacant
		WHEN 'Yes' THEN 'SoldAsVacant'
		WHEN 'No' THEN 'NotSoldAsVacant'
		ELSE 'Unknown'
	END AS SoldAsVacant,
	COUNT([UniqueID ]) AS UniqueIDs
FROM 
	NashvilleHousing
WHERE 
	YEAR(SaleDate) = 2014
GROUP BY 
	SoldAsVacant