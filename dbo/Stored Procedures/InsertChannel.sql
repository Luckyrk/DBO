CREATE PROCEDURE InsertChannel (
	@pChannelCode SMALLINT
	,@pChannelName NVARCHAR(40)
	,@pUser NVARCHAR(50)
	)
AS
BEGIN

	DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),'FR'))

	INSERT INTO [FRS].[CIRCUIT_VENTE] (
		[civ_cd_circ_vente]
		,[civ_lb_circ_vente]
		,[GPSUser]
		,[GPSUpdateTimestamp]
		,[CreationTimeStamp]
		)
	VALUES (
		@pChannelCode
		,@pChannelName
		,@pUser
		,@Getdate
		,@Getdate
		)
END