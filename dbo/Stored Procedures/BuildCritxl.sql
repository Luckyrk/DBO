
CREATE PROCEDURE [dbo].[BuildCritxl]
	@Year NVARCHAR(10),
	@Period NVARCHAR(10),
	@CountryId UNIQUEIDENTIFIER,
	@Attributes Demographics READONLY,
	@CultureCode INT=2057
AS
BEGIN
	DECLARE @IndividualQuery AS NVARCHAR(MAX);
	DECLARE @HouseholdQuery AS NVARCHAR(MAX);
	DECLARE @IndividualColumns AS NVARCHAR(MAX);

	DECLARE @HouseholdColumns AS NVARCHAR(MAX);
	DECLARE @IndividualKeys AS NVARCHAR(MAX);
	DECLARE @HouseholdKeys AS NVARCHAR(MAX);
	DECLARE @IndividualView NVARCHAR(100);
	DECLARE @HouseholdView NVARCHAR(100);

	DECLARE @IndividualColumnNames AS NVARCHAR(MAX);
	DECLARE @HouseholdColumnNames AS NVARCHAR(MAX);

	SET @Period = RIGHT('00' + @Period, 2)

	DECLARE @lockedAttributes INT;
	SELECT @lockedAttributes = COUNT(*) FROM  Critxl WHERE Country_Id = @CountryId AND [Year] = @Year AND Period = @Period AND Locked=1
	
	DELETE Critxl WHERE Country_Id = @CountryId AND [Year] = @Year AND Period = @Period
 
	INSERT INTO Critxl ([Year], Period, AttributeKey, Country_Id, Locked, UseShortCode,[GPSUser],[GPSUpdateTimestamp],[CreationTimeStamp])
	SELECT @Year, @Period, A.[Key], @CountryId, IIF(@lockedAttributes > 0, 1, 0) as Locked,T.UseShortCode,'',GETDATE(),GETDATE()
	FROM @Attributes T
	JOIN Attribute A ON T.DemographicName = A.GUIDReference

	--Get distinct values of the PIVOT Column 
	SELECT	@IndividualColumns = ISNULL(@IndividualColumns + ',','') + QUOTENAME(AttributeKey),
			@IndividualKeys = ISNULL(@IndividualKeys + ',','') + '''' + AttributeKey + '''',
			@IndividualColumnNames = ISNULL(@IndividualColumnNames + ',','') + AttributeName
	FROM (SELECT DISTINCT AttributeKey, CONCAT('[', AttributeKey, '] AS [', IIF(ISNULL(UseShortCode, 0) = 1, ISNULL(ShortCode, AttributeKey), AttributeKey), ']') AS AttributeName
		FROM Critxl C
		JOIN Attribute A ON A.Country_Id = C.Country_Id AND A.[Key] = C.AttributeKey
		JOIN AttributeScope S ON A.Scope_Id = S.GUIDReference
		WHERE C.Country_Id = @CountryId AND C.[Year] = @Year AND C.Period = @Period AND S.[Type] = 'Individual') AS Critxl

	SELECT	@HouseholdColumns = ISNULL(@HouseholdColumns + ',','') + QUOTENAME(AttributeKey),
			@HouseholdKeys = ISNULL(@HouseholdKeys + ',','') + '''' + AttributeKey + '''',
			@HouseholdColumnNames = ISNULL(@HouseholdColumnNames + ',','') + AttributeName
	--FROM (SELECT DISTINCT AttributeKey FROM Critxl C
	FROM (SELECT DISTINCT AttributeKey, CONCAT('[', AttributeKey, '] AS [', IIF(ISNULL(UseShortCode, 0) = 1, ISNULL(ShortCode, AttributeKey), AttributeKey), ']') AS AttributeName
		FROM Critxl C
		JOIN Attribute A ON A.Country_Id = C.Country_Id AND A.[Key] = C.AttributeKey
		JOIN AttributeScope S ON A.Scope_Id = S.GUIDReference
		WHERE C.Country_Id = @CountryId AND C.[Year] = @Year AND C.Period = @Period AND S.[Type] = 'HouseHold') AS Critxl

 
	--Prepare the PIVOT query using the dynamic 
	IF EXISTS(SELECT NAME FROM sys.views WHERE NAME LIKE 'CritxlIndiv_' + @Year + @Period)
		SET @IndividualView = 'ALTER VIEW CritxlIndiv_' + @Year + @Period
	ELSE
		SET @IndividualView = 'CREATE VIEW CritxlIndiv_' + @Year + @Period

	IF EXISTS(SELECT NAME FROM sys.views WHERE NAME LIKE 'CritxlFoyer_' + @Year + @Period)
		SET @HouseholdView = 'ALTER VIEW CritxlFoyer_' + @Year + @Period
	ELSE
		SET @HouseholdView = 'CREATE VIEW CritxlFoyer_' + @Year + @Period

	SET @IndividualQuery = 
	  @IndividualView + 
	  N' AS SELECT CountryISO2A, [Year], Period, IndividualId AS BusinessId, ' + ISNULL(@IndividualColumnNames, ''''' AS [NULL]') + ' FROM (
			SELECT CV.Year, CV.Period, CV.Candidate_Id, I.IndividualId, CV.AttributeKey, ISNULL(CV.Value, A.CritxlDefaultValue) AS Value, CN.CountryISO2A
				FROM CritxlValue CV				
				JOIN Individual I ON CV.Candidate_Id = I.GUIDReference				
				JOIN Country CN ON I.CountryId = CN.CountryId
				--JOIN Critxl C ON C.[Year]=CV.[Year] AND C.Period=CV.Period AND C.AttributeKey=CV.AttributeKey AND C.Country_Id=CN.CountryId
				JOIN Attribute A ON A.Country_Id = I.CountryId AND A.[Key] = CV.AttributeKey
				WHERE CV.Year = ' + @Year + ' AND CV.Period = ' + @Period + ' AND CV.AttributeKey IN (' + ISNULL(@IndividualKeys, '''''') + ')
		) AS Source PIVOT(MAX(Value) 
					  FOR AttributeKey IN (' + ISNULL(@IndividualColumns, '[NULL]') + ')) AS PVT'

	SET @HouseholdQuery = 
	  @HouseholdView + 
	  N' AS SELECT CountryISO2A, [Year], Period, Sequence, ' + ISNULL(@HouseholdColumnNames, ''''' AS [NULL]') + ' FROM (
			SELECT CV.Year, CV.Period, CV.Candidate_Id, H.Sequence, CV.AttributeKey, ISNULL(CV.Value, A.CritxlDefaultValue) AS Value, CN.CountryISO2A
				FROM CritxlValue CV
				JOIN Collective H ON CV.Candidate_Id = H.GUIDReference
				JOIN Country CN ON H.CountryId = CN.CountryId
				--JOIN Critxl C ON C.[Year]=CV.[Year] AND C.Period=CV.Period AND C.AttributeKey=CV.AttributeKey AND C.Country_Id=CN.CountryId
				JOIN Attribute A ON A.Country_Id = H.CountryId AND A.[Key] = CV.AttributeKey
				WHERE CV.Year = ' + @Year + ' AND CV.Period = ' + @Period + ' AND CV.AttributeKey IN (' + ISNULL(@HouseholdKeys, '''''') + ')
		) AS Source PIVOT(MAX(Value) 
					  FOR AttributeKey IN (' + ISNULL(@HouseholdColumns, '[NULL]') + ')) AS PVT'

	
	--Execute the Dynamic Pivot Query
	EXEC sp_executesql @IndividualQuery
	EXEC sp_executesql @HouseholdQuery

END
