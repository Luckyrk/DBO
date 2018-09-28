/*##########################################################################
-- Name				: GetOnGoingCommunicationByIndividualAndUser  
-- Date             : 2014-11-27
-- Author           : GPS Developer
-- Purpose          : 
					  param definitions
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : Called from UI
-- PARAM Definitions
			-- @pIndividualGUID UNIQUEIDENTIFIER -- GUID of individual
			-- @pCountryId -- guid reference of country
			--@pGPSUser NVARCHAR(100)-- GPS user
Usage 
 EXEC GetOnGoingCommunicationByIndividualAndUser   'D27CF9C6-3BBF-4353-A8A4-64FD4D986317','70387977-88F8-40C4-BCD0-1173F1AAFFC4','testuseruk1'
 EXEC GetOnGoingCommunicationByIndividualAndUser   'D27CF9C6-3BBF-4353-A8A4-64FD4D986317','70387977-88F8-40C4-BCD0-1173F1AAFFC4'
##########################################################################
-- version  user                  date        change 
-- 1.0  GPS Developer			2014-11-27   Initial

##########################################################################*/
CREATE PROCEDURE [dbo].[GetOnGoingCommunicationByIndividualAndUser] 
	@pIndividualGUID UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pGPSUser NVARCHAR(100) = NULL
AS
BEGIN
	
		SELECT ce.GUIDReference AS OnGoingCommunicationId
			,indv.GUIDReference AS CandidateId
			,1 AS OnGoingCommunicationInProgress
			,ce.GPSUser AS UserHoldingCommunication
			,ce.Incoming AS Incoming
			,ce.ContactMechanism_Id
			,CMT.[Types] AS ContactMechanismType
			,Ce.ContactMechanism_Id AS ContactMechanismId
		FROM CommunicationEvent CE
		INNER JOIN Individual indv ON indv.GUIDReference = ce.Candidate_Id and indv.GUIDReference=@pIndividualGUID 
		INNER JOIN ContactMechanismType CMT ON CMT.GUIDReference = Ce.ContactMechanism_Id
		WHERE ce.Country_Id = @pCountryId
			AND ce.[State] = 1  -- InProgress
			AND ce.GPSUser =isnull( @pGPSUser,ce.GPSUser)
		ORDER BY ce.CreationDate DESC
	
END