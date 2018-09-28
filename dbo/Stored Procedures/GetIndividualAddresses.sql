CREATE PROCEDURE [dbo].[GetIndividualAddresses] 
	 @pBusinessId UNIQUEIDENTIFIER
	,@pCountryID UNIQUEIDENTIFIER
	,@pCultureCode Int
AS
BEGIN

	SET NOCOUNT ON
	DECLARE @AddressType1 NVARCHAR(50) --postaladdress
	DECLARE @AddressType2 NVARCHAR(50) --phone address
	DECLARE @AddressType3 NVARCHAR(50) --electronic adddress
	DECLARE @DiscriminatorType NVARCHAR(256)
	DECLARE @Order INT
	SET @AddressType1 = 'PostalAddress'
	SET @AddressType2 = 'PhoneAddress'
	SET @AddressType3 = 'ElectronicAddress'
	SET @DiscriminatorType = 'PostalAddressType'
	SET @Order = 1
	--Individual to Geographic Area
	SELECT I.GUIDReference AS CandidateId
		,IndividualId AS BusinessId
		,G.GUIDReference AS Id
		,G.Code AS GeographicAreaCode
		,dbo.GetTranslationValue(G.Translation_Id, @pCultureCode) AS Description
		,G.CreationTimeStamp
	FROM Individual I
	INNER JOIN Candidate C ON I.GUIDReference = c.GUIDReference
	LEFT JOIN KeyAppSetting KA ON KA.KeyName = 'ShowGeographicArea'
	LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id = KA.GUIDReference AND KV.Country_Id = I.CountryId
	LEFT JOIN GeographicArea G ON G.GUIDReference = C.GeographicArea_Id AND ISNULL(KV.Value, KA.DefaultValue) IN ('0', 'false')
	WHERE I.GUIDReference = @pBusinessId

	--PostalAddress
	
	EXEC GetPostalAddress @pCultureCode,@pBusinessId,@AddressType1,@Order

	--PhoneAddress
	CREATE TABLE #TEMP
(
AddressLine1 NVARCHAR(400),
Id UniqueIdentifier,
DescriptionKey NVARCHAR(200),
[Description]	 NVARCHAR(200),
AddressTypeId	UniqueIdentifier
)

CREATE TABLE #PHONETEMP
(
AddressLine1 NVARCHAR(400),
Id UniqueIdentifier,
DescriptionKey NVARCHAR(200),
[Description]	 NVARCHAR(200),
AddressTypeId	UniqueIdentifier
)

	INSERT INTO #TEMP
	EXEC GetPhoneorElectronicAddress @pCultureCode
		,@pBusinessId
		,@AddressType2
	SELECT * FROM #TEMP

	INSERT INTO #PHONETEMP
	EXEC GetPhoneorElectronicAddress @pCultureCode
		,@pBusinessId
		,@AddressType2	
		
	--ElectronicAddress
	DELETE FROM #TEMP
	INSERT INTO #TEMP
	EXEC GetPhoneorElectronicAddress @pCultureCode
		,@pBusinessId
		,@AddressType3
	SELECT * FROM #TEMP
	
	--PostalAddress
	EXEC GetPostalAddress @pCultureCode
		,@pBusinessId
		,@AddressType1
		,Null


	--PostalAddressTypes
	SELECT AT.Id
		,dbo.GetTranslationValue(AT.Description_Id, @pCultureCode) AS Description
	FROM AddressType AT
		WHERE At.DiscriminatorType = @DiscriminatorType
	-- Templates List
	
	SELECT DISTINCT TD.TemplateMessageDefinitionId AS Id
		,TD.[Description] AS NAME
	FROM TemplateMessageDefinition TD
	JOIN TemplateMessageConfiguration TMC ON TD.TemplateMessageDefinitionId = TMC.TemplateMessageDefinitionId
	JOIN TemplateMessageScheme TMS ON TMC.TemplateMessageSchemeId = TMS.TemplateMessageSchemeId	
	JOIN CollectiveMembership CM ON CM.Individual_Id=@pBusinessId
	JOIN Panel P ON P.Name=TMS.[Description] AND P.Country_Id=TMS.CountryId
	JOIN Panelist PanInd ON PanInd.Panel_Id=P.GUIDReference AND PanInd.PanelMember_Id IN (CM.Individual_Id, CM.Group_Id)	
	AND TD.TemplateUsageIntentId=1 AND TMC.CommsMessageTemplateTypeId=1	

	SELECT (
			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryID, 'SmsIconBtn', 0)
			) AS IsSmsButtonVisible
				SELECT (
			SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryID, 'AddressHistoryBtn', 0)
			) AS IsAddressHistoryBtn
declare @UrlId Nvarchar(1000)
	set @UrlId=(select 
	 KV.Value
		from KeyAppSetting KS
		LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryID
		WHERE KS.KeyName='AddressReportPath')

		if try_cast(@UrlId as uniqueidentifier) IS NOT NULL
		begin
		select ReportPath  from Reports where ReportsId =cast(@UrlId as uniqueidentifier)
		end

		else
		begin
		select DefaultValue   from KeyAppSetting where KeyName='AddressReportPath'
		end
		declare @typeId int 
set @typeId=(select CommsMessageTemplateTypeId from 	CommsMessageTemplateType where [Description]='Email')
select TemplateMessageCategoryId as CategoryTypeId,Description as CategoryTypeDesc from TemplateMessageCategories where CommsMessageTemplateType_Id=@typeId and CountryId=@pCountryID
	DECLARE @AddressTypeMobile BIT=0
IF( (SELECT TOP 1  DescriptionKey FROM #PHONETEMP)='MobilePhoneType')
BEGIN
	set @AddressTypeMobile=1
END
SELECT @AddressTypeMobile AS IsAddressTypeMobile
DECLARE @GroupId VARCHAR(100)
	DECLARE @GroupBusinessDigits INT
	
	SELECT @GroupBusinessDigits = GroupBusinessIdDigits
	FROM CountryConfiguration
	WHERE Id = (SELECT Configuration_Id FROM Country WHERE CountryId=@pCountryID)
		
	SELECT TOP 1 @GroupId = (CASE WHEN LEN(C.Sequence) < @GroupBusinessDigits
			THEN RIGHT(REPLICATE('0', @GroupBusinessDigits), (@GroupBusinessDigits - LEN(C.Sequence))) + CAST(C.Sequence AS NVARCHAR)
			ELSE CAST(C.Sequence AS NVARCHAR)
			END)	
	FROM CollectiveMembership CM
	JOIN Collective C ON C.GUIDReference= CM.Group_Id
	JOIN StateDefinition SD ON CM.State_Id = SD.Id
	WHERE CM.Individual_Id = @pBusinessId AND C.CountryId = @pCountryID
	ORDER BY SD.InactiveBehavior, CM.GPSUpdateTimestamp

		SELECT (
		SELECT TOP 1 KV.Value+'/'+@GroupId+'.jpg' FROM KeyAppSetting K
					JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=K.GUIDReference
					WHERE K.KeyName='AddressImagelinkUrl' AND KV.Country_Id=@pCountryID
			) AS AddressImageUrl
DROP TABLE #TEMP
DROP TABLE #PHONETEMP
END
GO


