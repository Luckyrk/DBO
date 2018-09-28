
CREATE VIEW [dbo].[GetSummaryCategory]
AS
SELECT c.CountryISO2A
	,sc.Description
	,sc.SummaryCategoryId
FROM Summary_Category sc
INNER JOIN Country c ON c.CountryId = sc.Country_id