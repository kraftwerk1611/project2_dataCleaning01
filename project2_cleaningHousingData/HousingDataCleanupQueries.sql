use NashvilleHousingData;

-- first look at data.
select * from tblHousingData;
--------------------------------------------------------------
--Task: fixing date format in SaleDate column
--Check date format in SaleDate column
Select SaleDateNew  from tblHousingData;

--change saleDate format in table.
Alter table tblHousingData 
add SaleDateNew Date;

update tblHousingData set SaleDateNew=convert(date, SaleDate);

--Change Property Address column
Select PropertyAddress from tblHousingData;

---------------------------------------------------
-- Fixing Null values in PropertyAddress column
Select PropertyAddress from tblHousingData where PropertyAddress is null; --checking for null values

--self join to fill some null values for which ParcelId exists.
Select t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress,
IsNull(t1.PropertyAddress, t2.propertyAddress)
from tblHousingData t1
join tblHousingData t2
On t1.ParcelID=t2.ParcelID
AND t1.[UniqueID ]<> t2.[UniqueID ]
where t1.PropertyAddress is null;

--now update
Update t1
Set propertyAddress=IsNull(t1.PropertyAddress, t2.propertyAddress)
from tblHousingData t1
join tblHousingData t2
On t1.ParcelID=t2.ParcelID
AND t1.[UniqueID ]<> t2.[UniqueID ]
where t1.PropertyAddress is null;

--check if it worked
Select PropertyAddress from tblHousingData where PropertyAddress is null; --checking for null values 

--------------------------------------------------------------------------------------
--Task: parsing PropertyAddress column

Select PropertyAddress from tblHousingData;

Select PropertyAddress, substring(PropertyAddress, 1, charIndex(',', PropertyAddress)-1) as address1,
SUBSTRING(PropertyAddress,charIndex(',', PropertyAddress)+1, len(PropertyAddress)) as address2
from tblHousingData;

-- Now updating the table
Alter table tblHousingData Add StreetAddress varchar(50);

Alter table tblHousingData Add City varchar(40)

update tblHousingData
Set StreetAddress=substring(PropertyAddress, 1, charIndex(',', PropertyAddress)-1) ;

update tblHousingData
set city=SUBSTRING(PropertyAddress,charIndex(',', PropertyAddress)+1, len(PropertyAddress));

select OwnerAddress from tblHousingData;

---------------------------------------------------

/*Fixing OwnerAddress using parsed names
-- ParseName() only works with period so we need to use Replace() first to replace comma with period.*/
Select REPLACE(OwnerAddress,',','.') from tblHousingData;

/*Interstingly ParseName() works backwards looking for period from the end.
therefore it is used three times in the following statement.*/

Select 
ParseName(REPLACE(OwnerAddress,',','.'),3),
ParseName(REPLACE(OwnerAddress,',','.'),2),
ParseName(REPLACE(OwnerAddress,',','.'),1)
from tblHousingData;


-- Now make changes to the table
Alter table tblHousingData
add OwnerStreetAddress varchar(100),
OwnerCity varchar(100),
OwnerState varchar(100);

-- now the update statement
update tblHousingData
set OwnerStreetAddress=ParseName(REPLACE(OwnerAddress,',','.'),3);

update tblHousingData
set OwnerCity=ParseName(REPLACE(OwnerAddress,',','.'),2);

update tblHousingData
set OwnerState=ParseName(REPLACE(OwnerAddress,',','.'),1);

select OwnerStreetAddress, OwnerCity, OwnerState from tblHousingData;

select OwnerAddress from tblHousingData where OwnerAddress is not null 
;

------------------------------------------------------------------------------
--fixing SoldAdVacant
-- We get both Yes and Y and No and N
select distinct(SoldAsVacant), count(SoldAsVacant) from tblHousingData
group by SoldAsVacant;

--fix it 
select SoldAsVacant
, Case when upper(SoldAsVacant)='Y' then 'Yes'
When upper(SoldAsVacant)='N' then 'No'
Else SoldAsVacant
End
from tblHousingData;

--now update
update tblHousingData
set SoldAsVacant= Case when upper(SoldAsVacant)='Y' then 'Yes'
When upper(SoldAsVacant)='N' then 'No'
Else SoldAsVacant
End;


----------------------------------------------------------------------------------------

-- removing duplicates
/* Remember when Partion by is used then first result of each partition is assigned number 1. This means
That in following result set every unique combination of given columns is treated as a single partiontion
and therefore assigned number 1. Any  value of 2 means a duplicate on these rows.*/
With RowNumCTE as (
select 
*, Row_Number() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
Order by UniqueID) row_num from tblHousingData )
Select * from RowNumCTE
where row_num>1
Order by PropertyAddress;

-- Now deleting the duplicates found using above query
With RowNumCTE as (
select 
*, Row_Number() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
Order by UniqueID) row_num from tblHousingData )
Delete from RowNumCTE
where row_num>1 


--------------------------------------------------------

--Deleting extra unused columns

select * from tblHousingData;

Alter table tblHousingData
drop column OwnerAddress, PropertyAddress, TaxDistrict;

-- Delte this column too.
Alter table tblHousingData
drop column StreetAddress;

Alter table tblHousingData
drop column SaleDate;

select * from tblHousingData;

