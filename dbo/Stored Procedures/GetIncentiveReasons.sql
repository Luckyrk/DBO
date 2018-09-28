
/*##########################################################################
-- Name				: GetIncentiveReasons
-- Date             : 2014-11-21
-- Author           : GPS Developer
-- Company          : Cognizant Technology Solution
-- Purpose          : 
-- PARAM Definitions
	@pPanelId UNIQUEIDENTIFIER-- Guid of Panel
	@pIndividualId uniqueidentifier -- Guid of Individual
	@pCountryId UNIQUEIDENTIFIER -- Guid of Country
	
-- Sample Execution :
	EXEC GetIncentiveReasons '59229324-2033-4B5C-B620-0000039404C9','3558A18E-CCEB-CADC-CB8C-08CF81794A86',2057
##########################################################################
-- ver  user			 date        change 
-- 1.0  Pradeep		    2014-11-21	 initial
-- 1.1  Teena Areti		2014-12-01   Added history
##########################################################################*/
CREATE PROCEDURE [dbo].[GetIncentiveReasons] (
	@pPanelId UNIQUEIDENTIFIER
	,@pIncentiveId UNIQUEIDENTIFIER
	,@pCultureCode INT
	)
AS
BEGIN
		DECLARE @DateTime DATETIME
		DECLARE @CountryId UNIQUEIDENTIFIER
		SET @CountryId=(select Country_Id from panel  where GUIDReference=@pPanelId )
		SET @DateTime = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryId))

DECLARE @GETDATE DATE=CAST(@DateTime AS DATE)
	SELECT IP.GUIDReference AS Id
		,tt.Value AS Description
		,IP.Minimum
		,IP.Maximum
		,IP.HasUpdateableValue
		,IP.Value AS Points
		,IP.Code
	FROM IncentivePoint IP
	INNER JOIN PanelPoint PP ON PP.Point_Id = IP.GUIDReference
	INNER JOIN Panel p ON PP.Panel_Id = p.GUIDReference
	INNER JOIN TranslationTerm tt ON IP.Description_Id = tt.Translation_Id
		AND tt.CultureCode = @pCultureCode
	WHERE pp.Panel_Id = @pPanelId
		AND IP.Type_Id = @pIncentiveId
		AND (
			   (
				IP.ValidFrom IS NULL
			OR CAST(IP.ValidFrom AS DATE) <= @GETDATE
				)
			AND (
				IP.ValidTo IS NULL
				OR CAST(IP.ValidTo AS DATE) >= @GETDATE
				)
			)
END