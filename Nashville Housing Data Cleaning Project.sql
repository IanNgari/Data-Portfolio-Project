SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]


  SELECT *
  FROM PortfolioProject..NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------------
  /*
  CLEANING THE DATA
  */
 -------------------------------------------------------------------------------------------------------------------------------
  ---Standardize date format
  
  SELECT SaleDate2, CONVERT( Date, SaleDate)
  FROM PortfolioProject..NashvilleHousing


  UPDATE NashvilleHousing
  SET SaleDate= CONVERT( Date, SaleDate)

  ALTER TABLE NashvilleHousing
  ADD SaleDate2 Date;

  UPDATE NashvilleHousing
  SET SaleDate2= CONVERT( Date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------------
--Populate Property address data

  SELECT PropertyAddress
  FROM PortfolioProject..NashvilleHousing
  --Where PropertyAddress is null
  Order by ParcelID

  SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
  FROM PortfolioProject..NashvilleHousing as a
  JOIN PortfolioProject..NashvilleHousing as b
     on a.ParcelID= b.ParcelID
	 and a.[UniqueID ]<>b.[UniqueID ]

UPDATE a
SET PropertyAddress= ISNULL(a.propertyaddress, b.PropertyAddress)
 FROM PortfolioProject..NashvilleHousing as a
  JOIN PortfolioProject..NashvilleHousing as b
     on a.ParcelID= b.ParcelID
	 and a.[UniqueID ]<>b.[UniqueID ]


-------------------------------------------------------------------------------------------------------------------------------------------
--Breaking Address into individual columns (Address, City and State)

 SELECT PropertyAddress
  FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM dbo.NashvilleHousing


  ALTER TABLE NashvilleHousing
  ADD PropertySplitAddress NVARCHAR (255);

 UPDATE NashvilleHousing
  SET PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  ALTER TABLE NashvilleHousing
   ADD PropertySplitCity NVARCHAR (255);

  UPDATE NashvilleHousing
  SET PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 





  SELECT OwnerAddress
  FROM dbo.NashvilleHousing

 SELECT
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
 FROM dbo.NashvilleHousing

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitAddress NVARCHAR (255);

 UPDATE NashvilleHousing
  SET OwnerSplitAddress=  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

  ALTER TABLE NashvilleHousing
   ADD OwnerSplitCity NVARCHAR (255);

  UPDATE NashvilleHousing
  SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

   ALTER TABLE NashvilleHousing
   ADD OwnerSplitState NVARCHAR (255);

  UPDATE NashvilleHousing
  SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)







  ----------------------------------------------------------------------------------------------------------------------------------------
  --Change Y and N to Yes and No in 'SoldAsVacant' column


  SELECT SoldAsVacant, count(soldasvacant)
  FROM dbo.NashvilleHousing
  Group by SoldAsVacant
  order by 2

 SELECT SoldAsVacant,
 CASE When Soldasvacant= 'Y' then 'Yes'
	  When Soldasvacant= 'N' then 'No'
	  Else SoldAsVacant
	  End
  FROM dbo.NashvilleHousing
  

  UPDATE NashvilleHousing
  set SoldAsVacant= CASE When Soldasvacant= 'Y' then 'Yes'
	  When Soldasvacant= 'N' then 'No'
	  Else SoldAsVacant
	  End
  
-----------------------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

With RowNumCTE as(
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
FROM dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num> 1
---ORDER BY PropertyAddress

-----------------------------------------------------------------------------------------------------------------------------------------
--Delete Unused columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN  TaxDistrict 
