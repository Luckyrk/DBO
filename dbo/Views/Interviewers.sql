
CREATE VIEW [dbo].Interviewers
AS
SELECT *
FROM dbo.FullInterviewers
CROSS JOIN dbo.CountryViewAccess
WHERE (
		dbo.CountryViewAccess.UserId = SUSER_SNAME()
		AND FullInterviewers.CountryISO2A = dbo.CountryViewAccess.Country
		)