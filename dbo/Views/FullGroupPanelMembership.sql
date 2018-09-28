CREATE VIEW [dbo].[FullGroupPanelMembership]
AS
SELECT CO.CountryISO2A
	,PanelCode
	,NAME PanelName
	,Sequence GroupId
	,pl.GPSUser
	,pl.CreationDate
	,pl.GPSUpdateTimestamp
FROM Collective I
INNER JOIN Candidate C ON I.GUIDReference = C.GUIDReference
INNER JOIN Panelist PL ON I.GUIDReference = PL.PanelMember_Id
INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
INNER JOIN Country CO(NOLOCK) ON CO.CountryId = C.Country_Id