
CREATE VIEW [dbo].[IndividualPID]
AS
SELECT dbo.FullIndividualPID.CountryISO2A
	,dbo.FullIndividualPID.IndividualId
	,dbo.FullIndividualPID.DateOfBirth
	,dbo.FullIndividualPID.SexCode
	,dbo.FullIndividualPID.SexDescription
	,dbo.FullIndividualPID.TitleCode
	,dbo.FullIndividualPID.TitleDescription
	,dbo.FullIndividualPID.FirstOrderedName
	,dbo.FullIndividualPID.MiddleOrderedName
	,dbo.FullIndividualPID.LastOrderedName
	,dbo.FullIndividualPID.StateCode
	,dbo.FullIndividualPID.EnrollmentDate
	,dbo.FullIndividualPID.GeographicAreaCode
	,dbo.FullIndividualPID.Comment
FROM dbo.FullIndividualPID
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualPID.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullIndividualPID.CountryISO2A = dbo.CountryViewAccess.Country