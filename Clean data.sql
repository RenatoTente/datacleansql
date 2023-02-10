use dataclean

--clean data exercice

select * from dataclean.dbo.house

--standardize data format

select SaleDate, convert(date,SaleDate)
from dataclean.dbo.house



alter table house
add saledateconverted date

update house
set saledateconverted = convert(date,saledate)

select saledateconverted, convert(date,SaleDate)
from dataclean.dbo.house


-- populate property adress data

select *
from dataclean.dbo.house
--where PropertyAddress is null
order by parcelid


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from dataclean.dbo.house a
join dataclean.dbo.house b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dataclean.dbo.house a
join dataclean.dbo.house b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

-- Adress into indivudal columns (adress,city,state)

select PropertyAddress
from dataclean.dbo.house
--where PropertyAddress is null
--order by parcelid

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,len(PropertyAddress)) as address

from dataclean.dbo.house


--add columns with city and adress
alter table house
add propretyadresssplit nvarchar(255);

update house
set propretyadresssplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table house
add propretycityplit nvarchar(255);

update house
set propretycityplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,len(PropertyAddress))
go

select *
from dataclean.dbo.house





select OwnerAddress
from dataclean.dbo.house

select
PARSENAME(replace(OwnerAddress,',','.'), 3),
PARSENAME(replace(OwnerAddress,',','.'), 2),
PARSENAME(replace(OwnerAddress,',','.'), 1)
from dataclean.dbo.house



alter table house
add Owneraddressplit nvarchar(255)
go

update house
set Owneraddressplit = PARSENAME(replace(OwnerAddress,',','.'), 3)
go

alter table house
add Ownercitysplit nvarchar(255);
go

update house
set Ownercitysplit = PARSENAME(replace(OwnerAddress,',','.'), 2)
go

alter table house
add Ownerstateplit nvarchar(255);
go

update house
set Ownerstateplit = PARSENAME(replace(OwnerAddress,',','.'), 1)
go



select *
from dataclean.dbo.house


--change Y and N to yes or no in "sold as vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from dataclean.dbo.house
group by SoldAsVacant
order by 2


select SoldAsVacant,
case
     when soldasvacant ='Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end
from dataclean.dbo.house


update house
set SoldAsVacant = case
     when soldasvacant ='Y' then 'Yes'
     when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end

select distinct(SoldAsVacant), count(SoldAsVacant)
from dataclean.dbo.house
group by SoldAsVacant
order by 2


--remove duplicates
with rownumcte as (
select *, 
ROW_NUMBER()over(
partition by ParcelID,
             propertyaddress,
			 saleprice,
			 saledate,
			 legalreference
			 order by UniqueID)
			 row_num
from dataclean.dbo.house
--order by ParcelID
)
--DELETE
select *
from rownumcte
where row_num > 1
--order by PropertyAddress



--SELECT COUNT(DISTINCT [UniqueID ])
--from dataclean.dbo.house

--SELECT COUNT([UniqueID ])
--from dataclean.dbo.house


--delect unused columns

select * from dataclean.dbo.house

alter table dataclean.dbo.house
drop column OwnerAddress, taxdistrict, propertyaddress

alter table dataclean.dbo.house
drop column saledate

