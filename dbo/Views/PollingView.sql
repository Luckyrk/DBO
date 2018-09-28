
CREATE view [dbo].[PollingView] as
SELECT op260.COMMS_EVENT_CODE
	,op260.COMMS_DATE
	,op260.COMMS_EVENT_OUTCOME
	,op260.INSERT_DATE
	,op255.DEVICE_SERIAL_CHAR
	,coun.CountryISO2A
	,iv.IndividualId
	,pl.PanelCode
FROM PTO260_copy op260
INNER JOIN PTO255_copy op255 ON op260.CALL_NUMBER = op255.CALL_NUMBER
INNER JOIN Collective co ON RIGHT('000000' + CAST(op255.HOUSEHOLD_NUMBER AS VARCHAR(6)), 6) = RIGHT('000000' + CAST(co.Sequence  AS VARCHAR(6)), 6)
INNER JOIN Candidate can ON co.GUIDReference = can.GUIDReference
INNER JOIN Individual iv ON co.GroupContact_Id = iv.GUIDReference
INNER JOIN Respondent res ON can.GUIDReference = res.GUIDReference
INNER JOIN Country coun ON res.CountryID = coun.CountryId
INNER JOIN Panelist p ON p.Country_Id = coun.CountryId
	AND p.PanelMember_Id = can.GUIDReference
INNER JOIN Panel pl ON pl.GUIDReference = p.Panel_Id
	AND pl.Country_Id = coun.CountryId