CREATE Proc GetCommEventReasonCodesByActionType 
(
 @pActionTaskTypeId uniqueidentifier
)
AS
Begin
select CT.CommEventReasonCode as ReasonCode from CommunicationEventReasonType CT join CommunicationEventReasonTypeActionTaskType CTAT
on CTAT.CommunicationEventReasonType_Id=CT.GUIDReference join ActionTaskType AT
on CTAT.ActionTaskType_Id=AT.GUIDReference and AT.GUIDReference=@pActionTaskTypeId
END