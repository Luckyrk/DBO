/*##########################################################################
-- Name             : GetPanelistUrlInfo
-- Date             : 2014-12-01
-- Author           : Venkata Ramana
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure used to get the charity subsription details of individual
-- Usage            : 
-- PARAM Definitions
		@pCandidateId UNIQUEIDENTIFIER-- GUID of Candidate
		@pCountryID UNIQUEIDENTIFIER  -- GUID of country
				      
-- Sample Execution :
      EXEC GetPanelistUrlInfo '17D348D8-A08D-CE7A-CB8C-08CF81794A86','59229324-2033-4B5C-B620-0000039404C9'
##########################################################################
-- ver  user               date        change 
-- 1.0  Venkata Ramana     2014-11-01	  initial
##########################################################################*/

--
CREATE PROCEDURE GetPanelistUrlInfo --'17D348D8-A08D-CE7A-CB8C-08CF81794A86','59229324-2033-4B5C-B620-0000039404C9',1
        @pCandidateId uniqueidentifier,
        @pCountryId uniqueidentifier		
		AS
		BEGIN
		BEGIN TRY 
		DECLARE @IsVisibile BIT
		DECLARE @Url NVARCHAR(2000)
		DECLARE @TestModeOn NVARCHAR(2000)

		SELECT @IsVisibile=dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'ShowPanellisttripInfoUrl_Ind', 1)                           	
		SELECT @Url=[Key]  from NamedAlias NA
		join NamedAliasContext NAC on NA.AliasContext_Id=NAC.NamedAliasContextId
		where NA.Candidate_Id=@pCandidateId and NAC.Country_Id=@pCountryId --1

		SELECT ISNULL(@IsVisibile,0) AS IsVisibile,@Url AS Url

		SET @IsVisibile=NULL
		SET @Url=NULL
		SET @TestModeOn=NULL
		
		SELECT @IsVisibile= dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'ShowPanelistPollingDetailUrl', 1) --2

		SELECT @Url=
		(CASE
		WHEN KV.Value IS NULL THEN KS.DefaultValue
		ELSE KV.Value
		END) 
		from KeyAppSetting KS
		LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryId
		WHERE KS.KeyName='FrenchPollingDetailUrl' --2

		SELECT @TestModeOn=
		(CASE
		WHEN KV.Value IS NULL THEN KS.DefaultValue
		ELSE KV.Value
		END)
		from KeyAppSetting KS
		LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryId
		WHERE KS.KeyName='FrenchPollingDetailTestMode' --2

		SELECT ISNULL(@IsVisibile,0) AS IsVisibile,@Url AS Url,@TestModeOn AS TestModeOn
	   
	    SET @IsVisibile=NULL
		SET @Url=NULL
		SET @TestModeOn=NULL	
		SELECT @IsVisibile=dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'ShowFrenchShopManagementUrl', 1) --3

		SELECT @Url=
		(CASE
		WHEN KV.Value IS NULL THEN KS.DefaultValue
		ELSE KV.Value
		END )
		from KeyAppSetting KS
		LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryId
		WHERE KS.KeyName='FrenchShopManagementUrl'--3

		SELECT @TestModeOn=
		(CASE
		WHEN KV.Value IS NULL THEN KS.DefaultValue
		ELSE KV.Value
		END)
		from KeyAppSetting KS
		LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryId
		WHERE KS.KeyName='FrenchShopManagementTestMode' --3
		
		SELECT ISNULL(@IsVisibile,0) AS IsVisibile,@Url AS Url,@TestModeOn AS TestModeOn
		
		SET @IsVisibile=NULL
		SET @Url=NULL
		SET @TestModeOn=NULL
		SELECT @IsVisibile=dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'FrenchComplianceUrl', 1) --4

		SELECT @Url=
		(CASE
		WHEN KV.Value IS NULL THEN KS.DefaultValue
		ELSE KV.Value
		END )
		from KeyAppSetting KS
		LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryId
		WHERE KS.KeyName='FrenchComplianceUrl'--4

		SELECT @TestModeOn=
		(CASE
		WHEN KV.Value IS NULL THEN KS.DefaultValue
		ELSE KV.Value
		END
		)
		from KeyAppSetting KS
		LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryId
		WHERE KS.KeyName='FrenchComplianceTestMode'--4
	   
	   SELECT ISNULL(@IsVisibile,0) AS IsVisibile,@Url AS Url,@TestModeOn AS TestModeOn
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