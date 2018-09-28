



CREATE PROCEDURE [dbo].[SP_GetSqlJobDetails]
	 
AS
BEGIN

---------------------------------------------------------------------------------------------------------------------------------------------------------
  -- Database  Name   : GPS_Dev
  -- Procedure Name   : [GetSqlJobDetails]
  -- Description      : This Proc is called to retrieve all Sql Job details to show it in the landing page of SQLJobs page of BusinessRuleStudio                    
  --                    Functionality : BusinessRuleStudio-> SqlJobs Landing page
  
  -- Pre-requisite    : Table [dbo].[SqlBusinessRule]
  --				  : Table [dbo].[SqlJob]

  -- Input  Parameters: NA
  -- Output Parameters:
  -- Returns          : Data set of SQLJobDetails 

  -- Code Example     : 
  /*                                            
    ----------------------------------------------------------------------------     
    Exec GPS_Dev.dbo.[GetSqlJobDetails]                                             
    ---------------------------------------------------------------------------- 
	*/
SET NOCOUNT ON;

SELECT	SJ.Id						AS JobID
		,SJ.[Description]					AS JobName 
		,SBR.RuleEntity				AS EntityName	
		,SBR.RuleName				AS RuleName 
		,SBR.RuleApplicationName	AS RuleApplicationName
		,SBR.RuleVersion			AS RuleVersion
		,SJ.IsActive				AS IsJobActive		
		FROM SqlBusinessRule SBR 
		INNER JOIN SqlJob SJ 
		ON SBR.Id = SJ.SQLBusinessRuleID
END