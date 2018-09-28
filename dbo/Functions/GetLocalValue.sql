CREATE FUNCTION GetLocalValue(@CountryISO2A NVARCHAR(10), @TranslationId uniqueidentifier)
 RETURNS NVARCHAR(MAX)
AS
BEGIN
RETURN (
SELECT TOP 1 CAST(TT2.Value AS NVARCHAR(255)) 
FROM TranslationTerm TT2 
WHERE  TT2.Translation_Id=@TranslationId AND  TT2.CultureCode  IN (
	(SELECT items from dbo.Split(
		CASE cast(@CountryISO2A AS VARCHAR)
			WHEN 'BR'
				THEN '1046'
			WHEN 'CH'
				THEN '13322'
			WHEN 'ID'
				THEN '1057'
			WHEN 'TH'
				THEN '1054'
			WHEN 'TW'
				THEN '1028'
			WHEN 'FR'
				THEN '1036'
			WHEN 'ES'
				THEN '3082,1034'
			WHEN 'GB'
				THEN '2057'
			WHEN 'PH'
				THEN '1124,13321'
			WHEN 'MY'
				THEN '17417,1086'
			WHEN 'VN'
				THEN '1066'
			END,','
		)
	))
	)
END