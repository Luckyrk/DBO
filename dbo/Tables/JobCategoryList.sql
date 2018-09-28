CREATE TABLE JobCategoryList
(
JobCategoryNum int IDENTITY(1,1) PRIMARY KEY,
JobCategory nvarchar(max),
CountryISO2A varchar(max)
);