-- name: housing-queries
-- description: mysql code to clean up a housing data set
-- author: Gustavo Sopena

# Housing Data

## Populate Property Address Data

-- here, we select every column from the data set, where the `PropertyAddress` contains a value
-- in this case, we check against the empty string, ''

select *
from Nashville
where PropertyAddress = ''

-- we notice that rows with the same `ParcelID` have a corresponding property address
-- so, we are going to use this to populate the missing addresses

-- the following code joins the table to itself on the parcel ID and making sure the rows are mapped to a different row
-- in other words, it checks that row 1 is not mapped to row 1, but another row entirely
-- this process can be SLOW
-- however, since we are checking the rows that have empty property address, the process is less demanding

-- note that since the PropertyAddress is a string and empty strings are denoted by "", then we cannot use
-- ifnull(a.PropertyAddress, b.PropertyAddress)
-- so, we use the `if` and `strcmp` functions to achieve the desired output
-- essentially comparing against the empty string

-- afterwards, we can update the table to copy the addresses to the correct column
-- running this code after updating the column should result in no values returned

select a.ParcelID as aid, a.PropertyAddress as apa, b.ParcelID as bid, b.PropertyAddress as bpa, if(strcmp(a.PropertyAddress, "") = 0, b.PropertyAddress, a.PropertyAddress)
from Nashville a
join Nashville b
    on a.ParcelID = b.ParcelID
    and a.id <> b.id
where a.PropertyAddress = ''

-- here, we want to update the original dataset
-- for some reason, the following code yields a syntax error

-- update a
-- set PropertyAddress = if(strcmp(a.PropertyAddress, "") = 0, b.PropertyAddress, a.PropertyAddress) 
-- from Nashville as a
-- join Nashville as b
--     on a.ParcelID = b.ParcelID
--     and a.id <> b.id
-- where a.PropertyAddress = ''

-- after a bit of Google Searches, we have the following code to update the `PropertyAddress` column in the Nashville table

update Nashville as a
join Nashville as b
    on a.ParcelID = b.ParcelID
    and a.id <> b.id
set a.PropertyAddress = if(strcmp(a.PropertyAddress, "") = 0, b.PropertyAddress, a.PropertyAddress)
where a.PropertyAddress = ''

## Separate Address into three columns (Address, City, State)

-- this operation is useful when we want to categorize the data, e.g., cities
-- first, we can locate the comma in the address
-- we include a +1 in the second `substring` call because we want to move over the comma in the string

select substring(PropertyAddress, 1, locate(',', PropertyAddress)-1) as Address,
    substring(PropertyAddress, locate(',', PropertyAddress)+1, length(PropertyAddress)) as Address2
from Nashville

-- since we cannot create columns from the above, we need to do so "manually"
-- in the following, we create the desired columns and update them with the columns obtained from the previous queries
-- then, we can drop the original (combined) `PropertyAddress` column
-- the `locate` function finds the index position of the first argument of the string in the second argument

alter table Nashville
add PropertyAddressSplit varchar(255)

update Nashville
set PropertyAddressSplit = substring(PropertyAddress, 1, locate(',', PropertyAddress)-1)

alter table Nashville
add PropertyCity varchar(255)

update Nashville
set PropertyCity = substring(PropertyAddress, locate(',', PropertyAddress)+1, length(PropertyAddress))

select PropertyAddressSplit, PropertyCity
from Nashville
limit 10

## Separate the `OwnerAddress` into its parts

-- we are going to use `parsename`

select
parsename(replace(OwnerAddrses, ",", "."), 3),
parsename(replace(OwnerAddrses, ",", "."), 2),
parsename(replace(OwnerAddrses, ",", "."), 1)
from Nashville

-- now that we have the three columns, we can add them to the dataset as we did before

## Consistent labeling in boolean fields

-- if we take a look at the SoldAsVacant column, there is a combination of "N", "No", "Y", and "Yes"
-- we can choose one or the other but we cannot (or should not) have both
-- we can use the following query to see how the study was written in one form and perhaps switched to another form down the line

select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville
group by SoldAsVacant
order by 2

-- |SoldAsVacant|count(SoldAsVacant)|
-- |------------|-------------------|
-- |Y|52|
-- |N|399|
-- |Yes|4623|
-- |No|51403|

-- in our case, we are going to switch the letters to words
-- the following code showcases this with the `case`-`when` syntax
-- in here, the second column of the resulting table is updated with the desired strings based on the one encountered in the original

select SoldAsVacant,
    case when SoldAsVacant = 'Y' then 'Yes'
         when SoldAsVacant = 'N' then 'No'
         else SoldAsVacant
    end
from Nashville

-- unlike some of the queries above where we created columns, we can update the `SoldAsVacant` column directly

update Nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
end

-- running the query to show the results:
-- |SoldAsVacant|count(SoldAsVacant)|
-- |------------|-------------------|
-- |Yes|4675|
-- |No|51802|

-- I had the idea to use the if statement, but it would not have looked pretty
-- select distinct(if(strcmp(SoldAsVacant, "Y") = 0, "Yes", SoldAsVacant))
-- from Nashville

## Remove Duplicates

-- it is not standard practice to delete data from the dataset
-- in this case, we are essentially making assumptions of is considered a duplicate row
-- we are going to be supposing that rows are duplicates if the following match:
-- ParcelID
-- PropertyAddress
-- SalePrice
-- SaleDate
-- LegalReference

-- as such, we are going to use the partition statement

-- in the following code, the (next) row number is set when the five fields all match the previous row
-- the dataset is being ordered by the id
-- in other words, for each of the five column matches, order the ids from lowest to highest

select *,
    row_number() over (
    partition by ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
    order by id
    ) as row_num
from Nashville
order by id

-- sample output:
-- |id|ParcelID|...|row_num|
-- |---|---|---|---|
-- |123|1122|...|1|
-- |125|1122|...|2|

-- this can be further inspected by using a CTE to see when the row_num is greater than 1
-- to delete, replace the selection with the `delete` operation and specifying `where row_num > 1`

## Deleting Unused Columns

-- best practice? do not do this on the raw dataset (perhaps make a copy of the dataset)
-- for example, we can drop:
-- OwnerAddress
-- TaxDistrict
-- PropertyAddress
-- SaleDate
