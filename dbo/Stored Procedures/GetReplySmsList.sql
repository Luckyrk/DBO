GO
CREATE PROCEDURE [dbo].[GetReplySmsList] --'91390337-7506-4DD7-8D57-6999C47442EB',NULL,NULL
@pActionTaskId UniqueIdentifier,
@psenderMobileNumber NVARCHAR(100),
@punmatchedMobileNumber NVARCHAR(100)
AS
BEGIN
BEGIN TRY 
DECLARE @GetDate DATETIME
		DECLARE @CountryId UNIQUEIDENTIFIER
		SET @CountryId=(select Country_Id from actiontask  where GUIDReference=@pActionTaskId )
		SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryId))

Declare @SenderId nvarchar(4000)
IF(@psenderMobileNumber IS NULL)
BEGIN

select @SenderId=TD.SenderId from 
DocumentActionTaskAssociation  dta
join TextDocument TD ON TD.DocumentId=dta.DocumentId
WHERE dta.ActionTaskId=@pActionTaskId


	select 1 AS isIncoming,TD.Message,TD.CreationTimeStamp  from  --Incoming Messages
	TextDocument TD 
	WHERE TD.SenderId=@SenderId
	AND CAST(Td.CreationTimeStamp AS DATE)>=CAST(DATEADD(DD,-30,@GetDate) AS DATE)
	
	UNION

	select 0 AS isIncoming, TD.Message,TD.CreationTimeStamp  from  --OutGoing Messages
	TextDocument TD 
	WHERE TD.Recipient=@SenderId
	AND CAST(Td.CreationTimeStamp AS DATE)>=CAST(DATEADD(DD,-30,@GetDate) AS DATE)
	ORDER By Td.CreationTimeStamp DESC
END
ELSE
BEGIN
	select 1 AS isIncoming,TD.Message,TD.CreationTimeStamp  from 
	TextDocument TD 
	WHERE TD.SenderId=@psenderMobileNumber
	AND TD.Recipient=@punmatchedMobileNumber
	ORDER By Td.CreationTimeStamp DESC
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
GO