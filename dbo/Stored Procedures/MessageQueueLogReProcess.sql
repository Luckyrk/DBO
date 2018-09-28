CREATE PROCEDURE [dbo].[MessageQueueLogReProcess]
(
 @pRecordsReProcessInterVal INT=24
)
AS
BEGIN
 
DECLARE @MorphesAppUserContext AS NVARCHAR(MAX) ='MorphesAppUserContext'
DECLARE @MorphesAppUserContextId UNIQUEIDENTIFIER

SELECT @MorphesAppUserContextId=NamedAliasContextId 
FROM NamedAliasContext NAC INNER JOIN Country C ON C.CountryId=NAC.Country_Id
WHERE C.CountryISO2A='MH' AND Name=@MorphesAppUserContext

DECLARE @Tbl TABLE 
(
	MessageId UNIQUEIDENTIFIER,
	AppUserGUID NVARCHAR(MAX),
	QueueId NVARCHAR(MAX),
	MessageBody NVARCHAR(MAX),
	MessageStatus INT,
	CountryCode VARCHAR(10),
	CreationTimeStamp DATETIME
)

INSERT INTO @Tbl (MessageId,AppUserGUID,QueueId,MessageBody,MessageStatus,CountryCode,CreationTimeStamp)
select 
qlogs.MessageId,
substring (qlogs.MessageBody, CHARINDEX ('AppUserGUID":"',qlogs.MessageBody) + Len('AppUserGUID":"' ),(CHARINDEX('"',substring (qlogs.MessageBody, CHARINDEX ('AppUserGUID":"',qlogs.MessageBody) + Len('AppUserGUID":"' ),Len(qlogs.MessageBody))))-1) as AppUserGUID
--substring (qlogs.MessageBody, CHARINDEX ('AppUserGUID":"',qlogs.MessageBody) + Len('AppUserGUID":"' )-1,(CHARINDEX('"',substring (qlogs.MessageBody, CHARINDEX ('AppUserGUID":"',qlogs.MessageBody) + Len('AppUserGUID":"' ),Len(qlogs.MessageBody))))+1) as AppUserGUID
,qlogs.QueueId
,qlogs.MessageBody
,qlogs.MessageStatus
,qlogs.CountryCode
,qlogs.CreationTimeStamp
from 
[MorpheusErrorLog]  elogs  WITH (NOLOCK)   inner join [MorpheusQueueLog] qlogs WITH (NOLOCK)  on elogs.MessageId=qlogs.MessageId
where elogs.ErrorMessage like 'AppUserGUID NOT FOUND%' AND qlogs.[MessageStatus]<>1
	  AND qlogs.CreationTimeStamp>=DATEADD(HOUR, - @pRecordsReProcessInterVal, GETDATE())

select MessageId,QueueId,MessageBody,MessageStatus,CountryCode,t.CreationTimeStamp
from 
@Tbl t inner join NamedAlias na on na.[Key]=t.AppUserGUID 
WHERE na.AliasContext_Id=@MorphesAppUserContextId
ORDER BY t.CreationTimeStamp ASC

END