CREATE VIEW StockTypes
AS
SELECT ST.Code,ST.Name, C.CountryISO2A from StockType ST
JOIN Country C ON C.CountryId=ST.CountryId