CREATE PROCEDURE [dbo].[GetDiaryIncentives] (
	@pCultureCode INT
	,@pCountryId uniqueidentifier
	)
AS
BEGIN
	SELECT Incen.GUIDReference AS Id
		,Code
		,TT.Value AS NAME
	FROM IncentivePointAccountEntryType Incen
	INNER JOIN TranslationTerm TT ON Incen.TypeName_Id = TT.Translation_Id
		AND TT.CultureCode = @pCultureCode
	WHERE Type = 'IncentiveType'
		AND Incen.Country_Id = @pCountryId
END