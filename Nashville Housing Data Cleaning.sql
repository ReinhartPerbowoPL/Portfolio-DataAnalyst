
select *
from PortofolioProject..NashvilleHousing

-- Standardize Date Format
select SaleDate, CONVERT(Date, SaleDate)
from PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


--------------------------------------------------------------------------
-- Populate Property Address Data

/*Check address data based on ParcelID*/
select *
from PortofolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

/*Check Query to prepare populating Address based on ParcelID*/
select 
	a.ParcelID, 
	a.PropertyAddress, 
	b.ParcelID, 
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
order by 1

/*Update the Address*/
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortofolioProject..NashvilleHousing a
JOIN PortofolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------
-- Breaking out Address info to columns (Address, City, State)

-- Property Address
select PropertyAddress
from PortofolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

/* Process to break the address into its intended column */

-- Property Address
Select
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortofolioProject.dbo.NashvilleHousing

/*make new column for the splitted address*/

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = LTRIM(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)))


-- Owner Address

select 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
from PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = LTRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2))

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = LTRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1))

SELECT *
FROM PortofolioProject..NashvilleHousing


--------------------------------------------------------------------------
-- Change Y and N to Yes and no in "Sold as Vacant" field

/* checking total anomalies (value of N and Y) */
select distinct (SoldAsVacant), count(soldasvacant)
from PortofolioProject..NashvilleHousing
group by SoldAsVacant
Order by 2

/* using CASE WHEN to change Y/N to Yes/No */
select 
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
from PortofolioProject..NashvilleHousing

/* Update the column with new values */
Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				   END


				   --------------------------------------------------------------------------
-- Remove Duplicates

/* ROW_NUMBER() are used to define duplicate rows */
WITH RowNumCTE AS (
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num
from PortofolioProject..NashvilleHousing
)
DELETE FROM RowNumCTE
where row_num > 1


--------------------------------------------------------------------------
-- Remove Unused Columns

select *
from PortofolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress