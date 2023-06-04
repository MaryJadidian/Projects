
--Cleaning data in SQL Queries

SELECT * FROM ProjectCovid..NashvilleHousing

--Standardize Data Format

SELECT SaleDate, CONVERT(Date, SaleDate) FROM ProjectCovid..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate) FROM ProjectCovid..NashvilleHousing

--Populate Property Adress Data

SELECT * FROM ProjectCovid..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, B.ParcelID, A.PropertyAddress, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) 
FROM ProjectCovid..NashvilleHousing AS A
JOIN ProjectCovid..NashvilleHousing AS B
    ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM ProjectCovid..NashvilleHousing AS A
JOIN ProjectCovid..NashvilleHousing AS B
    ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--Breaking out Address into Individual Column (Address, City, State)

SELECT PropertyAddress FROM ProjectCovid..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS
FROM ProjectCovid.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT * FROM ProjectCovid.dbo.NashvilleHousing

SELECT OwnerAddress FROM ProjectCovid.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)  AS State
FROM ProjectCovid.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT * FROM ProjectCovid.dbo.NashvilleHousing


-- Cahge Y and N to YES and No is "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant) 
FROM ProjectCovid.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM ProjectCovid.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
	 	 	 	 	
--Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
      ROW_NUMBER() OVER (
	  PARTITION BY ParcelID,
	  PropertyAddress,
	  SalePrice,
	  SaleDate,
	  LegalReference
	  ORDER BY UniqueID) row_num
FROM ProjectCovid.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


SELECT *
FROM ProjectCovid.dbo.NashvilleHousing


--Delete Unused Columns

SELECT *
FROM ProjectCovid.dbo.NashvilleHousing

ALTER TABLE ProjectCovid.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, Propertyaddress

ALTER TABLE ProjectCovid.dbo.NashvilleHousing
DROP COLUMN SaleDate