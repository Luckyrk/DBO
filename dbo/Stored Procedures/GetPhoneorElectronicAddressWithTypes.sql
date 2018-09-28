/*##########################################################################
-- Name             : GetPhoneorElectronicAddressWithTypes
-- Date             : 2014-12-01
-- Author           : Jagadeesh B
-- Purpose          : To Get Phone or Electronic Address With Types 
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 

SET STATISTICS time ON
exec GetPhoneorElectronicAddressWithTypes '71232120-80C5-CA2E-F146-08D11B00459E',2057,'PhoneAddress'


##########################################################################
-- version  user                                       date        change 
-- 1.0     Jagadeesh B                            2014-12-01   Initial
-- 1.1     Matias Fernandez                       2016-30-05   Output column names change
##########################################################################*/
CREATE PROCEDURE [GetPhoneorElectronicAddressWithTypes]
(
  @pCandidateId UNIQUEIDENTIFIER,
  @pCultureCode INT,
  @pDiscriminatorType NVARCHAR(50)
)
AS
BEGIN
BEGIN TRY 
SELECT 
Id,
[dbo].[GetTranslationValue](AT.Description_Id,@pCultureCode) AS [Description],
[dbo].[GetTranslationValue](AT.Description_Id,NULL) AS DescriptionKey
FROM AddressType AT 
WHERE DiscriminatorType=@pDiscriminatorType+'Type'

	CREATE TABLE #TEMP
(
AddressLine1 NVARCHAR(400),
Id UniqueIdentifier,
DescriptionKey NVARCHAR(200),
[Description]	 NVARCHAR(200),
AddressTypeId	UniqueIdentifier
)

	INSERT INTO #TEMP
	EXEC GetPhoneorElectronicAddress @pCultureCode
		,@pCandidateId
		,@pDiscriminatorType
	SELECT * FROM #TEMP
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