
CREATE VIEW [dbo].[PanelSet]
AS
SELECT     dbo.FullPanelSet.CountryISO2A, dbo.FullPanelSet.Type, dbo.FullPanelSet.PanelCode, dbo.FullPanelSet.Total_Target_Population, dbo.FullPanelSet.Name,
            dbo.FullPanelSet.GPSUser, dbo.FullPanelSet.GPSUpdateTimestamp, dbo.FullPanelSet.CreationTimeStamp
FROM         dbo.FullPanelSet INNER JOIN
                      dbo.CountryViewAccess ON dbo.FullPanelSet.CountryISO2A = dbo.CountryViewAccess.Country
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND dbo.FullPanelSet.CountryISO2A = dbo.CountryViewAccess.Country