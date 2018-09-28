
Create procedure AccessoriesGridSave_AdminScreen(
@pName varchar(max)
,@pCode int
,@pQuantity int
,@pStockKitCode int
,@pCategory_Id uniqueidentifier 
 ,@pBehavior_Id uniqueidentifier 
 ,@pCountryISO2A nvarchar(30)
,@pGpsUser nvarchar(max)
,@pOldCode int
,@oldkitname varchar(max)
,@oldKitTypeName varchar(max)
,@oldname varchar(max)

 
 )
As
Begin
BEGIN TRY 

DECLARE @err bit
declare @err1 bit
Declare @newkitcode int
Declare @oldkitCode int 
 Declare @oldstockkitId uniqueidentifier
Declare @CountryId uniqueidentifier =(Select CountryId from country where CountryISO2A=@pCountryISO2A)
Declare @StockkitId uniqueidentifier
Declare @StockTypeid uniqueidentifier 
 declare @respondentId uniqueidentifier= NEWID()
DECLARE @GetDate DATETIME
Declare @CodeExistsError VARCHAR(max)='Given Code  ('+ (SELECT CONVERT(varchar(max), @pCode)) +') Already Exists Please Give New Code'
Declare @nameExistsError varchar (max)='Given name ('+ (SELECT CONVERT(varchar(max), @pName)) +') Already Exists With Same KitName Give New Name'
       set @newkitcode =(select top 1 code from StockKit where Name=@pName and Country_Id=@CountryId)
       set @StockkitId = (select top 1 GUIDReference from StockKit where code = @pStockKitCode and Country_Id=@CountryId )
       SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryId))
          set @oldkitCode =(select top 1 Code from stockkit where Name=@oldkitname and Country_Id=@CountryId)
          set @oldstockkitId =(select Top 1 GUIDReference from StockKit where code = @oldkitCode  and Country_Id=@CountryId)
          set @err=0
          set @err1=0
          set @pName = ltrim(rtrim(@pName))
          


          if((@oldkitCode=@pStockKitCode) and (@oldname=@pName))
          BEGIN
          set @err1=0
          END
          else
          BEGIn
          set @err1=1;
          END

          --if(@pName = @oldKitTypeName)
          --BEGIN
               if((@err1=1) or (@pOldCode=0))
               if  exists (SELECT top 1 st.name FROM StockKitItem ski 
                           inner join stockkit kit on kit.GUIDReference=ski.StockKit_Id
                           inner join stocktype st on st.GUIDReference=ski.StockType_Id
                           inner join country c on c.CountryId=kit.Country_Id
                           where st.name =@pName and kit.GUIDReference=@StockkitId and kit.Country_Id=@CountryId)
                                         BEGIN
                                         set @err =1
                                                       RAISERROR (
                                                       @nameExistsError
                                                       ,16
                                                       ,1
                                                       );
                           
                                         END
                                         ELSE
                                         BEGIN
                                           set @err =0
                                         END
         -- END


         -- ELSE
         --          BEGIN
                     --        if  exists (SELECT st.name FROM StockKitItem ski 
                     --     inner join stockkit kit on kit.GUIDReference=ski.StockKit_Id
                     --     inner join stocktype st on st.GUIDReference=ski.StockType_Id
                     --     inner join country c on c.CountryId=kit.Country_Id
                     --     where st.name =@pName and kit.GUIDReference=@StockkitId)
                     --                   BEGIN
                     --                   set @err =1
                     --                                RAISERROR (
                     --                                @nameExistsError
                     --                                ,16
                     --                                ,1
                     --                                );
                           
                     --                   END
                     --                   ELSE
                     --                   BEGIN
                     --                     set @err =0
                     --                   END

                     --END
       




       
       

       




if (@err = 0)
BEGIN
if exists (select top 1 code from StockType where code =@pOldCode and CountryId=@CountryId)
       begin
--update
        if  (@pCode=@pOldCode)
              BEGIN
                           


                     set @StockTypeid = (select top 1 GUIDReference from StockType where code = @pOldCode and CountryId=@CountryId)
                     Update StockType set Name=@pName,Code=@pCode,Category_Id=@pCategory_Id,Behavior_Id=@pBehavior_Id,GPSUpdateTimestamp=@GetDate where Code =@pOldCode and countryid =@CountryId
                     update StockKitItem set Quantity = @pQuantity,StockKit_Id=@StockkitId,GPSUpdateTimestamp=@GetDate where StockType_Id=@StockTypeid and StockKit_Id=@oldstockkitId and Country_Id=@CountryId
              END
              Else
              BEGIN
              if exists (select top 1 code from StockType where code =@pCode and CountryId=@CountryId)
                RAISERROR (
                           @CodeExistsError
                           ,16
                           ,1
                           );
                           Else
                                  BEGIN
                           
                               set @StockTypeid = (select top 1 GUIDReference from StockType where code = @pOldCode and CountryId=@CountryId)
                                  Update StockType set Name=@pName,Code=@pCode,Category_Id=@pCategory_Id,Behavior_Id=@pBehavior_Id,GPSUpdateTimestamp=@GetDate where Code =@pOldCode and countryid =@CountryId
                                  update StockKitItem set Quantity = @pQuantity,StockKit_Id=@StockkitId ,GPSUpdateTimestamp=@GetDate where StockType_Id=@StockTypeid and StockKit_Id=@oldstockkitId and Country_Id=@CountryId
                                  END
              END
       END


Else
       Begin
              
--insert
              if exists (select top 1 code from StockType where code =@pCode and CountryId=@CountryId)
                           Begin
                           
                                  RAISERROR (

                           @CodeExistsError

                           ,16

                           ,1

                           );
                           END                  
              Else
                                  BEGIN
                                  
                                         
                                         insert into Respondent(GUIDReference,DiscriminatorType,CountryID,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) values(@respondentId,'StockType',@CountryId,@pGpsUser,@GetDate,@GetDate)

                                         Declare @StocktypeGuid uniqueidentifier 
                                         set @StocktypeGuid =(select top 1 R.GUIDReference from Respondent   R 
                                         where GUIDReference not in (select GUIDReference from StockType) and R.DiscriminatorType='StockType' )
                                         Insert into stocktype (GUIDReference,Category_Id,Behavior_Id,Code,CountryId,Name,Quantity,WarningLimit,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,ReportsId) values(@respondentId,@pCategory_Id,@pBehavior_Id,@pCode,@CountryId,@pName,NULL,NULL,@pGpsUser,@GetDate,@GetDate,NULL)
                                         Insert into stockkititem values(newid(),@pQuantity,@pGpsUser,@GetDate,@GetDate,@StockkitId,@respondentId,@CountryId) 
                                  END
       END
       END

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
Go



