create PROCEDURE [dbo].[GetAllIndividuals] 

@pBusinessId UNIQUEIDENTIFIER,

@pcountryId UNIQUEIDENTIFIER


	,@pPageNumber INT = 1
	,@pPageSize INT = 100
	,@pIsExport BIT = 0
	,@pParametersTable dbo.GridParametersTable readonly

as

BEGIN


	DECLARE @OFFSETRows INT = 0
	IF (@pIsExport = 0)
		SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))
	ELSE
		SET @pPageSize = 15000;
	SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))
DECLARE @GROUPID AS UNIQUEIDENTIFIER

SET @GROUPID=(SELECT Group_Id  FROM CollectiveMembership  WHERE Individual_Id =@pBusinessId and Country_Id=@pcountryId )

 SELECT 

      count( ind.GUIDReference)

	

	FROM CollectiveMembership  cmp

	INNER JOIN Collective c ON cmp.Group_Id = c.GUIDReference

	INNER JOIN Candidate cand ON cand.GUIDReference = c.GUIDReference

	INNER JOIN Country ON Country.CountryId = cand.Country_Id

	INNER JOIN CountryConfiguration ON CountryConfiguration.Id = Country.Configuration_Id

	INNER JOIN Individual ind ON ind.GUIDReference = cmp.Individual_Id

	INNER JOIN PersonalIdentification p ON p.PersonalIdentificationId = ind.PersonalIdentificationId

	inner join IncentiveAccount inc on ind.GUIDReference =inc.IncentiveAccountId

	WHERE c.GUIDReference = @GroupId and ind.GUIDReference <>@pBusinessId 

SELECT 

        ind.GUIDReference,

		ind.GUIDReference AS Id

		,p.LastOrderedName  AS LastName

		,ind.IndividualId AS BusinessId

		,p.MiddleOrderedName AS MiddleName

		,p.FirstOrderedName AS FirstName

		,p.DateOfBirth AS DateOfBirth

		,(CASE inc.Type

WHEN 'OwnAccount' THEN 'OwnAccount'

WHEN 'RelatedAccount' THEN 'Do Not Own an Account'



END) as AccountDescription

	,inc.Type AccountType

	FROM CollectiveMembership  cmp

	INNER JOIN Collective c ON cmp.Group_Id = c.GUIDReference

	INNER JOIN Candidate cand ON cand.GUIDReference = c.GUIDReference

	INNER JOIN Country ON Country.CountryId = cand.Country_Id

	INNER JOIN CountryConfiguration ON CountryConfiguration.Id = Country.Configuration_Id

	INNER JOIN Individual ind ON ind.GUIDReference = cmp.Individual_Id

	INNER JOIN PersonalIdentification p ON p.PersonalIdentificationId = ind.PersonalIdentificationId

	inner join IncentiveAccount inc on ind.GUIDReference =inc.IncentiveAccountId

	WHERE c.GUIDReference = @GroupId and ind.GUIDReference <>@pBusinessId 

	order by p.FirstOrderedName desc
	 OFFSET  @OFFSETRows ROWS  FETCH NEXT @pPageSize ROWS ONLY
		   OPTION (RECOMPILE)

	

	END
