CREATE PROCEDURE rpt_NoPurchaseCheckReport @IndividualID VARCHAR(20)

	--,@PeriodYearPeriod VARCHAR(20)

	,@PanelCode VARCHAR(5)

AS

BEGIN
BEGIN TRY 

	--DECLARE @Year INT

	--	,@Period INT



	--SET @Year = (

	--		SELECT items

	--		FROM Split(@PeriodYearPeriod, '.')

	--		WHERE Id = 1

	--		)

	--SET @Period = (

	--		SELECT items

	--		FROM Split(@PeriodYearPeriod, '.')

	--		WHERE Id = 2

	--		)




	SELECT CAST(CPeriodYear.PeriodValue AS VARCHAR)+'.'+CAST(CPeriodPeriod.PeriodValue AS  VARCHAR) AS PeriodYearPeriod

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
	INNER JOIN candidate c ON c.GUIDReference = PL.PanelMember_Id
	inner join collectivemembership cm on (case when p.Type='HouseHold' then cm.group_id
	else cm.individual_id end)=c.guidreference
	join individual I on I.guidreference=cm.individual_id

	WHERE I.IndividualId = @IndividualID

		AND P.PanelCode = @PanelCode

		--AND CPeriodYear.PeriodValue = @Year

		--AND CPeriodPeriod.PeriodValue = @Period
		ORDER BY CPeriodYear.PeriodValue DESC,CPeriodPeriod.PeriodValue DESC
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH	
END
GO