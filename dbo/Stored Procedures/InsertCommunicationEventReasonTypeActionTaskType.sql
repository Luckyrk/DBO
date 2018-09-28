CREATE PROCEDURE InsertCommunicationEventReasonTypeActionTaskType_1
(
@pResonTypeId UNIQUEIDENTIFIER =NULL
,@pcommunicationEventActionTypeId UNIQUEIDENTIFIER=NULL
)
AS
BEGIN


IF NOT EXISTS (SELECT 1 FROM CommunicationEventReasonTypeActionTaskType where ActionTaskType_Id=@pcommunicationEventActionTypeId and CommunicationEventReasonType_Id=@pResonTypeId)
BEGIN
   INSERT INTO CommunicationEventReasonTypeActionTaskType(CommunicationEventReasonType_Id,ActionTaskType_Id)  values(@pResonTypeId,@pcommunicationEventActionTypeId ) 
END

END



