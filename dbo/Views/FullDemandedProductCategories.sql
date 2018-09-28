
CREATE VIEW [dbo].[FullDemandedProductCategories]
AS
SELECT cnt.CountryISO2A
	,dpc.[ProductCode]
	,dpc.[ProductDescription]
FROM [dbo].[DemandedProductCategory] dpc
INNER JOIN Country cnt ON cnt.CountryId = dpc.Country_Id