
CREATE VIEW [dbo].[DemandedProductAnswers]
AS
SELECT [CountryISO2A]
	,[PanelCode]
	,[PanelName]
	,[PanelMemberId]
	,[MainShopperId]
	,[GPSUser]
	,[GPSUpdateTimestamp]
	,[CreationTimeStamp]
	,[ProductCode]
	,[Productdescription]
	,[AnswerCatCode]
	,[AnswerCatDescription]
	,[CalendarId]
	,[PeriodId]
	,[ActionTask_Id]
	,[StartDate]
	,[EndDate]
	,[CompletionDate]
	,[ActionComment]
	,[InternalOrExternal]
	,[State]
	,[CommunicationCompletion_Id]
	,IgnoreCall
	,AskAgainInterval
	,[FreeText]
FROM [dbo].[FullDemandedProductAnswers]
INNER JOIN dbo.CountryViewAccess ON dbo.FullDemandedProductAnswers.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullDemandedProductAnswers.CountryISO2A = dbo.CountryViewAccess.Country