Create PROCEDURE [dbo].[GetInserdeDeviceSerialNumber]

@pCountryCode Varchar(2),

@pUserName Varchar(50),

@pClickerExtractionDateTime Datetime

AS

BEGIN
BEGIN TRY 
 SELECT TOP 1 CONCAT(SDM.Prefix, LTRIM(RTRIM(SerialNumber))) as SerialNumber, ISNULL(ST.Code, CAST(ST.Code AS int)) AS StockTypeCode
 FROM ClickerDevice CD
 JOIN Country CN ON CD.CountryCode = CN.CountryISO2A
 LEFT JOIN SerialNumberDeviceMapping SDM ON SDM.Country_Id = CN.CountryId AND LTRIM(RTRIM(SerialNumber)) LIKE SDM.Expression
 LEFT JOIN StockType ST ON ST.Name LIKE SDM.KitName --e.g. Stock Kit Name 'Clicker' is matched with Stock Type Name 'Clicker', in order to return the Stock Type Code
 WHERE 
	CD.CountryCode = @pCountryCode and
	CD.GPSUserName =  @pUserName and
	convert(date,CD.CreationDateTime) <= CONVERT(DATE, @pClickerExtractionDateTime) 
 ORDER BY cd.CreationDateTime DESC
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