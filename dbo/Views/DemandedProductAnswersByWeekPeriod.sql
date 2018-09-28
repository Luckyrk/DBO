CREATE VIEW [dbo].[DemandedProductAnswersByWeekPeriod]
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
	,[YearPeriodWeek]
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
FROM [dbo].[FullDemandedProductAnswersByWeekPeriod]
INNER JOIN dbo.CountryViewAccess ON dbo.FullDemandedProductAnswersByWeekPeriod.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullDemandedProductAnswersByWeekPeriod.CountryISO2A = dbo.CountryViewAccess.Country