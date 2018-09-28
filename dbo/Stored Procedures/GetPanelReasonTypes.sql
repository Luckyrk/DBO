GO
/*##########################################################################
-- Name             : GetPanelReasonTypes
-- Date             : 2014-12-04
-- Author           : Jagadeesh B
-- Purpose          : To Get the Scheduled Action Tasks
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
       @pCountryCode UNIQUEIDENTIFIER 
       @pCultureCode int  - Culture Code of type int
	   @pPanelId UNIQUEIDENTIFIER
SET STATISTICS time OFF
EXEC GetPanelReasonTypes NULL,'17D348D8-A08D-CE7A-CB8C-08CF81794A86',2057
SELECT * FROM Country
##########################################################################
-- version  user                                       date        change 
-- 1.0     Jagadeesh B                            2014-11-27   Initial
##########################################################################*/
CREATE PROCEDURE [dbo].[GetPanelReasonTypes]
(
@pPanelId UNIQUEIDENTIFIER
,@pCountryId UNIQUEIDENTIFIER
,@pCultureCode int

)
AS
BEGIN
BEGIN TRY
SELECT * FROM (
SELECT 
 GUIDReference as Id,
IsDealtByCommunicationTeam,
IsForFqs,
CommEventReasonCode as Code,
dbo.GetTranslationValue(TagTranslation_Id, @pCultureCode) AS TagValue,
CAST(CommEventReasonCode AS NVARCHAR)+dbo.GetTranslationValue(DescriptionTranslation_Id, @pCultureCode) AS DescriptionValue
FROM
CommunicationEventReasonType CRT
LEFT OUTER JOIN CommunicationEventReasonTypePanel CRTP ON CRT.GUIDReference=CRTP.CommunicationEventReasonType_Id
WHERE IsClosed=0 AND IsDealtByCommunicationTeam=1  AND Country_Id=@pCountryId
AND 
         NOT EXISTS
         (
           SELECT 1 FROM CommunicationEventReasonTypePanel WHERE CommunicationEventReasonType_Id=CRT.GUIDReference
         )

UNION

SELECT 
 GUIDReference as Id,
IsDealtByCommunicationTeam,
IsForFqs,
CommEventReasonCode as Code,
dbo.GetTranslationValue(TagTranslation_Id, @pCultureCode) AS TagValue,
CAST(CommEventReasonCode AS NVARCHAR)+dbo.GetTranslationValue(DescriptionTranslation_Id, @pCultureCode) AS DescriptionValue
FROM
CommunicationEventReasonType CRT 
INNER JOIN CommunicationEventReasonTypePanel CRTP ON CRT.GUIDReference=CRTP.CommunicationEventReasonType_Id AND CRTP.Panel_Id=@pPanelId
WHERE Country_Id=@pCountryId AND CRT.IsClosed=0 AND CRT.IsDealtByCommunicationTeam=1
) TEMP
ORDER BY Code
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH 
END
GO