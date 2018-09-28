Create PROCEDURE [dbo].[GetAnswers_AdminScreen] (@pcountrycode NVARCHAR(30))
AS
BEGIN
	SELECT DISTINCT AnswerCatCode AS AnswerCode
		,AnswerCatCode+'-'+ AnswerCatDescription AS AnswerDescription
	FROM DemandedProductcategoryAnswer DA
	LEFT JOIN Country c ON c.CountryId = DA.Country_Id
	WHERE c.CountryISO2A = @pcountrycode
		AND AnswerCatDescription <> '-- Select one from List --'
	ORDER BY AnswerCatCode
END
