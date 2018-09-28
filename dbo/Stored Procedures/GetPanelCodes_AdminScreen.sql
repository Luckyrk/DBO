CREATE procedure [dbo].[GetPanelCodes_AdminScreen](
@pcountrycode VARCHAR(10)
)
AS
BEGIN
SELECT P.GUIDReference as panel_Id, P.Name as PanelName , P.PanelCode as Panel_Code FROM Panel P 
join translation t on p.TypeTranslation_Id=t.translationid
join translationterm tt on tt.Translation_Id=t.translationid 
JOIN Country C ON P.Country_Id = C.CountryId
WHERE C.CountryISO2A = @pcountrycode and tt.culturecode=2057 
ORDER BY P.Name ASC
END
