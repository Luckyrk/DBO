CREATE PROCEDURE ChangePanelistActionstateFromInrule
 @pBusinessId VARCHAR(100),
 @pPanelCode INT,
 @pCountryCode VARCHAR(100),
 @pUser NVARCHAR(100) = 'InRule',
 @pActionState INT
AS
BEGIN
DECLARE @individualId UNIQUEIDENTIFIER
DECLARE @groupId UNIQUEIDENTIFIER
DECLARE @panelType VARCHAR(20)
DECLARE @countryId UNIQUEIDENTIFIER
DECLARE @GetDate DATETIME
SET @GetDate = (select dbo.GetLocalDateTime(GETDATE(),@pCountryCode))

		SET @countryId = (
				SELECT TOP 1 CountryId
				FROM Country
				WHERE CountryISO2A = @pCountryCode
				)

			SET @individualId = (
				SELECT TOP 1 GUIDReference
				FROM Individual
				WHERE IndividualId = @pBusinessId
					AND CountryId = @countryId
				)

				SET @panelType = (		
					SELECT TOP 1 [Type]
				FROM Panel
				WHERE PanelCode = @pPanelCode
					AND Country_Id = @countryId
				)

				IF(@panelType='HouseHold')
				BEGIN
						SET @groupId = (
					SELECT TOP 1 Group_Id
					FROM CollectiveMembership CM
					JOIN Collective C ON C.GUIDReference=CM.Group_Id
					WHERE C.Sequence=@pBusinessId AND C.CountryId=@countryId
					)

				END



				UPDATE AT SET AT.[State]=@pActionState,GPSUser=@pUser,GPSUpdateTimestamp=@GetDate
				FROM
				ActionTask AT
				JOIN 
					(	SELECT @individualId  AS Individual_Id
						UNION
						SELECT Individual_Id
						FROM CollectiveMembership
						WHERE Group_Id = @groupId
					) T ON T.Individual_Id=AT.Candidate_Id


END
