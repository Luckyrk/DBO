CREATE PROCEDURE [dbo].[DeletePanelist_AdminScreen] (
	@IndividualId NVARCHAR(30)
	,@PanelCode INT
	,@CountryISO2A NVARCHAR(30)
	)
AS
BEGIN
   DECLARE @CountryId uniqueidentifier
   DECLARE @GPSUser varchar(100) = 'GPSUser'
  SELECT
  @CountryId = CountryId
  FROM Country
  WHERE CountryISO2A = @CountryISO2A
  DECLARE @GetDate datetime
  SET @GetDate = (SELECT
    dbo.GetLocalDateTimeByCountryId(@GetDate, @CountryId))
  SET @GetDate = GETDATE()
Declare @IsHouseHold Nvarchar(max)
DECLARE @panelistid UNIQUEIDENTIFIER
declare @Configuration_Id uniqueidentifier
set @Configuration_Id=(select Configuration_Id from Country where CountryISO2A=@CountryISO2A)
------Individual states---------
 DECLARE @IndividualCandidate AS uniqueidentifier
 DECLARE @PanelistDropoutStateId AS uniqueidentifier
 SELECT
@PanelistDropoutStateId = Id
FROM StateDefinition
WHERE Code = 'PanelistDroppedOffState'
AND Country_Id = @CountryId
SET @IndividualCandidate = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'IndividualCandidate'
  AND Country_Id = @CountryId)
-------------------------------------------------------------

--------------- Group candidate states --------------
  DECLARE @groupStatusGuid uniqueidentifier
  DECLARE @groupAssignedStatusGuid uniqueidentifier
  DECLARE @groupParticipantStatusGuid uniqueidentifier
  DECLARE @groupTerminatedStatusGuid uniqueidentifier
   DECLARE @groupCandidateStatusGuid uniqueidentifier
  SET @groupCandidateStatusGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'GroupCandidate'
  AND Country_Id = @CountryId)
SET @groupAssignedStatusGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'GroupAssigned'
  AND Country_Id = @CountryId)
  SET @groupParticipantStatusGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'GroupParticipant'
  AND Country_Id = @CountryId)
  SET @groupTerminatedStatusGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'GroupTerminated'
  AND Country_Id = @CountryId)
  SET @groupStatusGuid = (SELECT
    Id
  FROM StateDefinition
    WHERE Code = 'GroupCandidate'
  AND Country_Id = @CountryId)
  DECLARE @existingroupStatusGuid uniqueidentifier
  SET @existingroupStatusGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'GroupPreseted'
  AND Country_Id = @CountryId)
  DECLARE @MainContactGUID uniqueidentifier
  DECLARE @individualAssignedGuid uniqueidentifier
  SET @individualAssignedGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'IndividualAssigned'
  AND Country_Id = @CountryId)
  --DECLARE @individualAssignedGuid UNIQUEIDENTIFIER
  SELECT
    @MainContactGUID = DR.DynamicRoleId
  FROM DynamicRole DR
  INNER JOIN Translation TR
    ON DR.Translation_Id = TR.TranslationId
  WHERE TR.KeyName = 'MainContact'
  AND DR.Country_Id = @CountryId
  DECLARE @individualParticipent uniqueidentifier = NULL
  SET @individualParticipent = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'IndividualParticipant'
  AND Country_Id = @CountryId)
  DECLARE @individualDropOf uniqueidentifier = NULL
  SET @individualDropOf = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'IndividualTerminated'
  AND Country_Id = @CountryId)
---------------------------------------------
DECLARE @GroupBusinessIdDigits INT
SET @GroupBusinessIdDigits=(select top 1 GroupBusinessIdDigits from CountryConfiguration where Id=@Configuration_Id)
declare @IndividualIdncomingGroupBusinessIdDigits nvarchar(30)
set @IndividualIdncomingGroupBusinessIdDigits=( 
     left (@IndividualId, CHARINDEX('-',@IndividualId)-1))
	Declare @GroupBusinessIdDigitsError VARCHAR(max)='Your Sequence is not correct Please enter your ('+ (SELECT CONVERT(varchar(10), @GroupBusinessIdDigits)) +') digit SequenceID' 
	Declare @NoGroupBusinessIdDigitsError BIT
