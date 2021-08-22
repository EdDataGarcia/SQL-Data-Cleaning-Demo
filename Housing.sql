/*
Cleaning Housing Data using SQL Queries
Ed Garcia
August 21, 2021
*/

--Initial Exploration of Data
SELECT	*
FROM PortfolioProject..NashvilleHousing



--Standardize Date Format by Removing Extraneous '0' Time Digits
SELECT	SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing
	
	--Alter the table with this solution
ALTER TABLE		NashvilleHousing
ALTER COLUMN	SaleDate Date
	--Make sure the table updated correctly
SELECT	SaleDate
FROM PortfolioProject..NashvilleHousing



--Populate Property Address Data
SELECT	PropertyAddress
FROM	PortfolioProject..NashvilleHousing
WHERE	PropertyAddress IS NULL

SELECT	*
FROM	PortfolioProject..NashvilleHousing
ORDER BY ParcelID --ParcelID is an identifier that matches each distinct PropertyAddress 

SELECT	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM	PortfolioProject..NashvilleHousing a
JOIN	PortfolioProject..NashvilleHousing b
	ON	a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE	a.PropertyAddress IS NULL

UPDATE	a
SET		PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)	
FROM	PortfolioProject..NashvilleHousing a
JOIN	PortfolioProject..NashvilleHousing b
	ON	a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE	a.PropertyAddress IS NULL



--Splitting Property Address into Individual Columns (Address, City) Using SUBSTRING
SELECT	PropertyAddress	-- notice that the property address contains the address and city with a comma delimiter
FROM	PortfolioProject..NashvilleHousing

	--Draft a solution to eliminate comma and split property address and city strings
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM	PortfolioProject..NashvilleHousing

	--Implement the solution
ALTER TABLE	PortfolioProject..NashvilleHousing
		ADD	PropertySplitAddress Nvarchar(255)

ALTER TABLE	PortfolioProject..NashvilleHousing
		ADD	PropertySplitCity Nvarchar(255)

UPDATE	PortfolioProject..NashvilleHousing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE	PortfolioProject..NashvilleHousing
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

	--Make sure the columns were added and populated successfully
SELECT	*
FROM PortfolioProject..NashvilleHousing



--Splitting OwnerAddress into Individual Columns (Address, City, State) using PARSENAME
SELECT	OwnerAddress	-- notice that the owner address contains the address, city, and state with comma delimiters
FROM	PortfolioProject..NashvilleHousing

	--Draft the solution
SELECT	
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM	PortfolioProject..NashvilleHousing

	--Implement the solution
ALTER TABLE	PortfolioProject..NashvilleHousing
		ADD	OwnerSplitAddress Nvarchar(255)

ALTER TABLE	PortfolioProject..NashvilleHousing
		ADD	OwnerSplitCity Nvarchar(255)

ALTER TABLE	PortfolioProject..NashvilleHousing
		ADD	OwnerSplitState Nvarchar(255)

UPDATE	PortfolioProject..NashvilleHousing
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE	PortfolioProject..NashvilleHousing
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE	PortfolioProject..NashvilleHousing
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

	--Test the solution
SELECT	*
FROM PortfolioProject..NashvilleHousing



--Change Y and N to Yes and No in "Sold as Vacant" Field
SELECT	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM	PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 --there is Y, N, Yes, and No listed, but most entries use Yes/No

	--Draft the solution
SELECT	SoldAsVacant,
   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM	PortfolioProject..NashvilleHousing

	--Implement the solution
UPDATE	PortfolioProject..NashvilleHousing
	SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
							WHEN SoldAsVacant = 'N' THEN 'No'
							ELSE SoldAsVacant
							END

	--Test the solution
SELECT	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM	PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



--Remove Duplicate Rows Using Windows Function within a CTE
WITH	RowNumCTE AS 
(
	SELECT	*,
		ROW_NUMBER() OVER (
		PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
			ORDER BY	UniqueID
							) row_num
	FROM PortfolioProject..NashvilleHousing
)
SELECT	*
FROM	RowNumCTE
WHERE	row_num > 1 --any value >1 in the col row_num is a duplicate row
ORDER BY PropertyAddress

	--Implement the solution
WITH	RowNumCTE AS 
(
	SELECT	*,
		ROW_NUMBER() OVER (
		PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
			ORDER BY	UniqueID
							) row_num
	FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM	RowNumCTE
WHERE	row_num > 1 --any value >1 in the col row_num is a duplicate row

	--Test the solution (this should return 0 rows)
WITH	RowNumCTE AS 
(
	SELECT	*,
		ROW_NUMBER() OVER (
		PARTITION BY	ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
			ORDER BY	UniqueID
							) row_num
	FROM PortfolioProject..NashvilleHousing
)
SELECT	*
FROM	RowNumCTE
WHERE	row_num > 1 
ORDER BY PropertyAddress



--Delete Irrelevant Columns
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress

--Test the solution
SELECT	*
FROM	PortfolioProject..NashvilleHousing
