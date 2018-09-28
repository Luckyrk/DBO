
CREATE PROCEDURE [dbo].[SP_UpdateSqlJob]
@jobID as bigint,
@query as nvarchar(MAX),  
@isOneToMany as bit,  
@ruleApplicationName as nvarchar (100),  
@ruleName as nvarchar (100),  
@entityName as nvarchar (100),  
@ruleVersion as int,  
@isJobActive as bit,  
@description as nvarchar (200),
@countryId as uniqueidentifier,
@loggedInUser as nvarchar(50) 
  
As   
BEGIN  
BEGIN TRY 
---------------------------------------------------------------------------------------------------------------------------------------------------------
  -- Database  Name   : GPS_Dev
  -- Procedure Name   : [UpdateSqlJob]
  -- Created By		  : NagaRamesh Thirlaka
  -- Created On		  : 21st May 2014
  -- Description      : This Proc is called to update the SqlJob and SqlBusinessRule tables for a given JobId                    
  --                    Functionality : BusinessRuleStudio-> SqlJobs ->EditRule ->CreateJob- UpdateJob click
  
  -- Pre-requisite    : Table [dbo].[SqlBusinessRule]
  --				  : Table [dbo].[SqlJob]

  -- Input  Parameters: @JobID as bigint,
  --					@JobCode as int,
  --					@Query as nvarchar(500),  
  --					@IsOneToMany as bit,  
  --					@RuleApplicationName as nvarchar (100),  
  --					@RuleName as nvarchar (100),  
  --					@EntityName as nvarchar (100),  
  --					@RuleVersion as int,  
  --					@IsJobActive as bit,  
  --					@Description as nvarchar (200)
  -- Output Parameters:
  -- Returns          : Data set of SQLJobDetails 

  -- Code Example     : 
  /*                                            
    ----------------------------------------------------------------------------     
    Exec GPS_Dev_Tool.dbo.[UpdateSqlJob] @JobID = 2  
									,@JobCode ='J2' 
									,@Query='select * from jobrule'                                           
									,@IsOneToMany = 1
									,@RuleApplicationName = 'BASE_APP'
									,@RuleName = 'SQLAPP'
									,@EntityName = 'Panelist'
									,@RuleVersion = 1
									,@IsJobActive = 1
									,@Description = 'CheckMail'
    ---------------------------------------------------------------------------- 
	*/
	
DECLARE @sqlBusinessRuleId as bigint


Declare @GetDate DATETIME
SET @GetDate=(Select dbo.GetLocalDateTimeByCountryId(GETDATE(),CountryId) from SqlJob  WHERE Id=@jobID)
  
BEGIN TRY  
BEGIN TRAN  
----updating the data to [SqlJob]
UPDATE [dbo].[SqlJob]
   SET [IsActive] = @isJobActive   
      ,[Description] = @description      
      ,[GPSUser] = @loggedInUser
	  ,[CountryId] = @countryId
	  ,GPSUpdateTimestamp = @GetDate
 WHERE Id = @jobID

  
SELECT @sqlBusinessRuleId = SQLBusinessRuleID from SqlJob WHERE Id = @jobID

--updating the data to [SqlBusinessRule]
UPDATE [dbo].[SqlBusinessRule]
   SET [SqlCommand] = @query
      ,[IsOneToManySql] = @isOneToMany
      ,[RuleApplicationName] = @ruleApplicationName
      ,[RuleName] = @ruleName
      ,[RuleEntity] = @entityName
      ,[RuleVersion] = @ruleVersion     
      ,[GPSUser]	= @loggedInUser
	  ,GPSUpdateTimestamp = @GetDate
 WHERE Id = @sqlBusinessRuleId

  
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