IF(@GroupBusinessIdDigits=LEN(@IndividualIdncomingGroupBusinessIdDigits))
BEGIN
SET @NoGroupBusinessIdDigitsError =1
END
else 
BEGIN
RAISERROR (
				@GroupBusinessIdDigitsError
				,16
				,1
				);
				END
if exists (select top 1 p.[type] from Panelist pl
									  join Panel p on p.GUIDReference=pl.Panel_Id
									  join collectivemembership cm on pl.panelmember_id=cm.Group_Id
									  JOIN Individual i ON i.GUIDReference = cm.Individual_id
		                              join collective ct on ct.guidreference=cm.Group_id
									  join Country c on c.CountryId=p.Country_Id where i.IndividualId =@IndividualId and c.CountryISO2A=@CountryISO2A and p.panelcode =@PanelCode)
Begin
	SET @panelistid = (
			SELECT TOP 1 pl.GUIDReference
			FROM Panelist pl
			INNER JOIN Panel p ON p.GUIDReference = pl.Panel_Id
			join collectivemembership cm on pl.panelmember_id= cm.Group_Id 
			JOIN Individual i ON i.GUIDReference = cm.Individual_id
		    join collective ct on ct.guidreference=cm.Group_id
			INNER JOIN Country c ON c.CountryId = p.Country_Id
			WHERE i.IndividualId = @IndividualId
				AND p.PanelCode = @PanelCode
				AND c.CountryISO2A = @CountryISO2A
			)
END
Else
Begin
SET @panelistid = (SELECT TOP 1 pl.GUIDReference
			FROM Panelist pl
			INNER JOIN Panel p ON p.GUIDReference = pl.Panel_Id
			join collectivemembership cm on pl.panelmember_id= cm.Individual_Id 
			JOIN Individual i ON i.GUIDReference = cm.Individual_id
		    join collective ct on ct.guidreference=cm.Group_id
			INNER JOIN Country c ON c.CountryId = p.Country_Id
			WHERE i.IndividualId = @IndividualId
				AND p.PanelCode = @PanelCode
				AND c.CountryISO2A = @CountryISO2A)
End
Declare @DPAError BIT
Declare @PSCError BIT
Declare @DPAPSCerror varchar(max) = 'This '+@IndividualId+' IndivdiualId Contains DPA  Records'
if exists (select top 1  Id from DemandedProductAnswer  WHERE Panelist_Id = @panelistid ) 
Begin
RAISERROR (
				@DPAPSCerror
				,16
				,1
				);
End
ELSE
Begin
SET @DPAError=0
End
Declare @PSCDPAerror varchar(max) = 'This '+@IndividualId+' IndivdiualId Contains PSC  Records'
if exists (select top 1  GUIDReference from PanelistSummaryCount  WHERE PanelistId = @panelistid )
Begin
RAISERROR (
				@PSCDPAerror
				,16
				,1
				);
End
ELSE
Begin
SET @PSCError=0
End
BEGIN TRANSACTION
	BEGIN TRY
