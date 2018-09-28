
CREATE VIEW [dbo].[FullIndividualPanelMembership]
AS
SELECT CO.CountryISO2A
	,PanelCode
	,NAME PanelName
	,IndividualId
FROM Individual I
INNER JOIN Panelist PL(NOLOCK) ON I.GUIDReference = PL.PanelMember_Id
INNER JOIN Panel P(NOLOCK) ON P.GUIDReference = PL.Panel_Id
INNER JOIN Country CO(NOLOCK) ON CO.CountryId = I.CountryId