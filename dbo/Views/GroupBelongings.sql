CREATE VIEW [dbo].[GroupBelongings]
AS
SELECT     dbo.FullGroupBelongings.CountryISO2A, dbo.FullGroupBelongings.GroupId,
                      dbo.FullGroupBelongings.BelongingCode, dbo.FullGroupBelongings.BelongingType, dbo.FullGroupBelongings.BelongingName,
                      dbo.FullGroupBelongings.AttributeType, dbo.FullGroupBelongings.StringValue, dbo.FullGroupBelongings.IntegerValue, dbo.FullGroupBelongings.EnumValue, 
                      dbo.FullGroupBelongings.FloatValue, dbo.FullGroupBelongings.DateValue, dbo.FullGroupBelongings.BooleanValue,
					  dbo.FullGroupBelongings.[Status],
					  dbo.FullGroupBelongings.[FreeText],
                      dbo.FullGroupBelongings.GPSUser, dbo.FullGroupBelongings.GPSUpdateTimestamp, dbo.FullGroupBelongings.CreationTimeStamp
FROM         dbo.FullGroupBelongings CROSS JOIN
                      dbo.CountryViewAccess
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME() AND dbo.FullGroupBelongings.CountryISO2A = dbo.CountryViewAccess.Country)


GO