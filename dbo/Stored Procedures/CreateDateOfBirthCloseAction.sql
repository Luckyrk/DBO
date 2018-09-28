--EXEC CreateDateOfBirthCloseAction '8C009AA7-FD3D-C79A-6D36-08D11B00469E','testuser',NULL,'17D348D8-A08D-CE7A-CB8C-08CF81794A86'

CREATE procedure CreateDateOfBirthCloseAction @pCandidateId UNIQUEIDENTIFIER, @pAssigneeName varchar(50),@pActionComment varchar(50), @pCountryId UNIQUEIDENTIFIER  

AS      

BEGIN      

 SET NOCOUNT ON      
BEGIN TRY 
DECLARE @ActiontaskId UNIQUEIDENTIFIER = newid();    

DECLARE @countryid UNIQUEIDENTIFIER;    

DECLARE @TypeTranslationid UNIQUEIDENTIFIER;    

DECLARE @TranslaionIds UNIQUEIDENTIFIER;    

DECLARE @AssigneeId UNIQUEIDENTIFIER;    

DECLARE @GUIDRefActionTask UNIQUEIDENTIFIER;

DECLARE @getdate DATETIME 
SET @getdate = (select dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId))

set  @AssigneeId = (Select Id from IdentityUser where UserName = @pAssigneeName AND Country_Id=@pCountryId)    

set @TranslaionIds = (select TranslationId from Translation where KeyName = 'DateOfBirthChanges')    

set @TypeTranslationid = (select TranslationId  from Translation where KeyName ='DealtByCommunicationTeamActionTaskTypeTypeDescriptor')    

 set @GUIDRefActionTask = (    

            SELECT GUIDReference     
     FROM ActionTaskType axc     

            WHERE TagTranslation_Id =  @TranslaionIds and axc.Country_Id = @pCountryId    
          )    


 IF (    
 
   @pCountryId IN (    

    SELECT C.CountryId    

    FROM FieldConfiguration FC    

    INNER JOIN Country C ON C.Configuration_Id = FC.CountryConfiguration_Id    

    WHERE [Key] = 'DateOfBirthChange'    

     AND [Visible] = 1    

    )    

   )  

  BEGIN  

IF NOT EXISTS(SELECT 1 FROM ActionTaskType WHERE [TagTranslation_Id]=@TranslaionIds AND [Country_Id]=@pCountryId)    

BEGIN  


SET @GUIDRefActionTask=NEWID()

INSERT INTO [dbo].[ActionTaskType]    

           ([GUIDReference]    

           ,[IsForDpa]    

           ,[IsForFqs]    

           ,[GPSUser]    

           ,[GPSUpdateTimestamp]    

           ,[CreationTimeStamp]    

           ,[Duration]    

           ,[TagTranslation_Id]    

           ,[DescriptionTranslation_Id]    

           ,[TypeTranslation_Id]    

           ,[Country_Id]    

           ,[Type]    

           ,[IsClosed])    

     VALUES    

   (NEWID()    
 ,0    

 ,0    
 ,@pAssigneeName    
 ,@getdate    
 ,@getdate   
 ,null    
 ,@TranslaionIds    
,@TranslaionIds    
  ,@TypeTranslationid    
  ,@pCountryId    

  ,'DealtByCommunicationTeam'    
,0)    

END    

IF(@GUIDRefActionTask IS NOT NULL)

BEGIN

       INSERT INTO [dbo].[ActionTask] (    



      [GUIDReference]    



      ,[StartDate]    



      ,[EndDate]    



      ,[CompletionDate]    



      ,[ActionComment]    



      ,[InternalOrExternal]    



      ,[GPSUser]    



      ,[GPSUpdateTimestamp]    



      ,[CreationTimeStamp]    



      ,[State]    



      ,[CommunicationCompletion_Id]    



      ,[ActionTaskType_Id]    



      ,[Candidate_Id]    



      ,[Country_Id]    



      ,[FormId]    



      ,[Assignee_Id]    



      ,[Panel_Id]    



      )    



VALUES (    



      @ActiontaskId    



      ,@getdate    



      ,@getdate   



      ,@getdate    



      ,@pActionComment    



      ,0    



      ,@pAssigneeName    



      ,@getdate    



      ,@getdate    



      ,4    



      ,NULL    



      ,@GUIDRefActionTask



      ,@pCandidateId    



      ,@pCountryId    



      ,NULL    



      ,@AssigneeId    



      ,NULL    



      )    



END    



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