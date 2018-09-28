CREATE PROCEDURE [dbo].[SP_GetSqlJobDetailsByJobID]( @jobID bigint)
AS

BEGIN
SET NOCOUNT ON;
BEGIN TRY
SELECT      SJ.Id                               AS JobID

            ,SJ.[Description]                         AS JobName 

            ,SBR.RuleEntity                     AS EntityName     

            ,SBR.RuleName                       AS RuleName 

            ,SBR.RuleApplicationName      AS RuleApplicationName

            ,SBR.RuleVersion              AS RuleVersion

            ,SJ.IsActive                        AS IsJobActive
            
            ,SBR.SqlCommand                     AS Query
            
            ,SBR.IsOneToManySql                 AS IsOneToMany 
			,  SJ.CountryId                     AS CountryId,
			SJ.GPSUser     AS LoggedInUser,
			SBR.JobType as JobType   

            FROM SqlBusinessRule SBR 

            INNER JOIN SqlJob SJ 

            ON SBR.Id = SJ.SQLBusinessRuleID

            Where SJ.Id = @jobID
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