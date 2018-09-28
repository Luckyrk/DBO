Create PROCEDURE [dbo].[GetProducts_AdminScreen] (@pcountrycode NVARCHAR(30))
AS
BEGIN
	SELECT DISTINCT ProductCode
		,ProductCode+'-'+ProductDescription AS ProductDescription
	FROM DemandedProductCategory DA
	LEFT JOIN Country c ON c.CountryId = DA.Country_Id
	WHERE c.CountryISO2A = @pcountrycode
		AND ProductDescription <> '-- Select one from List --'
	ORDER BY ProductCode
END
