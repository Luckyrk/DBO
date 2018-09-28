CREATE PROCEDURE GetActionReasonType
(
@pCommEventReasonCode INT=NULL

,@pRelatedActionTypeId UNIQUEIDENTIFIER=NULL

,@pCountryId UNIQUEIDENTIFIER

,@pCultureCode int

)

AS

BEGIN
BEGIN TRY 
IF @pRelatedActionTypeId is NULL or @pRelatedActionTypeId ='00000000-0000-0000-0000-000000000000'
BEGIN
select top 1 CommEventReasonCode as ReasonCode,dbo.GetTranslationValue(CER.TagTranslation_Id, @pCultureCode) as ReasonName,CER.GUIDReference as ReasonTypeId from CommunicationEventReasonType CER
INNER JOIN Translation T ON T.Translationid=CER.TagTranslation_Id
INNER JOIN TranslationTerm TT ON TT.Translation_id=T.Translationid
 where CommEventReasonCode=@pCommEventReasonCode and CultureCode=@pCultureCode AND CER.Country_Id = @pCountryId

 END
 ELSE

 BEGIN
 select top 1 CER.CommEventReasonCode as ReasonCode ,dbo.GetTranslationValue(CER.TagTranslation_Id,@pCultureCode) as ReasonName,CER.GUIDReference as ReasonTypeId
  From CommunicationEventReasonType CER join CommunicationEventReasonTypeActionTaskType CERAT
on CER.GUIDReference=CERAT.CommunicationEventReasonType_Id join ActionTaskType AT
on CERAT.ActionTaskType_Id=AT.GUIDReference
where CERAT.ActionTaskType_Id=@pRelatedActionTypeId 

 END
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

