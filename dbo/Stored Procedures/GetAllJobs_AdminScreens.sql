GO
Create PROCEDURE [dbo].[GetAllJobs_AdminScreen] (
        @pCountryCode varchar(100)
       )
AS
BEGIN
SELECT DISTINCT JobCategoryNum AS JobNumber
	,JobCategory AS JobCategory
FROM JobCategoryList END




