GO

CREATE VIEW [dbo].[GetViewExtendedProperties]
AS

--View information
select 
	v.Table_Name AS ViewName, e.name as PropertyName, e.value as ViewDescription
FROM INFORMATION_SCHEMA.VIEWS v
	INNER JOIN (
		SELECT objtype, objname, name, value FROM fn_listextendedproperty (NULL, 'schema', 'dbo', 'view', default, NULL, NULL)
		) e ON v.TABLE_NAME = e.objname COLLATE SQL_Latin1_General_CP1_CI_AI
--WHERE v.Table_Name = 'AllFullMainShoppersVN'
--ORDER BY v.TABLE_NAME

GO


--GRANT SELECT ON [GetViewExtendedProperties] TO GPSBusiness

--GO
