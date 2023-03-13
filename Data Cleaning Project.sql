/*

Data Cleaning Project in SSMS (T-SQL)

*/

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------

--Changing SaleDate to a different Format

--SELECT SaleDate, CONVERT(date, SaleDate)					--
--FROM DataCleaningProject.dbo.NashvilleHousing					--
										-- Would not Update
--UPDATE DataCleaningProject.dbo.NashvilleHousing				--
--SET SaleDate = CONVERT(date, SaleDate)					--

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing				-- Adds new column and
ADD SalesDateConverted Date;							-- updates new new column with desired
										-- date format
UPDATE DataCleaningProject.dbo.NashvilleHousing					-- 
SET SalesDateConverted = CONVERT(date, SaleDate)				-- 


------------------------------------------------------------------------------------------------------------

-- Populating the NULLS in the PropertyAddress Column

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY  ParcelID



SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleHousing AS a
JOIN DataCleaningProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject.dbo.NashvilleHousing AS a
JOIN DataCleaningProject.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------------------------------------------------------------------------------------------------------------

----Dividing Addresses into individual Columns (Address, City, State)
--PropertyAddress

SELECT PropertyAddress
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City

FROM DataCleaningProject.dbo.NashvilleHousing


--Making New Columns
--PropertyAddress

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

--PropertyCity

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--OwnerAddress

SELECT OwnerAddress
FROM DataCleaningProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS  Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM DataCleaningProject.dbo.NashvilleHousing

--OWNER'S ADDRESS

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--OWNER'S CITY

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--OWNER'S STATE

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


------------------------------------------------------------------------------------------------------------

-- Changing Y and N to Yes and No. (Data contains all 4 of these hence changing it so they are all the same)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant

END AS CorrectlyConvertedYesNo


FROM DataCleaningProject.dbo.NashvilleHousing

UPDATE DataCleaningProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
END 


------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				) AS row_num

FROM DataCleaningProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM DataCleaningProject.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------------











-- Deleting Unused Columns

SELECT * 
FROM DataCleaningProject.dbo.NashvilleHousing

ALTER TABLE DataCleaningProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress,
			OwnerAddress,
			TaxDistrict,
			SaleDate
