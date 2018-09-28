CREATE PROCEDURE [dbo].[GetPanelTypes_AdminScreen] (
        @pCountryCode varchar(100)
       )
AS

BEGIN
	DECLARE @CountryId UNIQUEIDENTIFIER;

	SET @CountryId = (
			SELECT CountryId
			FROM Country
			WHERE CountryISO2A = @pCountryCode
			)

	SELECT DISTINCT pnl.GUIDReference AS PanelGuidVal
		,PanelCode
		,pnl.[Name] AS PanelName
	FROM Panel pnl
	INNER JOIN Panelist pnlist ON pnlist.Panel_Id = pnl.GUIDReference
	WHERE pnl.Country_Id = @CountryId
	ORDER BY PanelName
END