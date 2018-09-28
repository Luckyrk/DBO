/*##########################################################################
-- Name             : GetAliasContext
-- Date             : 2014-09-26
-- Author           : Teena Areti
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure used to get the individual NamedAliases
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        :
-- PARAM Definitions
		@pBusinessId uniqueidentifier -- GUID of Individual table
		@pDiscriminator NVARCHAR(256)-- Discriminator of varchar type
		
-- Sample Execution :
       Exec [dbo].[GetAliasContext]  'BC05A5FD-CB7E-C4F4-C1A6-08D11B004586', '2057'                                     
##########################################################################
-- ver  user               date        change 
-- 1.0  Teena Areti     2014-09-26		initial
##########################################################################*/
CREATE PROCEDURE [dbo].[GetAliasContext] @pBusinessId uniqueidentifier
	,@pDiscriminator NVARCHAR(256)
AS
BEGIN
BEGIN TRY
	SELECT NA.[Guid] AS Id
		,NAC.Name
		,P.Name
		,NAS.[Type] AS Strategy
		,NAS.NamedAliasStrategyId AS Id
		,NAS.[Max]
		,NAS.[Min]
		,NAS.[Type] AS StrategyType
	FROM Individual I
	INNER JOIN NamedAlias NA ON Na.Candidate_Id = I.GUIDReference
	INNER JOIN NamedAliasContext NAC ON NAC.NamedAliasContextId = NA.AliasContext_Id
		AND NAC.Discriminator = @pDiscriminator
	INNER JOIN Panel P ON P.GUIDReference = NAC.Panel_Id
	INNER JOIN NamedAliasStrategy NAS ON NAS.NamedAliasStrategyId = NAC.Strategy_Id
	WHERE I.GUIDReference = @pBusinessId
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