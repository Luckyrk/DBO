CREATE procedure CreateAddressCardCloseAction @pCandidateId UNIQUEIDENTIFIER, @pAssigneeName varchar(50),@pActionComment varchar(50), @pActionDate DATETIME, @pCountryId UNIQUEIDENTIFIER, @pPanelId UNIQUEIDENTIFIER  
AS      
BEGIN   
BEGIN TRY    
 SET NOCOUNT ON    
  IF (@pPanelId='00000000-0000-0000-0000-000000000000')
 BEGIN
	SET @pPanelId=NULL
 END  
    
DECLARE @ActiontaskId UNIQUEIDENTIFIER = newid();    
DECLARE @countryid UNIQUEIDENTIFIER;    
DECLARE @TypeTranslationid UNIQUEIDENTIFIER;    
DECLARE @TranslaionIds UNIQUEIDENTIFIER;    
DECLARE @AssigneeId UNIQUEIDENTIFIER;    
DECLARE @GUIDRefActionTask UNIQUEIDENTIFIER;  
set  @AssigneeId = (Select Id from IdentityUser where UserName = @pAssigneeName AND Country_Id=@pCountryId )    
set @TranslaionIds = (select TranslationId from Translation where KeyName = 'AddressChanges')    
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
    WHERE [Key] = 'AddressCardchange'    
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
           ,@pActionDate    
           ,@pActionDate    
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
      ,@pActionDate    
      ,@pActionDate    
      ,@pActionDate    
      ,@pActionComment    
      ,0    
      ,@pAssigneeName    
      ,@pActionDate    
      ,@pActionDate    
      ,4    
      ,NULL    
      ,@GUIDRefActionTask
      ,@pCandidateId    
      ,@pCountryId    
      ,NULL    
      ,@AssigneeId    
      ,@pPanelId    
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
