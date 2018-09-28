/*##########################################################################
-- Name				: GetCalculatedDemographics.sql
-- Date             : 2014-09-26
-- Author           : Soujanya
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure gets all the Demographics and its values based on Country code and type
-- Usage			:
-- Impact			: 
-- Required grants  : 
-- Called by        : Visual Cron
-- PARAM Definitions
	@pCountryISO2A CHAR(2) -- Country Code
	@pType NVARCHAR(256) -- Type of demographic	
-- Sample Execution :
	Exec GetCalculatedDemographics 'TW' 'INDIVIDUAL'
##########################################################################
-- ver  user			 date        change 
-- 1.0  Soujanya        2014-09-26	 Initial
-- 1.1  GopiChand       2014-10-27	 Refactors
##########################################################################*/
CREATE PROCEDURE [dbo].[GetCalculatedDemographics] @pCountryISO2A CHAR(2)
	,@pType NVARCHAR(256)
AS
BEGIN
BEGIN TRY 
	DECLARE @countryId AS UNIQUEIDENTIFIER

	SET @countryId = (
			SELECT CountryId
			FROM Country
			WHERE CountryISO2A = @pCountryISO2A
			)

	SELECT A.GUIDReference AS DemographicId
		,BR.BusinessRule
		,BR.ApplicationName
		,A.[Type] AS AttributeType
		,BR.EntityName
		,A.[Key]
		,BR.Type AS RuleType
		,BR.Version
		,BR.Name AS BusinessRuleName
		,A.Country_Id AS CountryId
		,BRC.Name AS ContextName
		,BRC.ValidationsFolderPath AS ValidationsFolderPath
	FROM Attribute A
	INNER JOIN BusinessRule BR ON A.Calculation_Id = BR.GUIDReference
	INNER JOIN BusinessRulesContext BRC ON BR.Context_Id = BRC.GUIDReference
		AND BR.[Type] = @pType
	WHERE A.Country_Id = @countryId
		AND A.IsCalculated = 1
END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH
END