if(( @DPAError=0)and (@PSCError=0) and (@NoGroupBusinessIdDigitsError =1))
BEGIN
	DELETE
	FROM [Action]
	WHERE Panelist_Id = @panelistid
	DELETE
	FROM CollaborationMethodologyHistory
	WHERE Panelist_Id = @panelistid
	DELETE
	FROM ComplianceCategoryStatus
	WHERE Panelist_Id = @panelistid
	DELETE
	FROM DemandedProductAnswer
	WHERE Panelist_Id = @panelistid
		Declare @DynamicRoleAssignmentId uniqueidentifier
        set @DynamicRoleAssignmentId = (select Top 1 DynamicRoleAssignmentId from DynamicRoleAssignment where Panelist_Id=@panelistid)
	    delete from DynamicRoleAssignmentHistory where DynamicRoleAssignment_Id =@DynamicRoleAssignmentId
	DELETE
	FROM DynamicRoleAssignment
	WHERE Panelist_Id = @panelistid
	DELETE
	FROM ExclusionPanelist
	WHERE Panelist_Id = @panelistid
	DELETE
	FROM PanelistEligibility
	WHERE PanelistId = @panelistid
	DELETE
	FROM PanelistLogonCode
	WHERE PanelistId = @panelistid
	DELETE
	FROM PanelistSummaryCount
	WHERE PanelistId = @panelistid
	DELETE
	FROM PartyPanelSurveyParticipationTask
	WHERE Panelist_Id = @panelistid
	DELETE
	FROM PollingOccasionSummary
	WHERE PanelistId = @panelistid
	Delete from StockStateDefinitionHistory where StockItem_Id in (select guidreference  FROM StockItem
	WHERE Panelist_Id =  @panelistid)
	DELETE
	FROM StateDefinitionHistory
	WHERE Panelist_Id = @panelistid
	Delete from orderitem where StockItemId in (select guidreference  FROM StockItem
	WHERE Panelist_Id =  @panelistid)
	DELETE
	FROM StockItem
	WHERE Panelist_Id = @panelistid
	DELETE
	FROM StockItemHistory
	WHERE PanelistID = @panelistid
	DELETE
	FROM StockKitHistory
	WHERE Panelist_Id = @panelistid
	Delete from [order] where Location_Id in (select guidreference  FROM StockPanelistLocation
	WHERE Panelist_Id = @panelistid )
	DELETE
	FROM StockPanelistLocation
	WHERE Panelist_Id = @panelistid
	DELETE
	FROM StockStateDefinitionHistory
	WHERE Panelist_Id = @panelistid
	DELETE
	FROM Panelist
	WHERE GUIDReference = @panelistid
