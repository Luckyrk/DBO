/*##########################################################################
-- Name				: GetBusinessIdsIncentiveReasonsDiaryHistory
-- Date             : 2014-09-26
-- Author           : GPS Developer
-- Company          : Cognizant Technology Solution
-- Purpose          : 
-- PARAM Definitions
	@CultureCode INT -- Culture code of type int
	@PanelId UNIQUEIDENTIFIER -- Guid of PanelId
	@CountryCode NVARCHAR(10) -- Value of the CountryCode
	@IncentiveId UNIQUEIDENTIFIER)-- Guid of Incentive Id
	@CurrentDate DATETIME - Current date
	
-- Sample Execution :
	EXEC GETBUSINESSIDSINCENTIVEREASONSDIARYHISTORY 2057,'46CF747A-20A7-47A3-BFD6-ABEC05336251','TW',NULL,'2014-10-28'
##########################################################################
-- ver  user			 date        change 
-- 1.0  Pradeep		    2014-10-10	 initial
-- 1.1  Teena Areti     2014-10-28	 Refactors
-- 1.2  Teena Areti     2014-12-01	 Refactors
-- 1.3  Teena Areti		2014-12-12   Removed unwanted select statements and removed input argument @pKeyName VARCHAR(20)
##########################################################################*/
CREATE PROCEDURE [dbo].[GetBusinessIdsIncentiveReasonsDiaryHistory] (
	@pCultureCode INT
	,@pPanelId UNIQUEIDENTIFIER
	,@pCountryID UNIQUEIDENTIFIER
	,@pIncentiveId UNIQUEIDENTIFIER
	,@pCurrentDate DATETIME
	)
AS
BEGIN
	
	--EXEC GetAvailablePanelists @pCultureCode  
	--	,@pPanelId
	--	,@pCountryID
		
	EXEC GetIncentiveReasons @pPanelId ,@pIncentiveId ,@pCultureCode 

END
