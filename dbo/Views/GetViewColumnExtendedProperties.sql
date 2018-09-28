GO

CREATE VIEW [dbo].[GetViewColumnExtendedProperties]
AS

--View column information
SELECT 
	o.name AS TableName
	, c.name AS ColumnName
	, c.column_id AS OrdinalNum
	, t.name AS DataType
	, c.max_length
	,  ep.name AS PropertyName
	,  ep.value AS Description
FROM sys.objects o
INNER JOIN sys.columns c ON o.object_id = c.object_id
INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
CROSS APPLY fn_listextendedproperty(default,
                  'SCHEMA', schema_name(o.schema_id),
                  'View', o.name, 'COLUMN', c.name) ep
--ORDER BY o.name, c.column_id

GO

--GRANT SELECT ON [GetViewColumnExtendedProperties] TO GPSBusiness

--GO