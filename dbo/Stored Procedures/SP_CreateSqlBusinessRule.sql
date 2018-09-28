CREATE PROCEDURE [dbo].[SP_CreateSqlBusinessRule]
@jobQuery as nvarchar(MAX),
@isOneToMany as bit,
@ruleApplicationName as nvarchar (100),
@ruleName as nvarchar (100),
@entityName as nvarchar (100),
@ruleVersion as int,
@isActive as bit,
@description as nvarchar (200),
@countryId as uniqueidentifier,
@loggedInUser as nvarchar(50),
@jobType as nvarchar(50)

As 
BEGIN
BEGIN TRY
DECLARE @sqlBusinessRuleId as bigint,
@code as nvarchar(200)

DECLARE @GetDate DATETIME
SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@countryId))

BEGIN TRY
BEGIN TRAN
IF NOT EXISTS(SELECT 1 FROM SqlJob WHERE [Description]= @description AND CountryId = @countryId)
BEGIN
INSERT INTO SqlBusinessRule (SqlCommand, IsOneToManySql, RuleApplicationName, RuleName, RuleEntity, RuleVersion, CreateTimeStamp, GPSUpdateTimeStamp, GPSUser,JobType)
VALUES (@jobQuery,@isOneToMany,@ruleApplicationName,@ruleName,@entityName,@ruleVersion, @GetDate,@GetDate,@loggedInUser,@jobType)


SELECT @sqlBusinessRuleId = SCOPE_IDENTITY()

SELECT @code = 'J' + cast(@sqlBusinessRuleId as nvarchar(20))

SELECT @code


INSERT INTO SqlJob (Code, IsActive, SQLBusinessRuleID, Description,CountryId, CreationTimeStamp, GPSUpdateTimestamp, GPSUser)
VALUES (@code, @isActive, @sqlBusinessRuleId,@description,@countryId, @GetDate,@GetDate,@loggedInUser)

SELECT @code

END
COMMIT TRAN
END TRY
BEGIN CATCH
ROLLBACK TRAN
SELECT 
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_MESSAGE() AS ErrorMessage;
END CATCH
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


--**********************************************************************************************************


/****** Object:  StoredProcedure [dbo].[GetSqlJobAuditDetailsByJobID]    Script Date: 5/29/2014 12:20:52 PM ******/
SET ANSI_NULLS ON