
CREATE VIEW [dbo].[FullPanelSet]
WITH SCHEMABINDING
AS
SELECT     dbo.Country.CountryISO2A, dbo.Panel.Type, dbo.Panel.PanelCode, dbo.Panel.Total_Target_Population, dbo.Panel.Name,
            dbo.Panel.GPSUser, dbo.Panel.GPSUpdateTimestamp, dbo.Panel.CreationTimeStamp
FROM         dbo.Panel INNER JOIN
                      dbo.Country ON dbo.Panel.Country_Id = dbo.Country.CountryId