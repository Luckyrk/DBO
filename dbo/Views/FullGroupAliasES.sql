


CREATE VIEW [dbo].[FullGroupAliasES]
AS select *
FROM (SELECT [CountryISO2A]
      ,[GroupId]
      ,[Context]
      ,[Alias]
  FROM [dbo].[FullGroupAliasAsRows] where CountryISO2A = 'ES'
  ) AS source
PIVOT
(
    MAX([Alias])
    FOR [Context] IN (
      [NPAN(Baby Panel)],[NPAN(Household Panel)],[NPAN(Lady Panel)]
    )
  ) AS PivotTable