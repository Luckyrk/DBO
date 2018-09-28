CREATE PROCEDURE rpt_NoPurchaseCheckReport @IndividualID VARCHAR(20)
	,@PeriodYearPeriod VARCHAR(20)
	,@PanelCode VARCHAR(5)
AS
BEGIN
	DECLARE @Year INT
		,@Period INT

	SET @Year = (
			SELECT items
			FROM Split(@PeriodYearPeriod, '.')
			WHERE Id = 1
			)
	SET @Period = (
			SELECT items
			FROM Split(@PeriodYearPeriod, '.')
			WHERE Id = 2
			)

	--SELECT
	--PeriodYearPeriod,ProductCode,Name,ProductDescription,AnswerCode,AnswerDesc FROM (
	--SELECT *,
	--CASE
	--WHEN resultset2.StringCount=1 THEN Period
	--ELSE
	--REVERSE(SUBSTRING(REVERSE(resultset2.Period),CHARINDEX('.',REVERSE(resultset2.Period))+1,LEN(resultset2.Period))) 
	--END AS PeriodYearPeriod
	--FROM (
	--	SELECT *,dbo.CountOccurancesOfString(Period,'.') as StringCount FROM (
	--			select DPC.ProductCode,P.Name AS Name,DPC.ProductDescription,DPCA.AnswerCatCode AS AnswerCode,DPCA.AnswerCatDescription AS AnswerDesc
	--			,[dbo].[GetPanelCalendarPeriod](PL.Country_Id, PL.Panel_Id, PL.CreationDate) AS Period 
	--			from DemandedProductAnswer DPA
	--			JOIN DemandedProductCategory DPC ON DPC.Id=DPA.DncProduct_Id
	--			JOIN DemandedProductCategoryAnswer DPCA ON DPCA.Id=DPA.DncAnswerCategory_Id
	--			JOIN CalendarPeriod CP ON CP.CalendarId=DPA.CalendarPeriod_CalendarId AND CP.PeriodId=DPA.CalendarPeriod_PeriodId
	--			JOIN Panelist PL ON PL.GUIDReference=DPA.Panelist_Id
	--			JOIN Panel P ON P.GUIDReference=PL.Panel_Id
	--			JOIN Individual I ON I.GUIDReference=PL.PanelMember_Id
	--			WHERE I.IndividualId=@IndividualID
	--			AND P.PanelCode=@PanelCode
	--	) AS resultset1
	--) AS resultset2
	--WHERE resultset2.StringCount>=1
	--) resultset3 WHERE resultset3.PeriodYearPeriod=@PeriodYearPeriod
	SELECT @PeriodYearPeriod AS PeriodYearPeriod
		,DPC.ProductCode
		,P.NAME AS NAME
		,DPC.ProductDescription
		,DPCA.AnswerCatCode AS AnswerCode
		,DPCA.AnswerCatDescription AS AnswerDesc
	FROM DemandedProductAnswer DPA
	INNER JOIN DemandedProductCategory DPC ON DPC.Id = DPA.DncProduct_Id
	INNER JOIN DemandedProductCategoryAnswer DPCA ON DPCA.Id = DPA.DncAnswerCategory_Id
	--JOIN CalendarPeriod CP ON CP.CalendarId=DPA.CalendarPeriod_CalendarId AND CP.PeriodId=DPA.CalendarPeriod_PeriodId
	INNER JOIN CalendarPeriodHierarchy CPH ON CPH.CalendarId = DPA.CalendarPeriod_CalendarId
		AND CPH.SequenceWithinHierarchy = 1
	INNER JOIN CalendarPeriod CPeriodYear ON CPeriodYear.PeriodTypeId = CPH.ParentPeriodTypeId
		AND CPeriodYear.CalendarId = DPA.CalendarPeriod_CalendarId
	INNER JOIN CalendarPeriod CPeriodPeriod ON CPeriodPeriod.PeriodTypeId = CPH.ChildPeriodTypeId
		AND CPeriodPeriod.PeriodId = DPA.CalendarPeriod_PeriodId
		AND CPeriodPeriod.StartDate >= CPeriodYear.StartDate
		AND CPeriodPeriod.EndDate <= CPeriodYear.EndDate
		AND CPeriodPeriod.CalendarId = CPeriodYear.CalendarId
	INNER JOIN Panelist PL ON PL.GUIDReference = DPA.Panelist_Id
	INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
	INNER JOIN Individual I ON I.GUIDReference = PL.PanelMember_Id
	WHERE I.IndividualId = @IndividualID
		AND P.PanelCode = @PanelCode
		AND CPeriodYear.PeriodValue = @Year
		AND CPeriodPeriod.PeriodValue = @Period
END