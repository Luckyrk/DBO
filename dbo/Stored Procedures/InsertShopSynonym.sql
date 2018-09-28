GO
CREATE PROC [dbo].[InsertShopSynonym]
(
@pShopCode int,
@pShopShortName nvarchar(100),
@pSynonym nvarchar(150),
@pUser nvarchar(100)
)
AS
Begin
declare @getDate Datetime 
SET @getdate = (select dbo.GetLocalDateTime(GETDATE(),'FR'))
Declare @Shortname VARCHAR(100)
IF(CHARINDEX('-',@pShopShortName)>0)
BEGIN
 SET @Shortname=(SELECT items FROM dbo.Split(@pShopShortName,'-') WHERE Id=2)
END
ELSE 
BEGIN
SET @Shortname=@pShopShortName
END
INSERT INTO [FRS].[SYNONYMES_SHOP]
           ([shop_shortname]
           ,[syn_libelle]
           ,[shop_code]
           ,[syn_dt_insert]
           ,[GPSUser]
           ,[GPSUpdateTimestamp]
           ,[CreationTimeStamp])
     VALUES
           (
			@Shortname
           ,@pSynonym
           ,@pShopCode
           ,@getDate
           ,@pUser
           ,@getDate
           ,@getDate

		   )
End
GO