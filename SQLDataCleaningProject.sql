/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM SQLDataCleaning..NashvilleHousing;


-- To standardize date format
SELECT SaleDate, CONVERT(date, SaleDate)
FROM SQLDataCleaning..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD ConvertedSaleDate date;

UPDATE NashvilleHousing
SET ConvertedSaleDate = CONVERT(date, SaleDate)

SELECT ConvertedSaleDate
FROM SQLDataCleaning..NashvilleHousing;


-- To populate Property Address data
SELECT PropertyAddress
FROM SQLDataCleaning..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT na.ParcelID, na.PropertyAddress, ns.ParcelID, ns.PropertyAddress, ISNULL(na.PropertyAddress, ns.PropertyAddress)
FROM SQLDataCleaning..NashvilleHousing na
JOIN SQLDataCleaning..NashvilleHousing ns
	ON na.ParcelID = ns.ParcelID
	AND na.[UniqueID ] <> ns.[UniqueID ]
WHERE na.PropertyAddress IS NULL;

UPDATE na
SET PropertyAddress = ISNULL(na.PropertyAddress, ns.PropertyAddress)
FROM SQLDataCleaning..NashvilleHousing na
JOIN SQLDataCleaning..NashvilleHousing ns
	ON na.ParcelID = ns.ParcelID
	AND na.[UniqueID ] <> ns.[UniqueID ]
WHERE na.PropertyAddress IS NULL;

SELECT na.ParcelID, na.PropertyAddress, ns.ParcelID, ns.PropertyAddress
FROM SQLDataCleaning..NashvilleHousing na
JOIN SQLDataCleaning..NashvilleHousing ns
	ON na.ParcelID = ns.ParcelID
	AND na.[UniqueID ] <> ns.[UniqueID ];


-- To break out Property Address into individual columns (Address, City, State)
SELECT PropertyAddress
FROM SQLDataCleaning..NashvilleHousing

-- using a substring
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) as Address
FROM SQLDataCleaning..NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD PropertyAddressSplit nvarchar(255)

UPDATE NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
ADD PropertyCitySplit nvarchar(255)

UPDATE NashvilleHousing
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))


SELECT PropertyAddress, PropertyAddressSplit, PropertyCitySplit
FROM SQLDataCleaning..NashvilleHousing;


-- To break out Owner Address into individual columns (Address, City, State) using a simpler method: ParseName
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM SQLDataCleaning..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerAddressSplit nvarchar(255)

UPDATE NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerCitySplit nvarchar(255)

UPDATE NashvilleHousing
SET OwnerCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerStateSplit nvarchar(255)

UPDATE NashvilleHousing
SET OwnerStateSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT OwnerAddressSplit, OwnerCitySplit, OwnerStateSplit
FROM SQLDataCleaning..NashvilleHousing;



-- Changing Y and N to 'Yes' and 'No' in 'Sold as Vacant' field
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM SQLDataCleaning..NashvilleHousing
Group by SoldAsVacant
Order by 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM SQLDataCleaning..NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;


-- To remove duplicates
WITH RowNum AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM SQLDataCleaning..NashvilleHousing
)
DELETE
FROM RowNum
WHERE row_num > 1;



-- To delete unused columns
SELECT *
FROM SQLDataCleaning..NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

