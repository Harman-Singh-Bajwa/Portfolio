-- Cleaning Data using SQL.


-- View data.

SELECT * FROM project1..Housing_Data;


-- Standardizing the date format.

SELECT SaleDate
FROM project1..Housing_Data

UPDATE project1..Housing_Data
SET SaleDate = CONVERT(DATE, SaleDate);

-- Previous format had a timestamp but it had no value, so removed it as it was redundant. 


-- Populating the Property Address column.

SELECT * FROM project1..Housing_Data
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM project1..Housing_Data a
JOIN project1..Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM project1..Housing_Data a
JOIN project1..Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

/*
Here, many houses were sold multiple times hence they had the same ParcelID.
So taking those ID's as a reference point, populated the blank address fields with them.
*/



-- Seperating the Address into different columns i.e Address, City and State.

-- Seperating PropertyAddress column.

SELECT PropertyAddress FROM project1..Housing_Data

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM project1..Housing_Data

ALTER TABLE project1..Housing_Data
ADD Property_Split_Address NVARCHAR(255);

Update project1..Housing_Data
SET Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE project1..Housing_Data
ADD Property_Split_City NVARCHAR(255);

Update project1..Housing_Data
SET Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT * FROM project1..Housing_Data

/* 
The PropertyAddress column had the Address and the City together seperated by a comma,
so we split it in two different columns to increase efficiency.
*/

-- Seperating OwnerAddress column.

SELECT OwnerAddress FROM project1..Housing_Data

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM project1..Housing_Data

ALTER TABLE project1..Housing_Data
ADD Owner_Split_Address NVARCHAR(255);

UPDATE PROJECT1..Housing_Data
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE project1..Housing_Data
ADD Owner_Split_City NVARCHAR(255);

UPDATE project1..Housing_Data
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE project1..Housing_Data
ADD Owner_Split_State NVARCHAR(255);

UPDATE project1..Housing_Data
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT * FROM project1..Housing_Data

/*
For splitting the OwnerAddress column we used a different approach, 
just for demonstration purposes. Here we used the PARSENAME, by replacing the comma 
with a period and then splitting the 3 parts into 3 different columns.
*/


-- Changing 'Y' and 'N' to 'Yes' or 'No' in the SoldAsVacant column. (For better Readability)

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM project1..Housing_Data
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM project1..Housing_Data

UPDATE project1..Housing_Data
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Just used a simple CASE statement to change the values.


-- Removing Duplicates. (For better efficiency)

WITH RowNumCTE AS(
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

FROM project1..Housing_Data
-- ORDER BY ParcelID
)
SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

/*
We used a CTE here to filter out the rows that have matching values across 
multiple columns, and then deleted them.
*/


-- Deleteing columns that are not required. (Again for better efficiency)

SELECT * FROM project1..Housing_Data

ALTER TABLE project1..Housing_Data
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate

-- We deleted these 3 columns as we have already converted and seperated out the values.
