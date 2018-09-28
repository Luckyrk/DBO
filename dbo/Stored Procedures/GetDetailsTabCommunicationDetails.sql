/*##########################################################################
-- Name				: GetDetailsTabCommunicationDetails
-- Date             : 2014-11-24
-- Author           : GPS Developer
-- Company          : Cognizant Technology Solution
-- Purpose          : 
-- PARAM Definitions
	@pIndividualId uniqueidentifier -- Guid of Individual
	@pCountryId UNIQUEIDENTIFIER -- Guid of Country
	
-- Sample Execution :
	EXEC GetDetailsTabCommunicationDetails '59229324-2033-4B5C-B620-0000039404C9','3558A18E-CCEB-CADC-CB8C-08CF81794A86'
##########################################################################
-- ver  user			 date        change 
-- 1.0  Ramana		    2014-11-24	 initial
##########################################################################*/
CREATE PROCEDURE [dbo].[GetDetailsTabCommunicationDetails]
@pIndividualId uniqueidentifier,
@pCountryId uniqueidentifier
AS
BEGIN
       SELECT 
		   CM.CollectiveMembershipId as GroupMembershipId,
		   IIF(LEN(C.Sequence)>CC.GroupBusinessIdDigits, CAST(C.Sequence AS VARCHAR), REPLICATE('0',CC.GroupBusinessIdDigits-LEN(C.Sequence))+CAST(C.Sequence AS VARCHAR)) as BusinessId
       FROM CollectiveMembership CM
       JOIN StateDefinition SD ON SD.Id=CM.State_Id
       JOIN Collective C ON C.GUIDReference=CM.Group_Id
       JOIN Country COU ON COU.CountryId=C.CountryId
       JOIN CountryConfiguration CC ON COU.Configuration_Id=CC.Id
       WHERE Individual_Id=@pIndividualId
		   AND COU.CountryId=@pCountryId
		   AND (SD.InactiveBehavior = 0 OR NOT EXISTS (SELECT * FROM CollectiveMembership CM2 
													JOIN StateDefinition SD2 ON SD2.Id = CM2.State_Id
													WHERE CM2.Individual_Id = @pIndividualId AND SD2.InactiveBehavior = 0))
END