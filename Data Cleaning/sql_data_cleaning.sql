-- DATA CLEANING

-- Getting an idea of our columns and corresponding data types
select COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'nashville';

-- SaleDate conversion to only date type column
alter table nashville
alter column SaleDate date;

-- Populating Property Address data
-- Utilized the PardelID column to populate the missing PropertyAddress due to the column reltaionship
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
isnull(a.PropertyAddress,b.PropertyAddress)
from nashville a
join nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;
update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from nashville a
join nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

-- Confirming the population was successful
select ParcelID, count(distinct PropertyAddress)
from nashville
group by ParcelID
having count(distinct PropertyAddress) > 1;

-- Extracting the City from Address
-- Add the Address column to our table
alter table nashville
add Address nvarchar(255);
update nashville
set Address = substring(PropertyAddress,1,(CHARINDEX(',',PropertyAddress))-1);

-- Adding the City column to our table
alter table nashville
add City nvarchar(255);
update nashville
set City = substring(PropertyAddress,(CHARINDEX(',',PropertyAddress))+1,len(PropertyAddress));

-- Grabbing Address,City,Town from OwnerAddress
alter table nashville
add OwnerAddressSolo nvarchar(255);
update nashville
set OwnerAddressSolo = PARSENAME(replace(OwnerAddress,',','.'),3);

alter table nashville
add OwnerCity nvarchar(255);
update nashville
set OwnerCity = PARSENAME(replace(OwnerAddress,',','.'),2);

alter table nashville
add OwnerTown nvarchar(255);
update nashville
set OwnerTown = PARSENAME(replace(OwnerAddress,',','.'),1);


-- Change Y and N to Yes and No in SoldAsVacant

update nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from nashville;

-- Removing Duplicates

with duplicatecte as( 
select *,row_number() over(
partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
order by UniqueID) as row_num
from nashville
)
delete from duplicatecte
where row_num > 1;

-- Removing Unnecessary Columns
alter table nashville
drop column PropertyAddress,OwnerAddress; 
