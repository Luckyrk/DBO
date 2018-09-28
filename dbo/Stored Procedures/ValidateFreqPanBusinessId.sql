GO
CREATE Procedure [dbo].[ValidateFreqPanBusinessId]
@pbusinessId VARCHAR(100),
@pCountryId UNIQUEIDENTIFIER
AS
BEGIN
IF NOT EXISTS(SELECT Top 1  1 FROM Individual WHERE  IndividualId=@pbusinessId AND CountryId=@pCountryId)
BEGIN
   SELECT 0 AS Success,'Invalid businessId.' AS [Message],@pbusinessId AS BusinessId
END
ELSE
BEGIN

	DECLARE @pidfoyer INT,@ppan_no_individu INT
	SET @pidfoyer = (SELECT TOp 1  items FROM dbo.Split(@pbusinessId,'-') WHERE Id=1)
	SET @ppan_no_individu=(SELECT TOp 1  items FROM dbo.Split(@pbusinessId,'-') WHERE Id=2)

	IF EXISTS(
					  SELECT 1 FROM 
					  FRS.FREQUENTER_PAN_USI T2 WHERE T2.idfoyer=@pidfoyer AND T2.pan_no_individu=@ppan_no_individu-- AND T2.usi_code=T1.usi_code
				  )
		BEGIN
			SELECT 0 AS Success,'Some of the records already Exists. Please use the update screen.' AS [Message],'' AS BusinessId
		END
	ELSE 
	BEGIN
	   SELECT 1 AS Success,'Sucess' AS [Message],@pbusinessId AS BusinessId
	END
END
END
GO