END
DECLARE @Group_Id UNIQUEIDENTIFIER
SELECT @Group_Id=Group_Id 
FROM Individual I 
INNER JOIN CollectiveMembership CM ON CM.Individual_Id=I.GUIDReference  
WHERE I.IndividualId=@IndividualId and Country_Id = @CountryId
/* updating all individual Candidate status */
	INSERT INTO StateDefinitionHistory (GUIDReference
      , GPSUser
      , CreationDate
      , GPSUpdateTimestamp
      , CreationTimeStamp
      , Comments
      , CollaborateInFuture
      , From_Id
      , To_Id
      , ReasonForchangeState_Id
      , Country_Id
      , Candidate_Id)
        SELECT
          NEWID(),

          @GPSUser,

          @GetDate,

          @GetDate,

          @GetDate,

          NULL AS Comments,

          0 AS CollaborateInFuture,

          C.CandidateStatus,

          dbo.fnGetIndividualStatus(C.GUIDReference),

          NULL AS ReasonForChange,

          @CountryId AS CountryId,

          CMP.Individual_Id AS CandidateId

        FROM Collective G 

	INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = G.GUIDReference  

	INNER JOIN Candidate C ON C.GUIDReference = CMP.Individual_Id

	WHERE C.Country_Id = @CountryId AND  G.GUIDReference=@Group_Id 

	     AND C.CandidateStatus <> dbo.fnGetIndividualStatus(C.GUIDReference) 











	UPDATE C

	SET C.CandidateStatus = dbo.fnGetIndividualStatus(C.GUIDReference),

		C.GPSUser = @GPSUser,

		C.GPSUpdateTimestamp = @GetDate

	FROM Collective G 

	INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = G.GUIDReference  

	INNER JOIN Candidate C

		ON C.GUIDReference = CMP.Individual_Id

	WHERE C.Country_Id = @CountryId AND  G.GUIDReference=@Group_Id 

	     AND C.CandidateStatus <> dbo.fnGetIndividualStatus(C.GUIDReference) 

		

	

	/* Group Status */



	INSERT INTO StateDefinitionHistory (GUIDReference

      , GPSUser

      , CreationDate

      , GPSUpdateTimestamp

      , CreationTimeStamp

      , Comments

      , CollaborateInFuture

      , From_Id

      , To_Id

      , ReasonForchangeState_Id

      , Country_Id

      , Candidate_Id)

        SELECT

          NEWID(),

          @GPSUser,

          @GetDate,

          @GetDate,

          @GetDate,

          NULL AS Comments,

          0 AS CollaborateInFuture,

          C.CandidateStatus,

          dbo.fnGetIndividualStatus(C.GUIDReference),

          NULL AS ReasonForChange,

          @CountryId AS CountryId,

          C.GUIDReference 

        FROM Collective G 

	INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = G.GUIDReference  

	INNER JOIN Candidate C ON C.GUIDReference = CMP.Individual_Id

	WHERE C.Country_Id = @CountryId AND  G.GUIDReference=@Group_Id 

	     AND C.CandidateStatus <> dbo.fnGetIndividualStatus(C.GUIDReference) 







 

  



	  UPDATE C

      SET C.CandidateStatus = @groupTerminatedStatusGuid,

          C.GPSUpdateTimestamp = @GetDate,

          C.GPSUser = @GPSUser

      FROM Collective G

      INNER JOIN Candidate C ON G.GUIDReference   = C.GUIDReference

      WHERE G.GUIDReference=@Group_Id AND (( @individualDropOf = ALL (SELECT

                                                I.CandidateStatus

                                           FROM CollectiveMembership CM

                                           INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference

                                           WHERE CM.Group_Id = C.GUIDReference))

                                  OR

                                  (0 = ALL

                                  (

                                       SELECT IIF(PL.State_Id=@PanelistDropoutStateId,0,1)

                                         FROM CollectiveMembership CM 

                                          INNER JOIN Panelist PL ON CM.Individual_Id=PL.PanelMember_Id

                                         WHERE CM.Group_Id=C.GUIDReference

                                         UNION 

                                          SELECT IIF(PL.State_Id=@PanelistDropoutStateId,0,1) 

                                          FROM CollectiveMembership CM 

                                          INNER JOIN Panelist PL ON CM.Individual_Id=PL.PanelMember_Id

                                         WHERE CM.Group_Id=C.GUIDReference

                                  )

                                  ))





	  UPDATE C

      SET C.CandidateStatus = @groupParticipantStatusGuid,

          C.GPSUpdateTimestamp = @GetDate,

          C.GPSUser = @GPSUser

      FROM Collective G

      INNER JOIN Candidate C ON G.GUIDReference   = C.GUIDReference

      WHERE G.GUIDReference=@Group_Id AND @individualParticipent = ANY (SELECT

					I.CandidateStatus

				  FROM CollectiveMembership CM

				  INNER JOIN Candidate I

					ON CM.Individual_Id = I.GUIDReference

				  WHERE CM.Group_Id = C.GUIDReference)
	UPDATE C
      SET C.CandidateStatus = @groupAssignedStatusGuid,
          C.GPSUpdateTimestamp = @GetDate,
          C.GPSUser = @GPSUser
      FROM Collective G
      INNER JOIN Candidate C ON G.GUIDReference   = C.GUIDReference
      WHERE G.GUIDReference=@Group_Id AND EXISTS (SELECT
					1
				  FROM CollectiveMembership CM
				  INNER JOIN Candidate I
					ON CM.Individual_Id = I.GUIDReference
				  WHERE CM.Group_Id = C.GUIDReference
				  AND I.CandidateStatus NOT IN (
					   @individualParticipent
					  , @IndividualCandidate
					  , @individualDropOf
				  ))
      AND @individualAssignedGuid = ANY (SELECT
				I.CandidateStatus
			  FROM CollectiveMembership CM
			  INNER JOIN Candidate I
				ON CM.Individual_Id = I.GUIDReference
			  WHERE CM.Group_Id = C.GUIDReference)
	AND @individualParticipent <> ALL (SELECT
				I.CandidateStatus
			  FROM CollectiveMembership CM
			  INNER JOIN Candidate I
				ON CM.Individual_Id = I.GUIDReference
			  WHERE CM.Group_Id = C.GUIDReference)
		 UPDATE C
      SET C.CandidateStatus = @groupCandidateStatusGuid,
          C.GPSUpdateTimestamp = @GetDate,
          C.GPSUser = @GPSUser
      FROM Collective G
      INNER JOIN Candidate C ON G.GUIDReference   = C.GUIDReference
      WHERE G.GUIDReference=@Group_Id AND  @IndividualCandidate = ALL (SELECT
							I.CandidateStatus
						  FROM CollectiveMembership CM
						  INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
						  WHERE CM.Group_Id = C.GUIDReference)
	COMMIT TRANSACTION
     END TRY
		BEGIN CATCH
		DECLARE @error NVARCHAR(max) = (
				SELECT ERROR_MESSAGE()
				)
		RAISERROR (
				@error
				,16
				,1
				)
		ROLLBACK TRANSACTION
	END CATCH
END
