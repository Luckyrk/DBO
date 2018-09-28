CREATE VIEW [dbo].[BelongingCensoViewES]
AS 
WITH FilteredBelongings([GroupId], [BelongingCode], [Status], [AttributeType],[Value])
AS
(
	SELECT 
	[GroupId], [BelongingCode], [Status], [AttributeType], Value      
	FROM [dbo].[FullGroupBelongingsLight]
	WHERE [CountryISO2A]='ES' AND BelongingName='censo'
)
SELECT GroupId, BelongingCode, [Status], [Census DateSent],[Census DateReceived], [Census state], [Census type], [Census year]
FROM(
 SELECT * FROM FilteredBelongings
) p
PIVOT 
(
 MAX(value)
 FOR AttributeType in ([Census DateSent],[Census DateReceived], [Census state], [Census type], [Census year])
)
AS pt 
