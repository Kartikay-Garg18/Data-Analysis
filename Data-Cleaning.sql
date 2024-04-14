select * from PortfolioProject..NashVilleHousing

--Standardize Date Format
Alter table PortfolioProject..NashVilleHousing
Alter column SaleDate date

--Analysing Property Address
select * 
from PortfolioProject..NashVilleHousing
where PropertyAddress is null

--Checking Existing Null Property Address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject..NashVilleHousing a
join PortfolioProject..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Populating Existing Null Property Address
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashVilleHousing a
join PortfolioProject..NashVilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking Out PropertyAddress Into Main Address, City

select PropertyAddress
from PortfolioProject..NashVilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject..NashVilleHousing

Alter table PortfolioProject..NashVilleHousing
add PropertyMainAddress nvarchar(255)

Alter table PortfolioProject..NashVilleHousing
add PropertyCity nvarchar(255)

Update PortfolioProject..NashVilleHousing
set PropertyMainAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Update PortfolioProject..NashVilleHousing
set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Breaking Out OwnerAddress Into Main Address, City, State

select OwnerAddress
from PortfolioProject..NashVilleHousing

select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashVilleHousing


Alter table PortfolioProject..NashVilleHousing
add OwnerMainAddress nvarchar(255)


Alter table PortfolioProject..NashVilleHousing
add OwnerCity nvarchar(255)


Alter table PortfolioProject..NashVilleHousing
add OwnerState nvarchar(255)

Update PortfolioProject..NashVilleHousing
set OwnerMainAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


Update PortfolioProject..NashVilleHousing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


Update PortfolioProject..NashVilleHousing
set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Setting Y and N to Yes and No respecticely in SoldAsVacant

select distinct(SoldAsVacant)
from PortfolioProject..NashVilleHousing

update PortfolioProject..NashVilleHousing
set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
						When SoldAsVacant = 'N' then 'No'
						Else SoldAsVacant
						END


--Removing Duplicate Rows

select *, ROW_NUMBER() Over (
							Partition By
							ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
							Order By UniqueID) DupNum
From PortfolioProject..NashVilleHousing


With DuplicateCTE AS
(
select *, ROW_NUMBER() Over (
							Partition By
							ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
							Order By UniqueID) DupNum
From PortfolioProject..NashVilleHousing
)

Select * 
from DuplicateCTE
where DupNum>1

Delete 
from DuplicateCTE
where DupNum>1

--Deleting Unusable Columns

select * 
from PortfolioProject..NashVilleHousing

alter table PortfolioProject..NashVilleHousing
drop column PropertyAddress, OwnerAddress, TaxDistrict
