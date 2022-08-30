/*
	Data Cleaning
*/

Select * 
FROM DAProjct.dbo.NashvilleHousing


-- Standardize Date Format

Select SaleDate--, CONVERT(Date, SaleDate)
FROM DAProjct.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


 -- OR 
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property Address Data

Select PropertyAddress
FROM DAProjct.dbo.NashvilleHousing
--WHERE PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DAProjct.dbo.NashvilleHousing a
JOIN DAProjct.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DAProjct.dbo.NashvilleHousing a
JOIN DAProjct.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


-- Destructuring address into city, street etc.

-- Address of the Property

SELECT PropertyAddress
FROM DAProjct.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress))-1) AS Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress))+1, LEN(PropertyAddress)) AS City
FROM DAProjct.dbo.NashvilleHousing

-- Address
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress))-1);

-- City
ALTER TABLE NashvilleHousing
ADD PropertyCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress))+1, LEN(PropertyAddress));

SELECT * 
FROM DAProjct.dbo.NashvilleHousing

-- Address of the Owner

SELECT OwnerAddress
FROM DAProjct.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),  3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),  2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),  1)
FROM DAProjct.dbo.NashvilleHousing

-- 3 - Address

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),  3);

-- 2 - City

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),  2);

-- 1 - State

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),  1);


SELECT *
FROM DAProjct.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DAProjct.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END
FROM DAProjct.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = (
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
	END
)

-- Remove Duplicates

-- CTE

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
	) row_num
FROM DAProjct.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Deleting Unused Columns

SELECT *
FROM DAProjct.dbo.NashvilleHousing

ALTER TABLE DAProjct.dbo.NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress






