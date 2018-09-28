/*##########################################################################
-- Name				: GetBusinessIdsByPanel
-- Date             : 2014-10-26
-- Author           : GPS Developer
-- Company          : Cognizant Technology Solution
-- Purpose          : 
-- PARAM Definitions
	@CultureCode INT -- Culture code of type int
	@PanelId UNIQUEIDENTIFIER -- Guid of PanelId
	@pCountryId UNIQUEIDENTIFIER  -- Guid of Country
	@pIncentiveId UNIQUEIDENTIFIER -- Guid of Incentive
	@pIsPanelistsRequired  bit -- bit for logic
-- Sample Execution :
	EXEC GetBusinessIdsByPanel 2057,'46CF747A-20A7-47A3-BFD6-ABEC05336251','3558A18E-CCEB-CADC-CB8C-08CF81794A86',null,1
##########################################################################
-- ver  user			 date        change 
-- 1.0  Pradeep			2014-11-21	 initial
##########################################################################*/
CREATE PROCEDURE [dbo].[GetBusinessIdsByPanel] (
	 @pCultureCode int
	,@pPanelId UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pIncentiveId UNIQUEIDENTIFIER
	,@pIsPanelistsRequired BIT
	)
AS
BEGIN
	--IF (@pIsPanelistsRequired = 1)
	--BEGIN
		
	--	EXEC GetAvailablePanelists @pCultureCode
	--		,@pPanelId
	--		,@pCountryId
	--END

	EXEC GetIncentiveReasons @pPanelId
		,@pIncentiveId
		,@pCultureCode
END