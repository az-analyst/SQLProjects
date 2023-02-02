/*
Project Script: Data Cleaning in SQL
*/


-- Extracting the original table

Select*
From DataBaseProjects.dbo.NashvilleHousing

--------------------------------------------------------------------------------

-- Standardize Data Type

Select SaleDate, CONVERT(Date, SaleDate) as SaleDateConverted
From DataBaseProjects.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate) -- It didn't work

Alter table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDate, SaleDateConverted
From NashvilleHousing

----------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
From NashvilleHousing

Select PropertyAddress
From NashvilleHousing
Where PropertyAddress is null -- there are null values

Select *
From NashvilleHousing
order by ParcelID -- there are duplicates: same ParcelIDs with the same addresses

--joining a table to itself, where ParcelID is the same, but not from the same row(UniqueID) 
Select n.ParcelID, n.PropertyAddress, h.ParcelID, h.PropertyAddress
From NashvilleHousing n
join NashvilleHousing h
on n.ParcelID = h.ParcelID
and n.[UniqueID ] <> h.[UniqueID ] 
where h.PropertyAddress is null

--Filling the null values in n.PropertyAddress with the data from h.PropertyAddress
Select n.ParcelID, n.PropertyAddress, h.ParcelID, h.PropertyAddress, ISNULL(n.PropertyAddress, h.PropertyAddress)
From NashvilleHousing n
join NashvilleHousing h
on n.ParcelID = h.ParcelID
and n.[UniqueID ] <> h.[UniqueID ] 
where n.PropertyAddress is null

-- Updating the table with the new values
Update n
Set PropertyAddress = ISNULL(n.PropertyAddress, h.PropertyAddress)
From NashvilleHousing n
join NashvilleHousing h
on n.ParcelID = h.ParcelID
and n.[UniqueID ] <> h.[UniqueID ] 
where n.PropertyAddress is null -- now there are no null values

---------------------------------------------------------------------------------------

-- Breaking Out Address Into New Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing

--Extracting address (data until delimeter comma) and deleting comma
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From NashvilleHousing

--Extracting cities
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as City
From NashvilleHousing

-- Adding new columns to the table
Alter table NashvilleHousing
Add Address nvarchar(255);

Update NashvilleHousing
Set Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add City nvarchar(255);

Update NashvilleHousing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))

Select *
from NashvilleHousing  -- new columns were added


--------------------------------------------------------------------------------

-- Another method of breaking down the address into the new columns

Select OwnerAddress
from NashvilleHousing

-- Using Parsename
select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
, PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing


-- Adding new columns to the table
Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

select *
from NashvilleHousing


----------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field


-- Looking at the values
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2  -- we have Y, N, Yes and No values

-- Changing values
select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from NashvilleHousing

-- Adding the new column to the table
Update NashvilleHousing
Set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end

select *
from NashvilleHousing

---------------------------------------------------------------------------------

--Remove duplicates

-- Creating CTE to look at the duplicates
With RowNum as (
select *,
Row_number() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, Legalreference
Order by UniqueID
) row_num

from NashvilleHousing
)

select *
from RowNum
where row_num > 1
order by PropertyAddress

-- Deleting duplicates
With RowNum as (
select *,
Row_number() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, Legalreference
Order by UniqueID
) row_num

from NashvilleHousing
)

DELETE
from RowNum
where row_num > 1


---------------------------------------------------------------------------------------

-- Remove unnecessary columns

Alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table NashvilleHousing
drop column SaleDate


-- Looking at the final version of the table
select *
from NashvilleHousing