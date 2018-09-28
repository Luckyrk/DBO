
Create PROCEDURE CreatePreallocatedDemographics
@pdemoGraphicList  PreallocatedDemographics READONLY,
@LocalOffice VARCHAR(100)
,@CountryCode VARCHAR(10)
,@GpsUser VARCHAR(100)
,@GPSDateTime DATETIME
	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CityDemographicGUID UniqueIdentifier,@OfficeDemographicGUID UniqueIdentifier,@CountryGUID UniqueIdentifier
	SELECT @CountryGUID=CountryId FROM Country WHERE CountryISO2A=@CountryCode
	SELECT @CityDemographicGUID =GUIDReference FROM Attribute WHERE [Key]='City' AND Country_Id=@CountryGUID
	SELECT @OfficeDemographicGUID =GUIDReference FROM Attribute WHERE [Key]='LocalOffice' AND Country_Id=@CountryGUID

	INSERT INTO AttributeValue(GUIDReference,DemographicId,CandidateId,RespondentId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Address_Id
	,Value,ValueDesc,Country_Id,[FreeText],Discriminator,EnumDefinition_Id)
	SELECT NEWID() AS GUIDReference,@CityDemographicGUID AS DemographicId,CandidateId,NULL AS RespondentId,@GpsUser AS GPSUser,@GPSDateTime AS GPSUpdateTimestamp,@GPSDateTime AS CreationTimeStamp,NULL AS Address_Id
	,City AS Value,NULL AS ValueDesc,@CountryGUID AS Country_Id,NULL AS [FreeText],'StringAttributeValue' AS Discriminator,NULL AS EnumDefinition_Id FROM  @pdemoGraphicList
	UNION
	SELECT NEWID() AS GUIDReference,@OfficeDemographicGUID AS DemographicId,CandidateId,NULL AS RespondentId,@GpsUser AS GPSUser,@GPSDateTime AS GPSUpdateTimestamp,@GPSDateTime AS CreationTimeStamp,NULL AS Address_Id
	,@LocalOffice AS Value,NULL AS ValueDesc,@CountryGUID AS Country_Id,NULL AS [FreeText],'StringAttributeValue' AS Discriminator,NULL AS EnumDefinition_Id FROM  @pdemoGraphicList

END
GO


 
