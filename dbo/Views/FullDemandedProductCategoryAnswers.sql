
CREATE VIEW [dbo].[FullDemandedProductCategoryAnswers]
AS
SELECT cnt.CountryISO2A
	,dpc.[AnswerCatCode]
	,dpc.[AnswerCatDescription]
	--,dpc.[CallAgain] AS IgnoreCall
	,IIF(dpcam.DoNotCallAgain=1,0,1) AS IgnoreCall
	,dpcam.AskAgainInterval
	,dp.[ProductCode]
FROM [dbo].[DemandedProductCategoryAnswer] dpc
JOIN Country cnt ON cnt.CountryId = dpc.Country_Id
JOIN DemandedProductCategoryAnswerMapping dpcam ON dpcam.DemandedProductCategoryAnswer_Id=dpc.Id
JOIN DemandedProductCategory dp ON dp.Id=dpcam.DemandedProductCategory_Id