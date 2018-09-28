CREATE PROCEDURE UpdateExclusionsDetails(
       @pRangeTo DATETIME
	   ,@pRangeFrom DATETIME
      ,@pExclusionId UNIQUEIDENTIFIER
       ,@pIndividual_Id VARCHAR(15)
       ,@pCountryCode VARCHAR(10)
       )

AS
BEGIN
       SET NOCOUNT ON
	   BEGIN TRY
       DECLARE @countryid UNIQUEIDENTIFIER =(SELECT TOP 1 CountryId FROM country WHERE CountryISO2A=@pCountryCode)
       DECLARE @individualid UNIQUEIDENTIFIER=(SELECT TOP 1 GUIDReference FROM Individual WHERE IndividualId=@pIndividual_Id and CountryId=@countryid)

              UPDATE Exclusion

              SET [Range_To] = @pRangeTo , [Range_From] = @pRangeFrom

              WHERE [Type_Id]  = @pExclusionId

                     AND Parent_Id = @individualid
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